// lib/services/emotion_detector.dart
//
// Top-level controller exposed to the UI via ChangeNotifier.
// Owns InferenceIsolateManager + AudioService, wires them together.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/detection/services/audio_service.dart';
import 'package:fem_psychmonitor/detection/services/documents_storage_service.dart';
import 'package:fem_psychmonitor/detection/services/inference_isolate.dart';
import 'package:flutter/material.dart';

class EmotionDetector extends ChangeNotifier {
  static const int _sampleRate = 16000;
  static const int _chunkSamples = 48000;
  static const int _strideSamples = 24000;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _ready = false;
  bool _detecting = false;
  bool _processingUpload = false;
  String? _error;
  EmotionResult? _latest;
  String? _lastRecordingPath;
  String? _lastDetectionPath;
  String? _lastUploadedPath;
  String? _sessionId;
  DateTime? _sessionStartedAt;
  int _sessionStartIndex = 0;
  final List<EmotionResult> _timeline = [];

  bool get isReady => _ready;
  bool get isDetecting => _detecting;
  bool get isProcessingUpload => _processingUpload;
  String? get error => _error;
  EmotionResult? get latest => _latest;
  String? get lastRecordingPath => _lastRecordingPath;
  String? get lastDetectionPath => _lastDetectionPath;
  String? get lastUploadedPath => _lastUploadedPath;
  List<EmotionResult> get timeline => List.unmodifiable(_timeline);
  Stream<double> get onAmplitudeChanged => _ready ? _audio.onAmplitudeChanged : const Stream.empty();
  bool get isPaused => _ready ? _audio.isPaused : false;

  // ── Internals ──────────────────────────────────────────────────────────────
  late final InferenceIsolateManager _isolate;
  late final DocumentsStorageService _documentsStorage;
  late final AudioService _audio;
  StreamSubscription<EmotionResult>? _resultSub;
  StreamSubscription<String>? _errorSub;

  // ── Initialize: extract model from assets, boot isolate
  Future<void> init() async {
    if (_ready) return;
    try {
      _isolate = InferenceIsolateManager();
      await _isolate.start('assets/models/female_model.tflite');
      _documentsStorage = DocumentsStorageService();

      _audio = AudioService(
        inferenceManager: _isolate,
        storageService: _documentsStorage,
      );

      // Wire results from isolate → UI
      _resultSub = _isolate.results.listen(_onResult);
      _errorSub = _isolate.errors.listen(_onError);

      _ready = true;
      notifyListeners();
    } catch (e) {
      _error = 'Inisialisasi gagal: $e';
      notifyListeners();
    }
  }

  Future<void> startDetection({bool saveToFile = true}) async {
    if (!_ready || _detecting) return;
    _error = null;
    _lastRecordingPath = null;
    _lastDetectionPath = null;
    _sessionId = _documentsStorage.createSessionId();
    _sessionStartedAt = DateTime.now();
    _sessionStartIndex = _timeline.length;
    _detecting = true;
    notifyListeners();
    await _audio.start(saveToFile: saveToFile, sessionId: _sessionId);
  }

  Future<String?> stopDetection() async {
    if (!_detecting) {
      return null;
    }
    final sessionStoppedAt = DateTime.now();
    _lastRecordingPath = await _audio.stop();

    final sessionResults = _timeline.sublist(_sessionStartIndex);
    final sessionStartedAt = _sessionStartedAt ?? sessionStoppedAt;
    final sessionId = _sessionId ?? _documentsStorage.createSessionId();
    _lastDetectionPath = await _documentsStorage.saveEncryptedDetectionTimeline(
      timeline: sessionResults,
      recordingPath: _lastRecordingPath,
      sessionId: sessionId,
      sessionStartedAt: sessionStartedAt,
      sessionStoppedAt: sessionStoppedAt,
    );

    _sessionId = null;
    _detecting = false;
    notifyListeners();
    return _lastRecordingPath;
  }

  Future<void> pauseDetection() async {
    if (!_detecting || isPaused) return;
    await _audio.pause();
    notifyListeners();
  }

  Future<void> resumeDetection() async {
    if (!_detecting || !isPaused) return;
    await _audio.resume();
    notifyListeners();
  }

  Future<String?> detectFromAudioFile(String filePath) async {
    if (!_ready) {
      await init();
    }
    if (_detecting) {
      await stopDetection();
    }

    _error = null;
    _processingUpload = true;
    _lastUploadedPath = filePath;
    _lastRecordingPath = filePath;
    _lastDetectionPath = null;
    _sessionId = _documentsStorage.createSessionId();
    final sessionStartedAt = DateTime.now();
    _sessionStartIndex = _timeline.length;
    notifyListeners();

    StreamSubscription<EmotionResult>? resultWaitSub;
    StreamSubscription<String>? errorWaitSub;

    try {
      final samples = await _decodeAudioFile(filePath);
      final chunks = _buildChunks(samples);

      final pendingIds = <int>{};
      final done = Completer<void>();

      resultWaitSub = _isolate.results.listen((r) {
        if (pendingIds.remove(r.requestId) &&
            pendingIds.isEmpty &&
            !done.isCompleted) {
          done.complete();
        }
      });

      errorWaitSub = _isolate.errors.listen((msg) {
        if (!done.isCompleted) {
          done.completeError(Exception(msg));
        }
      });

      for (int i = 0; i < chunks.length; i++) {
        final startSample = i * _strideSamples;
        final startSec = startSample / _sampleRate;
        final reqId = _isolate.infer(chunks[i], startSec);
        pendingIds.add(reqId);
      }

      if (pendingIds.isNotEmpty) {
        await done.future.timeout(
          const Duration(seconds: 45),
          onTimeout: () {
            throw TimeoutException('Inferensi audio file timeout');
          },
        );
      }

      final sessionStoppedAt = DateTime.now();
      final sessionResults = _timeline.sublist(_sessionStartIndex);
      final sessionId = _sessionId ?? _documentsStorage.createSessionId();

      _lastDetectionPath = await _documentsStorage
          .saveEncryptedDetectionTimeline(
            timeline: sessionResults,
            recordingPath: _lastRecordingPath,
            sessionId: sessionId,
            sessionStartedAt: sessionStartedAt,
            sessionStoppedAt: sessionStoppedAt,
          );

      _sessionId = null;
      _processingUpload = false;
      notifyListeners();
      return _lastDetectionPath;
    } catch (e) {
      _error = 'Deteksi file gagal: $e';
      _processingUpload = false;
      _sessionId = null;
      notifyListeners();
      return null;
    } finally {
      await resultWaitSub?.cancel();
      await errorWaitSub?.cancel();
    }
  }

