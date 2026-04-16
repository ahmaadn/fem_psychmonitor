import 'package:flutter/material.dart';

class PulseThemeExtension extends ThemeExtension<PulseThemeExtension> {
  final LinearGradient primaryGradient;
  final BoxShadow ambientShadow;

  PulseThemeExtension({
    required this.primaryGradient,
    required this.ambientShadow,
  });

  @override
  ThemeExtension<PulseThemeExtension> copyWith() => this;

  @override
  ThemeExtension<PulseThemeExtension> lerp(
    ThemeExtension<PulseThemeExtension>? other,
    double t,
  ) {
    return this;
  }

  // Helper untuk akses cepat
  static PulseThemeExtension of(BuildContext context) =>
      Theme.of(context).extension<PulseThemeExtension>()!;
}
