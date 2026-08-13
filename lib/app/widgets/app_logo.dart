import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final BoxFit fit;
  final Color? tint;

  const AppLogo({
    super.key,
    this.size = 120,
    this.fit = BoxFit.contain,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: size.w,
      height: size.w,
      fit: fit,
      color: tint,
      filterQuality: FilterQuality.medium,
    );
  }
}