  void clearTimeline() {
    _timeline.clear();
    _latest = null;
    _lastRecordingPath = null;
    _lastDetectionPath = null;
    _lastUploadedPath = null;
    _sessionId = null;
    notifyListeners();
  }

  Future<List<double>> _decodeAudioFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File audio tidak ditemukan: $filePath');
    }

    final bytes = await file.readAsBytes();
    if (bytes.length < 4) {
      throw Exception('File audio terlalu kecil');
    }

    if (_isWav(bytes)) {
      return _decodeWavPcm16Mono(bytes);
    }

    return _decodeRawPcm16(bytes);
  }

  bool _isWav(Uint8List bytes) {
    if (bytes.length < 12) return false;
    return bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45;
  }

  List<double> _decodeWavPcm16Mono(Uint8List bytes) {
    final bd = ByteData.sublistView(bytes);

    int channels = 0;
    int bitsPerSample = 0;
    int sampleRate = 0;
    int dataOffset = -1;
    int dataSize = 0;

    int offset = 12;
    while (offset + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = bd.getUint32(offset + 4, Endian.little);
      final chunkDataStart = offset + 8;
      final chunkDataEnd = chunkDataStart + chunkSize;

      if (chunkDataEnd > bytes.length) break;

      if (chunkId == 'fmt ') {
        final audioFormat = bd.getUint16(chunkDataStart, Endian.little);
        channels = bd.getUint16(chunkDataStart + 2, Endian.little);
        sampleRate = bd.getUint32(chunkDataStart + 4, Endian.little);
        bitsPerSample = bd.getUint16(chunkDataStart + 14, Endian.little);

        if (audioFormat != 1) {
          throw Exception('Format WAV harus PCM (linear), dapat $audioFormat');
        }
      } else if (chunkId == 'data') {
        dataOffset = chunkDataStart;
        dataSize = chunkSize;
        break;
      }

      offset = chunkDataEnd + (chunkSize.isOdd ? 1 : 0);
    }

    if (dataOffset < 0 || dataSize <= 0) {
      throw Exception('Chunk data WAV tidak ditemukan');
    }
    if (channels != 1) {
      throw Exception('WAV harus mono, dapat $channels channel');
    }
    if (bitsPerSample != 16) {
      throw Exception('WAV harus 16-bit PCM, dapat $bitsPerSample-bit');
    }
    if (sampleRate != _sampleRate) {
      throw Exception(
        'Sample rate harus $_sampleRate Hz, dapat $sampleRate Hz',
      );
    }

    final sampleCount = dataSize ~/ 2;
    final out = List<double>.filled(sampleCount, 0.0, growable: false);
    for (int i = 0; i < sampleCount; i++) {
      final raw = bd.getInt16(dataOffset + i * 2, Endian.little);
      out[i] = raw / 32768.0;
    }
    return out;
  }

  List<double> _decodeRawPcm16(Uint8List bytes) {
    final bd = ByteData.sublistView(bytes);
    final sampleCount = bytes.length ~/ 2;
    final out = List<double>.filled(sampleCount, 0.0, growable: false);
    for (int i = 0; i < sampleCount; i++) {
      final raw = bd.getInt16(i * 2, Endian.little);
      out[i] = raw / 32768.0;
    }
    return out;
  }

  List<List<double>> _buildChunks(List<double> samples) {
    if (samples.isEmpty) {
      throw Exception('Audio tidak memiliki sample');
    }

    if (samples.length <= _chunkSamples) {
      final padded = List<double>.filled(_chunkSamples, 0.0);
      for (int i = 0; i < samples.length; i++) {
        padded[i] = samples[i];
      }
      return [padded];
    }

    final chunks = <List<double>>[];
    final startIndices = <int>[];
    int start = 0;
    while (start + _chunkSamples <= samples.length) {
      chunks.add(samples.sublist(start, start + _chunkSamples));
      startIndices.add(start);
      start += _strideSamples;
    }

    final lastStart = samples.length - _chunkSamples;
    if (startIndices.isEmpty || startIndices.last != lastStart) {
      chunks.add(samples.sublist(lastStart));
    }

    return chunks;
  }

  // ── Callbacks ──────────────────────────────────────────────────────────────
  void _onResult(EmotionResult r) {
    _latest = r;
    _timeline.add(r);
    // Keep at most 200 results in memory
    // if (_timeline.length > 200) _timeline.removeAt(0);
    notifyListeners();
  }

  void _onError(String msg) {
    _error = msg;
    notifyListeners();
  }

  @override
  void dispose() {
    _resultSub?.cancel();
    _errorSub?.cancel();
    _audio.dispose();
    _isolate.dispose();
    super.dispose();
  }
}
