import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Raster emotion emoji.
///
/// The source assets under `assets/emoji/` are 562×632 px (~370 KB each), but
/// they are almost always rendered between 14dp and 76dp. Without an explicit
/// decode size Flutter keeps the full-resolution bitmap in the image cache —
/// roughly 1.4 MB of RGBA per emoji — and the Discover calendar alone mounts
/// hundreds of these tiles, which is what makes that list stutter while
/// scrolling.
///
/// [cacheWidth]/[cacheHeight] make the decoder downsample to the size actually
/// painted, so each distinct render size costs a few KB instead of megabytes.
class EmotionEmoji extends StatelessWidget {
  final String asset;
  final double size;
  final BoxFit fit;

  const EmotionEmoji({
    super.key,
    required this.asset,
    this.size = 24,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final side = size.w;
    // Decode at physical-pixel size so the bitmap stays sharp on high-DPI
    // screens without holding the full 562×632 source in the cache.
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    final decodeSide = (side * dpr).round().clamp(1, 632);

    return Image.asset(
      asset,
      width: side,
      height: side,
      fit: fit,
      cacheWidth: decodeSide,
      cacheHeight: decodeSide,
      filterQuality: FilterQuality.medium,
    );
  }
}