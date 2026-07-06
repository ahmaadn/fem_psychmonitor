// Background Isolate untuk inferensi:
//   Input  : 'female_model_input'  shape=(None, 128, 121)  dtype=float32
//   Output : index 0               shape=(None, 6)         dtype=float32
//
// Pipeline per chunk:
//   audio[48000] → C++ MFCC FFI → [128×121] → TFLite → softmax[6] → EmotionResult

import 'dart:io';
import 'dart:isolate';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'mfcc_ffi.dart';

class _InferenceRequest {
  final List<double> audioChunk; // 48000 float32 samples @ 16kHz
  final double chunkStartSec;
  final int requestId;
  const _InferenceRequest({
    required this.audioChunk,
    required this.chunkStartSec,
    required this.requestId,
  });
}

class _WorkerConfig {
  final SendPort replyPort;
  final String modelPath;
  const _WorkerConfig({required this.replyPort, required this.modelPath});
}

// ─── Worker (background isolate)

/// Entry point background isolate: memuat model TFLite, lalu mendengarkan
/// permintaan inferensi dari UI isolate dan membalas dengan [EmotionResult].
Future<void> _inferenceWorker(_WorkerConfig initMsg) async {
  final config = initMsg;
  final receivePort = ReceivePort();

  // 1. Kirim balik SendPort kita ke UI isolate
  config.replyPort.send(receivePort.sendPort);

  // 2. Load TFLite interpreter
  late Interpreter interpreter;
  late int inputTensorIndex;

  try {
    interpreter = Interpreter.fromFile(
      File(config.modelPath),
      options: InterpreterOptions()..threads = 2,
    );
    interpreter.allocateTensors();

    // Nama input tensor di model: 'serving_default_female_model_input:0'
    inputTensorIndex = interpreter.getInputIndex(
      'serving_default_female_model_input:0',
    );

    final inTensor = interpreter.getInputTensor(inputTensorIndex);
    final outTensor = interpreter.getOutputTensor(0);
    config.replyPort.send(
      'READY: input[$inputTensorIndex]=${inTensor.shape} '
      'dtype=${inTensor.type} | output[0]=${outTensor.shape} '
      'dtype=${outTensor.type}',
    );
  } catch (e) {
    config.replyPort.send('ERROR: Gagal load model: $e');
    return;
  }

  // 3. Pre-alokasi output buffer [1, 6]
  final outputBuffer = [List<double>.filled(6, 0.0)];

  // 4. Listen untuk request
  receivePort.listen((msg) {
    if (msg is _InferenceRequest) {
      try {
        // A. Ekstraksi fitur via C++ FFI
        // Hasil: flat List<double> panjang 128*121 = 15488
        final flat = MfccFFI.instance.extractFeatures(msg.audioChunk);

        // B. Reshape ke [1, 128, 121]
        // TEPAT sama dengan female_model_input: (None=1, 128, 121)
        // Tidak ada channel dimension ke-4.
        final input = _reshapeTo3D(flat, 128, 121);

        // C. Reset output
        outputBuffer[0].fillRange(0, 6, 0.0);

        // D. Inferensi
        // runForMultipleInputs lebih robust untuk named-tensor models.
        interpreter.runForMultipleInputs(
          [input], // list of inputs, diindeks sesuai tensor index
          {0: outputBuffer},
        );

        // E. Parse hasil
        final probs = outputBuffer[0];
        final bestIdx = _argmax(probs);
        final label = EmotionLabelType.values[bestIdx];
        final confidence = probs[bestIdx];

        config.replyPort.send(
          EmotionResult(
            startSec: msg.chunkStartSec,
            endSec: msg.chunkStartSec + 3.0,
            label: label,
            confidence: confidence,
            allProbs: List<double>.from(probs),
            requestId: msg.requestId,
          ),
        );
      } catch (e, st) {
        config.replyPort.send('INFERENCE_ERROR: $e\n$st');
      }
    } else if (msg == 'SHUTDOWN') {
      interpreter.close();
      receivePort.close();
    }
  });
}

