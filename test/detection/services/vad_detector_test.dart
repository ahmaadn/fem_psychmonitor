import 'dart:math' as math;
import 'package:fem_psychmonitor/detection/services/vad_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const int sampleRate = 16000;
  const int chunkSamples = 48000; // 3 s

  VadDetector makeDetector() => VadDetector();

  /// 3-second pure silence (all zeros).
  List<double> silenceChunk() =>
      List<double>.filled(chunkSamples, 0.0, growable: false);

  /// 3-second 220 Hz sine wave, amplitude 0.2 (speech-like energy).
  List<double> sineChunk({double freq = 220.0, double amp = 0.2}) {
    final out = List<double>.filled(chunkSamples, 0.0, growable: false);
    final twoPiFreq = 2 * math.pi * freq / sampleRate;
    for (int i = 0; i < chunkSamples; i++) {
      out[i] = amp * math.sin(twoPiFreq * i);
    }
    return out;
  }

  /// 3 s window: 2.5 s silence + 0.5 s of speech-like sine at the end.
  /// (48000 samples total → 100 frames of 480; 8000 samples of sine →
  /// ~16 voiced frames → fraction ~0.16, above the 0.15 threshold.)
  List<double> silenceThenSpeechChunk() {
    final out = List<double>.filled(chunkSamples, 0.0, growable: false);
    final speechLen = 8000; // 0.5 s @ 16 kHz
    final start = chunkSamples - speechLen;
    final twoPiFreq = 2 * math.pi * 220.0 / sampleRate;
    for (int i = 0; i < speechLen; i++) {
      out[start + i] = 0.2 * math.sin(twoPiFreq * i);
    }
    return out;
  }

  group('VadDetector.isSpeech', () {
    test('pure silence returns false', () {
      final vad = makeDetector();
      expect(vad.isSpeech(silenceChunk(), sampleRate: sampleRate), isFalse);
    });

    test('full 220 Hz sine returns true', () {
      final vad = makeDetector();
      expect(vad.isSpeech(sineChunk(), sampleRate: sampleRate), isTrue);
    });

    test('silence followed by short speech returns true', () {
      final vad = makeDetector();
      expect(
        vad.isSpeech(silenceThenSpeechChunk(), sampleRate: sampleRate),
        isTrue,
      );
    });

    test('empty chunk returns false', () {
      final vad = makeDetector();
      expect(vad.isSpeech(<double>[], sampleRate: sampleRate), isFalse);
    });
  });
}
