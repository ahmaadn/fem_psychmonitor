// lib/detection/services/vad_detector.dart
//
// Voice Activity Detection (VAD) — pure Dart, tanpa dependency Flutter/FFI.
//
// Digunakan untuk mem-filter inferensi emosi: chunk sunyi dilewati sepenuhnya
// agar model tidak pernah dijalankan terhadap noise/sunyi (yang jika
// dibiarkan akan menghasilkan prediksi "marah" yang menyesatkan, mencemari
// timeline, dan ikut bocor ke sesi berikutnya).
//
// Algoritma: energi per-frame (RMS) + Zero-Crossing Rate (ZCR). Sebuah frame
// dianggap "voiced" bila RMS-nya di atas `rmsThreshold` DAN ZCR-nya di bawah
// atau sama dengan `zcrMax`. Sebuah chunk dianggap berisi ucapan ketika
// frasi frame yang voiced >= `minVoicedFraction`.
//
// Konstanta dapat disetel (lewat named param/field, bukan angka ajaib). Nilai
// default dikalibrasi untuk percakapan near-field mic ponsel pada 16 kHz. Cara
// rekalibrasi:
//   - Rekam beberapa detik sunyi murni lalu setel `rmsThreshold` agar sunyi
//     mengembalikan false.
//   - Rekam ucapan normal dan pastikan `minVoicedFraction` terpenuhi dengan
//     nyaman.
//   - Turunkan `rmsThreshold` bila ucapan pelan ikut terlewat (false-negative).
//
// Dapat di-unit-test: input berupa `List<double>` dalam rentang [-1, 1].

import 'dart:math' as math;

/// Voice Activity Detection (VAD) — pure Dart, tanpa dependency Flutter/FFI.
///
/// Digunakan untuk mem-filter inferensi emosi: chunk sunyi dilewati sepenuhnya
/// agar model tidak pernah dijalankan terhadap noise/sunyi (yang jika
/// dibiarkan akan menghasilkan prediksi "marah" yang menyesatkan, mencemari
/// timeline, dan ikut bocor ke sesi berikutnya).
///
/// Algoritma: energi per-frame (RMS) + Zero-Crossing Rate (ZCR). Sebuah frame
/// dianggap "voiced" bila RMS-nya di atas [rmsThreshold] DAN ZCR-nya di bawah
/// atau sama dengan [zcrMax]. Sebuah chunk dianggap berisi ucapan ketika
/// fraksi frame yang voiced >= [minVoicedFraction].
class VadDetector {
  VadDetector({
    this.frameMs = 30,
    this.rmsThreshold = 0.01, // ~-40 dBFS
    this.zcrMax = 0.3,
    this.minVoicedFraction = 0.15,
  });

  /// Panjang frame dalam milidetik (default 30 ms → 480 sample pada 16 kHz).
  final double frameMs;

  /// Energi RMS minimum agar sebuah frame dianggap voiced (linear, ~0.01).
  final double rmsThreshold;

  /// Zero-Crossing Rate maksimum agar sebuah frame dianggap voiced. Ucapan
  /// cenderung memiliki ZCR lebih rendah daripada sunyi/noise; sunyi murni
  /// sering memiliki ZCR tinggi dan acak.
  final double zcrMax;

  /// Fraksi minimum frame voiced agar seluruh chunk dianggap berisi ucapan.
  final double minVoicedFraction;

  /// Mengembalikan true bila [chunk] mengandung ucapan, false bila sunyi/noise.
  ///
  /// [chunk] adalah jendela PCM mono dalam rentang [-1, 1]. [sampleRate]
  /// default 16 kHz.
  bool isSpeech(List<double> chunk, {int sampleRate = 16000}) {
    if (chunk.isEmpty) return false;

    final int frameSize = (frameMs * sampleRate / 1000).round();
    if (frameSize <= 0) return false;

    final int frameCount = chunk.length ~/ frameSize;
    if (frameCount == 0) {
      // Chunk shorter than one frame: evaluate the whole thing as a frame.
      final double rms = _frameRms(chunk, 0, chunk.length);
      final double zcr = _frameZcr(chunk, 0, chunk.length);
      return rms >= rmsThreshold && zcr <= zcrMax;
    }

    int voiced = 0;
    for (int i = 0; i < frameCount; i++) {
      final start = i * frameSize;
      final rms = _frameRms(chunk, start, frameSize);
      final zcr = _frameZcr(chunk, start, frameSize);
      if (rms >= rmsThreshold && zcr <= zcrMax) voiced++;
    }

    final fraction = voiced / frameCount;
    return fraction >= minVoicedFraction;
  }

  /// Energi RMS sebuah frame: sqrt(mean(x^2)).
  double _frameRms(List<double> chunk, int start, int length) {
    double sumSq = 0.0;
    final end = start + length;
    for (int i = start; i < end; i++) {
      final v = chunk[i];
      sumSq += v * v;
    }
    return math.sqrt(sumSq / length);
  }

  /// Zero-Crossing Rate: jumlah pergantian tanda / jumlah sample.
  double _frameZcr(List<double> chunk, int start, int length) {
    if (length <= 1) return 0.0;
    int crossings = 0;
    final end = start + length - 1;
    for (int i = start; i < end; i++) {
      final a = chunk[i];
      final b = chunk[i + 1];
      if ((a >= 0.0 && b < 0.0) || (a < 0.0 && b >= 0.0)) crossings++;
    }
    return crossings / (length - 1);
  }
}
