import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Image.asset(
      asset,
      width: size.w,
      height: size.w,
      fit: fit,
      filterQuality: FilterQuality.medium,
    );
  }
}
