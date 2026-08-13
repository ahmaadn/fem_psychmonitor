// DocumentsStorageService — penyimpanan rekaman & timeline deteksi terenkripsi.
//
// Menangani: (1) penulisan stream PCM rekaman dan finalisasi ke file WAV,
// (2) penyimpanan timeline hasil deteksi sebagai JSON terenkripsi AES-256-CBC,
// serta (3) resolusi direktori Documents (publik di Android, app-documents di
// platform lain) termasuk permintaan izin storage bila perlu.

import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Layanan penyimpanan file rekaman dan timeline deteksi emosi.
///
/// File rekaman disimpan sebagai WAV (PCM16, mono, 16 kHz), sedangkan timeline
/// deteksi disimpan sebagai JSON yang dienkripsi dengan AES-256-CBC. Pada
/// Android, file disimpan ke folder Documents publik agar mudah diakses pengguna.
class DocumentsStorageService {
  static const String appName = 'fem_psychmonitor';

  static const int sampleRate = 16000;
  static const int chunkSamples = 48000;
  static const int strideMs = 1500;

  static const String _documentsFolderName = 'documents';
  static const String _encryptionKey = 'fem_psychmonitor_docs_key_32bytes';

  /// Membuat id sesi unik berbasis waktu UTC (YYYYMMDD_HHMMSS_mmm).
  String createSessionId() {
    final now = DateTime.now().toUtc();
    return '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}_'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  /// Membuka sink penulisan PCM untuk sesi [sessionId].
  ///
  /// Mengembalikan record berisi file PCM dan [IOSink]-nya. File lama dengan
  /// nama yang sama akan dihapus terlebih dahulu.
  Future<({File pcmFile, IOSink sink})> openRecordingSink({
    required String sessionId,
  }) async {
    final recordingDir = await _getRecordingDir();
    final safeId = _sanitizeSessionId(sessionId);
    final pcmFile = File('${recordingDir.path}/filerecord_$safeId.pcm');

    if (await pcmFile.exists()) {
      await pcmFile.delete();
    }

    final sink = pcmFile.openWrite(mode: FileMode.writeOnlyAppend);
    return (pcmFile: pcmFile, sink: sink);
  }

  /// Memfinalisasi rekaman: menambahkan header WAV ke file PCM lalu
  /// menghapus file PCM asli. Mengembalikan path file WAV, atau null bila
  /// [pcmFile] tidak ada.
  Future<String?> finalizeRecording(
    File? pcmFile, {
    required String sessionId,
  }) async {
    if (pcmFile == null || !await pcmFile.exists()) {
      return null;
    }

    final pcmLength = await pcmFile.length();
    final recordingDir = await _getRecordingDir();
    final safeId = _sanitizeSessionId(sessionId);
    final wavFile = File('${recordingDir.path}/filerecord_$safeId.wav');

    final header = _buildWavHeader(pcmLength);
    final sink = wavFile.openWrite();
    sink.add(header);
    await sink.addStream(pcmFile.openRead());
    await sink.flush();
    await sink.close();

    await pcmFile.delete();
    return wavFile.path;
  }

  /// Menyimpan [timeline] hasil deteksi sebagai file JSON terenkripsi
  /// AES-256-CBC beserta metadata sesi. Enkripsi dijalankan di background
  /// isolate via [compute]. Mengembalikan path file hasil.
  Future<String> saveEncryptedDetectionTimeline({
    required List<EmotionResult> timeline,
    required String? recordingPath,
    required String sessionId,
    required DateTime sessionStartedAt,
    required DateTime sessionStoppedAt,
    String modelAsset = 'assets/models/female_model.tflite',
  }) async {
    final detectionDir = await _getDetectionDir();
    final safeId = _sanitizeSessionId(sessionId);
    final outFile = File(
      '${detectionDir.path}/hasiltimeline_deteksi_$safeId.json',
    );

    final timelineJson = timeline
        .map(
          (r) => {
            'request_id': r.requestId,
            'start_sec': r.startSec,
            'end_sec': r.endSec,
            'label': r.label.name,
            'label_display': r.label.displayName,
            'confidence': r.confidence,
            'all_probs': r.allProbs,
          },
        )
        .toList();

    final metadata = {
      'app_name': appName,
      'session_id': safeId,
      'generated_at_utc': DateTime.now().toUtc().toIso8601String(),
      'session_started_at_utc': sessionStartedAt.toUtc().toIso8601String(),
      'session_stopped_at_utc': sessionStoppedAt.toUtc().toIso8601String(),
      'recording_file': recordingPath,
      'model_asset': modelAsset,
      'sample_rate': sampleRate,
      'chunk_samples': chunkSamples,
      'stride_ms': strideMs,
      'total_segments': timeline.length,
      'detected_labels': timeline.map((e) => e.label.name).toSet().toList(),
    };

    final finalJsonStr = await compute(
      _performHeavyEncryption,
      EncryptionIsolateData(
        metadata: metadata,
        timelineJson: timelineJson,
        encryptionKey: _encryptionKey,
      ),
    );

    await outFile.writeAsString(finalJsonStr, flush: true);

    return outFile.path;
  }

  String _sanitizeSessionId(String sessionId) {
    final sanitized = sessionId.trim().replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '_',
    );
    return sanitized.isEmpty ? createSessionId() : sanitized;
  }

  // String _normalizeAesKey(String key) {
  //   if (key.length == 16 || key.length == 24 || key.length == 32) {
  //     return key;
  //   }
  //   if (key.length > 32) {
  //     return key.substring(0, 32);
  //   }
  //   return key.padRight(32, '0');
  // }

