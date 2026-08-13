// AudioService — merekam audio mikrofon dan mengirim chunk ke inferensi.
//
// Mengelola stream PCM 16-bit/16 kHz/mono dari `record`, memelihara ring buffer
// berisi 3 detik audio terakhir, lalu setiap 1,5 detik menarik jendela 3 detik
// untuk dikirim ke [InferenceIsolateManager]. Setiap chunk terlebih dahulu
// diuji dengan [VadDetector]; chunk sunyi tidak diteruskan ke inferensi.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fem_psychmonitor/detection/services/documents_storage_service.dart';
import 'package:fem_psychmonitor/detection/services/inference_isolate.dart';
import 'package:fem_psychmonitor/detection/services/vad_detector.dart';
import 'package:record/record.dart';

/// Layanan perekaman audio real-time yang menghubungkan mikrofon, VAD, dan
/// inferensi emosi.
///
/// Mengubah stream PCM mentah menjadi amplitudo (untuk visualisasi), status
/// VAD (sedang berbicara/diam), serta chunk 3 detik yang diteruskan ke isolate
/// inferensi. Opsional menyimpan rekaman PCM ke file (lihat [start]).
class AudioService {
  AudioService({
    required this.inferenceManager,
    required this.storageService,
    VadDetector? vad,
  }) : _vad = vad ?? VadDetector();

  final InferenceIsolateManager inferenceManager;
  final DocumentsStorageService storageService;
  final VadDetector _vad;

  final AudioRecorder _recorder = AudioRecorder();

  // Ring buffer: holds the last 3 s of audio (48 000 samples)
  static const int _sampleRate = 16000;
  static const int _chunkSamples = 48000; // 3 s
  static const int _strideMs = 1500; // stride 1.5 s

  final List<double> _ringBuffer = [];
  double _recordedSeconds = 0.0;
  bool _running = false;
  bool _isPaused = false;
  bool get isPaused => _isPaused;

  final StreamController<double> _amplitudeController = StreamController<double>.broadcast();
  Stream<double> get onAmplitudeChanged => _amplitudeController.stream;

  // VAD state: true while speech is detected in the latest chunk.
  final StreamController<bool> _vadStateController = StreamController<bool>.broadcast();
  Stream<bool> get onVadStateChanged => _vadStateController.stream;
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  void _setVadState(bool speaking) {
    if (_isSpeaking == speaking) return;
    _isSpeaking = speaking;
    if (!_vadStateController.isClosed) _vadStateController.add(speaking);
  }

  int _sampleCounter = 0;
  double _currentMax = 0.0;

  StreamSubscription<Uint8List>? _audioSub;
  Timer? _strideTimer;
  IOSink? _pcmSink;
  File? _pcmFile;
  String? _activeSessionId;
  String? _lastSavedRecordingPath;

  String? get lastSavedRecordingPath => _lastSavedRecordingPath;

  // ── Mulai merekam ──────────────────────────────────────────────────────────

  /// Memulai perekaman dan pemrosesan chunk.
  ///
  /// Bila [saveToFile] true, PCM ditulis ke file rekaman; [sessionId] dapat
  /// ditentukan atau dibuat otomatis. Melempar exception bila izin mikrofon
  /// belum diberikan.
  Future<void> start({
    bool saveToFile = true,
    String? sessionId,
  }) async {
    if (_running) return;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) throw Exception('Microphone permission denied');

    _running = true;
    _isPaused = false;
    _recordedSeconds = 0.0;
    _ringBuffer.clear();

    if (saveToFile) {
      _activeSessionId = sessionId ?? storageService.createSessionId();
      final recordingIo = await storageService.openRecordingSink(
        sessionId: _activeSessionId!,
      );
      _pcmFile = recordingIo.pcmFile;
      _pcmSink = recordingIo.sink;
      _lastSavedRecordingPath = null;
    } else {
      _activeSessionId = null;
      _pcmFile = null;
      _pcmSink = null;
      _lastSavedRecordingPath = null;
    }

