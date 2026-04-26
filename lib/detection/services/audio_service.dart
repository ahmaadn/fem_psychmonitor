// lib/services/audio_service.dart
//
// Captures microphone audio at 16 kHz mono, maintains a ring buffer,
// and fires a 3-second chunk to InferenceIsolateManager every 1.5 seconds.

import 'dart:async';
import 'dart:typed_data';
import 'package:fem_psychmonitor/detection/services/inference_isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

class AudioService {
  AudioService({required this.inferenceManager});

  final InferenceIsolateManager inferenceManager;

  final AudioRecorder _recorder = AudioRecorder();

  // ── Ring buffer: holds the last 3 s of audio (48 000 samples) ─────────────
  static const int _sampleRate = 16000;
  static const int _chunkSamples = 48000; // 3 s
  static const int _strideMs = 1500; // stride 1.5 s

  final List<double> _ringBuffer = [];
  double _recordedSeconds = 0.0;
  bool _running = false;

  StreamSubscription<Uint8List>? _audioSub;
  Timer? _strideTimer;

  // ── Start recording ────────────────────────────────────────────────────────
  Future<void> start() async {
    if (_running) return;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) throw Exception('Microphone permission denied');

    _running = true;
    _recordedSeconds = 0.0;
    _ringBuffer.clear();

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

  // ── Stop recording ─────────────────────────────────────────────────────────
  Future<void> stop() async {
    _running = false;
    _strideTimer?.cancel();
    _strideTimer = null;
    await _audioSub?.cancel();
    _audioSub = null;
    await _recorder.stop();
    _ringBuffer.clear();
  }

  // ── Incoming PCM bytes → float32 ring buffer ───────────────────────────────
  void _onAudioBytes(Uint8List bytes) {
    // 16-bit little-endian PCM → float [-1, 1]
    final ByteData bd = bytes.buffer.asByteData(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    final int sampleCount = bytes.length ~/ 2;
    for (int i = 0; i < sampleCount; i++) {
      final int raw = bd.getInt16(i * 2, Endian.little);
      _ringBuffer.add(raw / 32768.0);
    }
    _recordedSeconds += sampleCount / _sampleRate;

    // Keep ring buffer from growing unbounded (keep last 6 s max)
    if (_ringBuffer.length > _sampleRate * 6) {
      _ringBuffer.removeRange(0, _ringBuffer.length - _sampleRate * 6);
    }
  }

  // ── Stride tick: extract 3-second window, send to isolate ─────────────────
  void _onStrideTick(Timer _) {
    if (!_running) return;
    if (_ringBuffer.length < _chunkSamples) return; // not enough data yet

    // Grab the most recent 3 seconds
    final start = _ringBuffer.length - _chunkSamples;
    final chunk = _ringBuffer.sublist(start); // length == 48000

    final double chunkStartSec = _recordedSeconds - 3.0;

    inferenceManager.infer(chunk, chunkStartSec.clamp(0.0, double.infinity));
  }

  bool get isRunning => _running;

  void dispose() {
    stop();
  }
}