  Future<Directory> _getRecordingDir() async {
    final appDir = await _getAppDocumentsDir();
    final dir = Directory('${appDir.path}/recording');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _getDetectionDir() async {
    final appDir = await _getAppDocumentsDir();
    final dir = Directory('${appDir.path}/detection');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _getAppDocumentsDir() async {
    await _requestStoragePermissionIfNeeded();

    final baseDir = await _resolveBaseDocumentsDirectory();
    final appDir = Directory('${baseDir.path}/$_documentsFolderName/$appName');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    await _assertWritableDirectory(appDir);

    return appDir;
  }

  Future<Directory> _resolveBaseDocumentsDirectory() async {
    if (!kIsWeb && Platform.isAndroid) {
      final candidates = <String>[
        '/storage/emulated/0/Documents',
        '/sdcard/Documents',
      ];

      for (final path in candidates) {
        final dir = Directory(path);
        try {
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          await _assertWritableDirectory(dir);
          return dir;
        } on FileSystemException {
          continue;
        }
      }

      throw Exception(
        'Folder Documents publik tidak dapat diakses. Pastikan izin storage sudah diberikan.',
      );
    }

    return getApplicationDocumentsDirectory();
  }

  Future<void> _requestStoragePermissionIfNeeded() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    final manageStatus = await Permission.manageExternalStorage.status;
    if (manageStatus.isGranted) {
      return;
    }

    final manageRequested = await Permission.manageExternalStorage.request();
    if (manageRequested.isGranted) {
      return;
    }

    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return;
    }

    final storageRequested = await Permission.storage.request();
    if (!storageRequested.isGranted) {
      throw Exception(
        'Izin storage ditolak. Aktifkan izin file/storage agar bisa menyimpan ke Documents publik.',
      );
    }
  }

  Future<void> _assertWritableDirectory(Directory dir) async {
    final probe = File('${dir.path}/.storage_probe.tmp');
    try {
      await probe.writeAsString('ok', flush: true);
    } on FileSystemException catch (e) {
      throw Exception('Storage tidak dapat ditulis: $e');
    } finally {
      if (await probe.exists()) {
        await probe.delete();
      }
    }
  }

  Uint8List _buildWavHeader(int pcmDataLength) {
    const int numChannels = 1;
    const int bitsPerSample = 16;
    final int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final int blockAlign = numChannels * (bitsPerSample ~/ 8);
    final int riffChunkSize = 36 + pcmDataLength;

    final bytes = ByteData(44);

    bytes.setUint8(0, 0x52);
    bytes.setUint8(1, 0x49);
    bytes.setUint8(2, 0x46);
    bytes.setUint8(3, 0x46);
    bytes.setUint32(4, riffChunkSize, Endian.little);
    bytes.setUint8(8, 0x57);
    bytes.setUint8(9, 0x41);
    bytes.setUint8(10, 0x56);
    bytes.setUint8(11, 0x45);
    bytes.setUint8(12, 0x66);
    bytes.setUint8(13, 0x6d);
    bytes.setUint8(14, 0x74);
    bytes.setUint8(15, 0x20);
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, numChannels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, byteRate, Endian.little);
    bytes.setUint16(32, blockAlign, Endian.little);
    bytes.setUint16(34, bitsPerSample, Endian.little);
    bytes.setUint8(36, 0x64);
    bytes.setUint8(37, 0x61);
    bytes.setUint8(38, 0x74);
    bytes.setUint8(39, 0x61);
    bytes.setUint32(40, pcmDataLength, Endian.little);

    return bytes.buffer.asUint8List();
  }
}

/// Data yang dikirim ke background isolate untuk enkripsi timeline.
///
/// Dipisah sebagai class agar dapat dilewatkan melalui [compute] (harus
/// bisa di-serialize antar isolate).
class EncryptionIsolateData {
  final Map<String, dynamic> metadata;
  final List<Map<String, dynamic>> timelineJson;
  final String encryptionKey;

  EncryptionIsolateData({
    required this.metadata,
    required this.timelineJson,
    required this.encryptionKey,
  });
}

/// Mengenkripsi payload (metadata + timeline) dengan AES-256-CBC dan IV acak.
///
/// Dijalankan pada background isolate agar tidak memblokir UI. Mengembalikan
/// string JSON berisi metadata, info enkripsi (algoritma/encoding/iv), dan
/// ciphertext dalam base64.
String _performHeavyEncryption(EncryptionIsolateData data) {
  final plaintextPayload = jsonEncode({
    'metadata': data.metadata,
    'timeline': data.timelineJson,
  });

  final iv = IV.fromSecureRandom(16);
  final normalizedKey = _normalizeAesKeyStatic(data.encryptionKey);
  final encrypter = Encrypter(
    AES(Key.fromUtf8(normalizedKey), mode: AESMode.cbc),
  );
  final encrypted = encrypter.encrypt(plaintextPayload, iv: iv);

  final encryptedEnvelope = {
    'metadata': data.metadata,
    'encryption': {
      'algorithm': 'AES-256-CBC',
      'encoding': 'base64',
      'iv': iv.base64,
    },
    'ciphertext': encrypted.base64,
  };

  return const JsonEncoder.withIndent('  ').convert(encryptedEnvelope);
}

String _normalizeAesKeyStatic(String key) {
  if (key.length == 16 || key.length == 24 || key.length == 32) {
    return key;
  }
  if (key.length > 32) {
    return key.substring(0, 32);
  }
  return key.padRight(32, '0');
}