    // Stream raw PCM: 16-bit signed, 16 kHz, mono
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
      ),
    );

    _audioSub = stream.listen(_onAudioBytes);

    // Every 1.5 s: pull a 3-second window from ring buffer
    _strideTimer = Timer.periodic(
      const Duration(milliseconds: _strideMs),
      _onStrideTick,
    );
  }

  // ── Hentikan merekam

  /// Menghentikan perekaman, menutup file PCM, dan memfinalisasi rekaman WAV.
  /// Mengembalikan path file WAV hasil rekaman (atau null bila tidak disimpan).
  Future<String?> stop() async {
    _running = false;
    _isPaused = false;
    _strideTimer?.cancel();
    _strideTimer = null;
    await _audioSub?.cancel();
    _audioSub = null;
    await _recorder.stop();
    await _pcmSink?.flush();
    await _pcmSink?.close();
    _pcmSink = null;
    _setVadState(false);

    final sessionId = _activeSessionId ?? storageService.createSessionId();
    final savedPath = await storageService.finalizeRecording(
      _pcmFile,
      sessionId: sessionId,
    );
    _activeSessionId = null;
    _pcmFile = null;
    _lastSavedRecordingPath = savedPath;

    _ringBuffer.clear();
    return savedPath;
  }

  /// Menjeda perekaman dan timer stride (inferensi dihentikan sementara).
  Future<void> pause() async {
    if (!_running || _isPaused) return;
    await _recorder.pause();
    _isPaused = true;
    _strideTimer?.cancel();
    _strideTimer = null;
  }

  /// Melanjutkan perekaman dan timer stride setelah [pause].
  Future<void> resume() async {
    if (!_running || !_isPaused) return;
    await _recorder.resume();
    _isPaused = false;
    _strideTimer = Timer.periodic(
      const Duration(milliseconds: _strideMs),
      _onStrideTick,
    );
  }

  // ── Byte PCM masuk → ring buffer float32
  void _onAudioBytes(Uint8List bytes) {
    _pcmSink?.add(bytes);

    // 16-bit little-endian PCM → float [-1, 1]
    final ByteData bd = bytes.buffer.asByteData(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    final int sampleCount = bytes.length ~/ 2;
    for (int i = 0; i < sampleCount; i++) {
      final int raw = bd.getInt16(i * 2, Endian.little);
      final double val = raw / 32768.0;
      _ringBuffer.add(val);

      final absVal = val.abs();
      if (absVal > _currentMax) _currentMax = absVal;

      _sampleCounter++;
      // Update ~20 times per second (16000 / 20 = 800 samples)
      if (_sampleCounter >= 800) {
        _amplitudeController.add(_currentMax);
        _sampleCounter = 0;
        _currentMax = 0.0;
      }
    }
    _recordedSeconds += sampleCount / _sampleRate;

    // Keep ring buffer from growing unbounded (keep last 6 s max)
    if (_ringBuffer.length > _sampleRate * 6) {
      _ringBuffer.removeRange(0, _ringBuffer.length - _sampleRate * 6);
    }
  }

  // ── Stride tick: ambil jendela 3 detik, kirim ke isolate
  void _onStrideTick(Timer _) {
    if (!_running) return;
    if (_ringBuffer.length < _chunkSamples) return; // not enough data yet

    // Grab the most recent 3 seconds
    final start = _ringBuffer.length - _chunkSamples;
    final chunk = _ringBuffer.sublist(start); // length == 48000

    final double chunkStartSec = _recordedSeconds - 3.0;

    // VAD gate: skip inference on silent chunks entirely so the model never
    // runs on noise/silence (which produces stale predictions that pollute
    // the timeline and leak into the next session). The recording file is
    // unaffected — only inference is gated.
    if (!_vad.isSpeech(chunk, sampleRate: _sampleRate)) {
      _setVadState(false);
      return;
    }
    _setVadState(true);

    inferenceManager.infer(chunk, chunkStartSec.clamp(0.0, double.infinity));
  }

  bool get isRunning => _running;

  void fromAudioBytes(Uint8List bytes) {
    _onAudioBytes(bytes);
  }

  void dispose() {
    stop();
    _amplitudeController.close();
    _vadStateController.close();
  }
}
