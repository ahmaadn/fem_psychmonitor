// MFCC FFI — jembatan Dart ↔ C++ untuk ekstraksi fitur MFCC.
//
// Memanggil fungsi native `extract_features` dan `feature_output_size` dari
// pustaka `libmfcc_extractor` (Android) atau simbol yang di-link statis (iOS)
// untuk mengubah PCM audio 16 kHz menjadi matriks fitur MFCC berukuran
// 128 × 121 yang siap dimasukkan ke model TFLite.

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ─── Tanda tangan fungsi native ──────────────────────────────────────────────

typedef _ExtractFeaturesNative =
    Void Function(
      Pointer<Float> audioIn,
      Int32 nSamples,
      Pointer<Float> output,
    );
typedef _ExtractFeaturesDart =
    void Function(Pointer<Float> audioIn, int nSamples, Pointer<Float> output);

typedef _OutputSizeNative = Int32 Function();
typedef _OutputSizeDart = int Function();

// ─── Loader singleton ────────────────────────────────────────────────────────

/// Loader singleton untuk pustaka MFCC native (C++).
///
/// Meng-lookup fungsi `extract_features` dan `feature_output_size` dari
/// [DynamicLibrary] sesuai platform, lalu menyediakan API Dart untuk
/// ekstraksi fitur MFCC.
class MfccFFI {
  MfccFFI._();
  static MfccFFI? _instance;
  static MfccFFI get instance => _instance ??= MfccFFI._().._load();

  late final _ExtractFeaturesDart _extractFeatures;
  late final _OutputSizeDart _outputSize;

  /// Panjang maksimum padding (jumlah timeframe MFCC).
  static const int maxPadLen = 128;

  /// Dimensi fitur per timeframe (N_MFCC*3 + 1 = 121).
  static const int featureDim = 121; // N_MFCC*3 + 1

  void _load() {
    final DynamicLibrary lib = _openLib();
    _extractFeatures = lib
        .lookupFunction<_ExtractFeaturesNative, _ExtractFeaturesDart>(
          'extract_features',
        );
    _outputSize = lib.lookupFunction<_OutputSizeNative, _OutputSizeDart>(
      'feature_output_size',
    );
  }

  /// Membuka [DynamicLibrary] pustaka MFCC sesuai platform.
  ///
  /// Android memuat `libmfcc_extractor.so`; iOS menggunakan simbol yang
  /// di-link statis ke binary runner.
  static DynamicLibrary _openLib() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libmfcc_extractor.so');
    } else if (Platform.isIOS) {
      // Di iOS simbol di-link statis ke binary runner.
      return DynamicLibrary.process();
    }
    throw UnsupportedError(
      'Platform not supported: ${Platform.operatingSystem}',
    );
  }

  // ── API publik ─────────────────────────────────────────────────────────────

  /// Mengekstrak fitur MFCC dari [audioData].
  ///
  /// [audioData] harus tepat 48.000 sample PCM float32 pada 16 kHz.
  /// Mengembalikan [List<double>] datar berukuran 128 × 121 (row-major).
  ///
  /// Mengalokasikan memori native, memanggil C++, menyalin hasil kembali,
  /// lalu membebaskan memori. ~1-3 ms.
  List<double> extractFeatures(List<double> audioData) {
    assert(audioData.length == 48000, 'Need exactly 48000 samples');

    final int outSize = _outputSize(); // 128 * 121 = 15488

    // Alokasikan buffer native
    final Pointer<Float> nativeAudio = calloc<Float>(audioData.length);
    final Pointer<Float> nativeOutput = calloc<Float>(outSize);

    try {
      // Salin audio → heap native
      for (int i = 0; i < audioData.length; i++) {
        nativeAudio[i] = audioData[i];
      }

      // Panggil C++
      _extractFeatures(nativeAudio, audioData.length, nativeOutput);

      // Salin hasil kembali ke list Dart
      final result = List<double>.filled(outSize, 0.0);
      for (int i = 0; i < outSize; i++) {
        result[i] = nativeOutput[i];
      }
      return result;
    } finally {
      calloc.free(nativeAudio);
      calloc.free(nativeOutput);
    }
  }
}
