import 'package:flutter/widgets.dart';

/// Web: keep picker path (blob URL); no filesystem copy.
Future<String> persistPickedImagePath(String sourcePath, String fileName) async {
  return sourcePath;
}

/// Web: tidak ada filesystem — path picker dipakai apa adanya (SER tetap
/// tidak tersedia di web).
Future<String> copyPickedAudioToTemp(String sourcePath, String fileName) async {
  return sourcePath;
}

/// Web: blob / http paths load via [NetworkImage].
ImageProvider localImageProvider(String path) {
  return NetworkImage(path);
}

Future<void> deleteLocalPath(String? path) async {
  // No-op on web.
}
