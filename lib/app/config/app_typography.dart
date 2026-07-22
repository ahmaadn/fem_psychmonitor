import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central Inter type scale. Do not hardcode fontSize/weight in widgets.
///
/// Color hierarchy (apply via AppPalette):
/// - Display / bodyStrong → `p.ink` (primary text, WCAG AA)
/// - body / caption → `p.ink` or default theme onSurface
/// - Supporting / meta → `p.inkMuted`
/// - Placeholder / legal → `p.inkFaint`
/// - Brand emphasis → `p.primary` / `p.primaryFocus`
class AppTypography {
  AppTypography._();

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    double height = 1.4,
    double letterSpacing = -0.2,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle get heroDisplay => _inter(
        size: 40,
        weight: FontWeight.w600,
        height: 1.08,
        letterSpacing: -0.4,
      );

  static TextStyle get displayLg => _inter(
        size: 28,
        weight: FontWeight.w600,
        height: 1.12,
        letterSpacing: -0.3,
      );

  static TextStyle get displayMd => _inter(
        size: 24,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.25,
      );

  static TextStyle get lead => _inter(
        size: 18,
        weight: FontWeight.w400,
        height: 1.3,
      );

  static TextStyle get leadAiry => _inter(
        size: 16,
        weight: FontWeight.w300,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get tagline => _inter(
        size: 16,
        weight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle get bodyStrong => _inter(
        size: 15,
        weight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get body => _inter(
        size: 15,
        weight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get denseLink => _inter(
        size: 14,
        weight: FontWeight.w400,
        height: 1.8,
        letterSpacing: 0,
      );

  static TextStyle get caption => _inter(
        size: 12,
        weight: FontWeight.w400,
        height: 1.35,
      );

  static TextStyle get captionStrong => _inter(
        size: 12,
        weight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get buttonLarge => _inter(
        size: 15,
        weight: FontWeight.w400,
        height: 1.0,
        letterSpacing: 0,
      );

  static TextStyle get buttonUtility => _inter(
        size: 12,
        weight: FontWeight.w400,
        height: 1.25,
      );

  static TextStyle get finePrint => _inter(
        size: 11,
        weight: FontWeight.w400,
        height: 1.2,
      );

  static TextStyle get microLegal => _inter(
        size: 10,
        weight: FontWeight.w400,
        height: 1.25,
      );

  static TextStyle get navLink => _inter(
        size: 11,
        weight: FontWeight.w500,
        height: 1.0,
        letterSpacing: 0,
      );

  static TextStyle get display => displayLg;
  static TextStyle get h1 => displayMd;
  static TextStyle get h2 => tagline;
  static TextStyle get bodyLg => body;
  static TextStyle get bodyMd => caption;
  static TextStyle get bodySm => finePrint;
  static TextStyle get label => captionStrong;
  static TextStyle get xs => microLegal;

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: heroDisplay,
      displayMedium: displayLg,
      displaySmall: displayMd,
      headlineLarge: displayLg,
      headlineMedium: tagline,
      headlineSmall: bodyStrong,
      bodyLarge: body,
      bodyMedium: caption,
      bodySmall: finePrint,
      labelLarge: bodyStrong,
      labelMedium: captionStrong,
      labelSmall: navLink,
    );
  }
}
