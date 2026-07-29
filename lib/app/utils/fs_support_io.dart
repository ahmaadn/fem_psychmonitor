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

Future<void> deleteLocalPath(String? path) async {
  if (path == null || path.trim().isEmpty) return;
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {}
}