// ─── Helper: reshape flat → [1, rows, cols] ──────────────────────────────────
// tflite_flutter mengharapkan nested List<dynamic> untuk input multi-dimensi.
// Shape (1, 128, 121): batch=1, timeframes=128, features=121
List<List<List<double>>> _reshapeTo3D(List<double> flat, int rows, int cols) {
  assert(
    flat.length == rows * cols,
    'Expected ${rows * cols} elements, got ${flat.length}',
  );
  return [
    List<List<double>>.generate(
      rows,
      (r) => flat.sublist(r * cols, (r + 1) * cols),
    ),
  ];
}

int _argmax(List<double> v) {
  int best = 0;
  for (int i = 1; i < v.length; i++) {
    if (v[i] > v[best]) best = i;
  }
  return best;
}

// ─── Manager publik ───────────────────────────────────────────────────────────

/// Manager yang menjalankan inferensi TFLite pada background isolate.
///
/// Mengisolasi beban berat (ekstraksi MFCC via FFI + inferensi model) dari UI
/// isolate agar antarmuka tetap responsif. Komunikasi dua arah via [SendPort]:
/// UI mengirim [_InferenceRequest], worker membalas [EmotionResult] atau
/// pesan teks (READY/ERROR/INFERENCE_ERROR).
class InferenceIsolateManager {
  SendPort? _workerPort;
  int _reqId = 0;

  final ReceivePort _receivePort = ReceivePort();
  late final Stream<dynamic> _messages = _receivePort.asBroadcastStream();

  /// Stream hasil EmotionResult ke UI.
  Stream<EmotionResult> get results =>
      _messages.where((msg) => msg is EmotionResult).cast<EmotionResult>();

  /// Stream semua pesan teks dari worker (READY, ERROR, INFERENCE_ERROR).
  Stream<String> get logs =>
      _messages.where((msg) => msg is String).cast<String>();

  /// Stream hanya error.
  Stream<String> get errors => logs.where(
    (s) => s.startsWith('ERROR') || s.startsWith('INFERENCE_ERROR'),
  );

  /// Mulai background isolate. Panggil sekali saat init.
  Future<void> start(String modelPath) async {
    final localModelPath = await _resolveModelPath(modelPath);

    await Isolate.spawn(
      _inferenceWorker,
      _WorkerConfig(
        replyPort: _receivePort.sendPort,
        modelPath: localModelPath,
      ),
      errorsAreFatal: false,
      debugName: 'InferenceIsolate',
    );

    // Tunggu worker kirim SendPort-nya
    _workerPort =
        await _messages.firstWhere((msg) => msg is SendPort) as SendPort;

    // Log info shape tensor saat READY (debugPrint, bukan print produksi).
    logs
        .where((s) => s.startsWith('READY'))
        .first
        .then((msg) => debugPrint('[InferenceIsolate] $msg'));
  }

  Future<String> _resolveModelPath(String modelPath) async {
    final file = File(modelPath);
    if (await file.exists()) return file.path;
    return _materializeModelAsset(modelPath);
  }

  // Asset bundle hanya aman di main isolate. Worker cukup baca file path lokal.
  Future<String> _materializeModelAsset(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final outFile = File('${tempDir.path}/$fileName');
    await outFile.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );
    return outFile.path;
  }

  /// Kirim chunk audio ke worker. [audioChunk] harus tepat 48000 sample.
  int infer(List<double> audioChunk, double chunkStartSec) {
    assert(_workerPort != null, 'Panggil start() terlebih dahulu');
    assert(
      audioChunk.length == 48000,
      'Butuh tepat 48000 sample, dapat ${audioChunk.length}',
    );
    final requestId = _reqId++;
    _workerPort!.send(
      _InferenceRequest(
        audioChunk: audioChunk,
        chunkStartSec: chunkStartSec,
        requestId: requestId,
      ),
    );
    return requestId;
  }

  /// Shutdown bersih.
  void dispose() {
    _workerPort?.send('SHUTDOWN');
    _receivePort.close();
  }
}
