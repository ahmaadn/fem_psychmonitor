// Web / non-IO stub: SER (MFCC FFI + TFLite + FFmpeg) is native-only.
// Same public surface as EmotionDetector so UI and Provider wiring stay shared.

import 'dart:async';

import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/foundation.dart';

class EmotionDetector extends ChangeNotifier {
  bool _ready = false;
  bool _detecting = false;
  bool _processingUpload = false;
  String? _error =
      'Emotion detection is not available on web. Use Android for SER.';
  EmotionResult? _latest;
  String? _lastRecordingPath;
  String? _lastDetectionPath;
  String? _lastUploadedPath;
  final List<EmotionResult> _timeline = [];
  bool _isSpeaking = false;
  bool _isPaused = false;

  bool get isReady => _ready;
  bool get isDetecting => _detecting;
  bool get isProcessingUpload => _processingUpload;
  String? get error => _error;
  EmotionResult? get latest => _latest;
  String? get lastRecordingPath => _lastRecordingPath;
  String? get lastDetectionPath => _lastDetectionPath;
  String? get lastUploadedPath => _lastUploadedPath;
  List<EmotionResult> get timeline => List.unmodifiable(_timeline);
  Stream<double> get onAmplitudeChanged => const Stream.empty();
  bool get isPaused => _isPaused;
  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    // Stay not-ready so recording flows can show the error message.
    _ready = false;
    _error =
        'Emotion detection is not available on web. Use Android for SER.';
    notifyListeners();
  }

  Future<void> startDetection({bool saveToFile = true}) async {
    _error =
        'Emotion detection is not available on web. Use Android for SER.';
    notifyListeners();
  }

  Future<String?> stopDetection() async {
    _detecting = false;
    _isSpeaking = false;
    _isPaused = false;
    notifyListeners();
    return null;
  }

  Future<void> pauseDetection() async {
    _isPaused = true;
    notifyListeners();
  }

  Future<void> resumeDetection() async {
    _isPaused = false;
    notifyListeners();
  }

  Future<String?> detectFromAudioFile(String filePath) async {
    _error =
        'Emotion detection is not available on web. Use Android for SER.';
    _processingUpload = false;
    notifyListeners();
    return null;
  }

  void clearTimeline() {
    _timeline.clear();
    _latest = null;
    _lastRecordingPath = null;
    _lastDetectionPath = null;
    _lastUploadedPath = null;
    notifyListeners();
  }
}
