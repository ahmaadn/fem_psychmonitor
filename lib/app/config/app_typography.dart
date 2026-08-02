import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter type scale (DESIGN.md §3). Design sizes on 390×844 canvas.
class AppTypography {
  AppTypography._();

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    double height = 1.4,
    double letterSpacing = 0,
    Color? color,
    FontFeature? feature,
    bool scale = false,
  }) {
    final fontSize = scale ? size.sp : size;
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontFeatures: feature != null ? [feature] : null,
    );
  }

  static TextStyle get display => _inter(
    size: 28,
    weight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle get title => _inter(
    size: 22,
    weight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
  );

  static TextStyle get subtitle =>
      _inter(size: 18, weight: FontWeight.w600, height: 1.3);

  static TextStyle get bodyStrong =>
      _inter(size: 15, weight: FontWeight.w600, height: 1.4);

  static TextStyle get body =>
      _inter(size: 15, weight: FontWeight.w400, height: 1.5);

  static TextStyle get caption => _inter(
    size: 13,
    weight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.1,
  );

  static TextStyle get label => _inter(
    size: 12,
    weight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.4,
  );

  static TextStyle get metric => _inter(
    size: 32,
    weight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
    feature: const FontFeature.tabularFigures(),
  );

  static TextStyle get button => _inter(
    size: 15,
    weight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.1,
  );

  /// Badge — streak / "Recording" (DESIGN.md §3).
  static TextStyle get badge => _inter(
    size: 10,
    weight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.5,
  );

  /// Tab label — bottom nav (DESIGN.md §3).
  static TextStyle get tabLabel => _inter(
    size: 11,
    weight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.1,
  );

  /// Dense chart / axis labels (derived from label).
  static TextStyle get micro => _inter(
    size: 10,
    weight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.2,
  );

  /// Emoji glyph sizes (not freelanced per screen).
  static TextStyle get emojiSm =>
      _inter(size: 14, weight: FontWeight.w400, height: 1.0);
  static TextStyle get emojiMd =>
      _inter(size: 18, weight: FontWeight.w400, height: 1.0);
  static TextStyle get emojiLg =>
      _inter(size: 22, weight: FontWeight.w400, height: 1.0);
  static TextStyle get emojiXl =>
      _inter(size: 32, weight: FontWeight.w400, height: 1.0);
  static TextStyle get emojiHero =>
      _inter(size: 40, weight: FontWeight.w400, height: 1.0);

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: display,
      displayMedium: display,
      displaySmall: title,
      headlineLarge: title,
      headlineMedium: subtitle,
      headlineSmall: bodyStrong,
      titleLarge: title,
      titleMedium: subtitle,
      titleSmall: bodyStrong,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: button,
      labelMedium: label,
      labelSmall: label,
    );
  }
}
