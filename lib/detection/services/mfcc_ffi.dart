import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ─── Native function signatures ──────────────────────────────────────────────

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

// ─── Singleton loader ────────────────────────────────────────────────────────

class MfccFFI {
  MfccFFI._();
  static MfccFFI? _instance;
  static MfccFFI get instance => _instance ??= MfccFFI._().._load();

  late final _ExtractFeaturesDart _extractFeatures;
  late final _OutputSizeDart _outputSize;

  static const int maxPadLen = 128;
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

  static DynamicLibrary _openLib() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libmfcc_extractor.so');
    } else if (Platform.isIOS) {
      // On iOS the symbols are statically linked into the runner binary.
      return DynamicLibrary.process();
    }
    throw UnsupportedError(
      'Platform not supported: ${Platform.operatingSystem}',
    );
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// [audioData] must be exactly 48 000 float32 PCM samples at 16 kHz.
  /// Returns a flat Float32List of size 128 × 121 (row-major).
  ///
  /// Allocates native memory, calls C++, copies back, frees. ~1-3 ms.
  List<double> extractFeatures(List<double> audioData) {
    assert(audioData.length == 48000, 'Need exactly 48000 samples');

    final int outSize = _outputSize(); // 128 * 121 = 15488

    // Allocate native buffers
    final Pointer<Float> nativeAudio = calloc<Float>(audioData.length);
    final Pointer<Float> nativeOutput = calloc<Float>(outSize);

    try {
      // Copy audio → native heap
      for (int i = 0; i < audioData.length; i++) {
        nativeAudio[i] = audioData[i];
      }

      // Call C++
      _extractFeatures(nativeAudio, audioData.length, nativeOutput);

      // Copy result back to Dart list
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
