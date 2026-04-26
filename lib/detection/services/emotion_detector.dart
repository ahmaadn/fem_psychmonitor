// lib/services/emotion_detector.dart
//
// Top-level controller exposed to the UI via ChangeNotifier.
// Owns InferenceIsolateManager + AudioService, wires them together.

import 'dart:async';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/detection/services/audio_service.dart';
import 'package:fem_psychmonitor/detection/services/inference_isolate.dart';
import 'package:flutter/material.dart';

class EmotionDetector extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  bool _ready = false;
  bool _detecting = false;
  String? _error;
  EmotionResult? _latest;
  final List<EmotionResult> _timeline = [];

  bool get isReady => _ready;
  bool get isDetecting => _detecting;
  String? get error => _error;
  EmotionResult? get latest => _latest;
  List<EmotionResult> get timeline => List.unmodifiable(_timeline);

  // ── Internals ──────────────────────────────────────────────────────────────
  late final InferenceIsolateManager _isolate;
  late final AudioService _audio;
  StreamSubscription<EmotionResult>? _resultSub;
  StreamSubscription<String>? _errorSub;

  // ── Initialize: extract model from assets, boot isolate ───────────────────
  Future<void> init() async {
    if (_ready) return;
    try {
      _isolate = InferenceIsolateManager();
      await _isolate.start('assets/models/female_model.tflite');

      _audio = AudioService(inferenceManager: _isolate);

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

  Future<void> startDetection() async {
    if (!_ready || _detecting) return;
    _error = null;
    _detecting = true;
    notifyListeners();
    await _audio.start();
  }

  Future<void> stopDetection() async {
    if (!_detecting) return;
    await _audio.stop();
    _detecting = false;
    notifyListeners();
  }

  void clearTimeline() {
    _timeline.clear();
    _latest = null;
    notifyListeners();
  }

  // ── Callbacks ──────────────────────────────────────────────────────────────
  void _onResult(EmotionResult r) {
    _latest = r;
    _timeline.add(r);
    // Keep at most 200 results in memory
    if (_timeline.length > 200) _timeline.removeAt(0);
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
