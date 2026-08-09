import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path_util;
import 'package:path_provider/path_provider.dart';

Future<String> persistPickedImagePath(String sourcePath, String fileName) async {
  final appDir = await getApplicationDocumentsDirectory();
  final avatarsDir = Directory('${appDir.path}/avatars');
  if (!await avatarsDir.exists()) {
    await avatarsDir.create(recursive: true);
  }
  final destPath = path_util.join(avatarsDir.path, fileName);
  final destFile = await File(sourcePath).copy(destPath);
  return destFile.path;
}

ImageProvider localImageProvider(String path) {
  return FileImage(File(path));
}

/// Menyalin audio yang dipilih pengguna ke direktori temp aplikasi.
///
/// Pada desktop (dan sebagian platform) `file_picker` mengembalikan path file
/// asli milik pengguna, sedangkan pipeline analisis menghapus
/// `uploadedAudioPath` setelah sesi disimpan. Menyalin dulu memastikan yang
/// terhapus hanya salinan sementara, bukan file asli pengguna.
Future<String> copyPickedAudioToTemp(String sourcePath, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final uploadsDir = Directory(path_util.join(tempDir.path, 'uploads'));
  if (!await uploadsDir.exists()) {
    await uploadsDir.create(recursive: true);
  }
  final destPath = path_util.join(
    uploadsDir.path,
    '${DateTime.now().millisecondsSinceEpoch}_$fileName',
  );
  final destFile = await File(sourcePath).copy(destPath);
  return destFile.path;
}

Future<void> deleteLocalPath(String? path) async {
  if (path == null || path.trim().isEmpty) return;
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {}
}
