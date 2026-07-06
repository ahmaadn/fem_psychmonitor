import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Aura Echo typography.
///
/// The personality carrier is **Fraunces** — a characterful modern serif with
/// optical sizing and a soft, slightly-oldstyle feel. It turns the headlines
/// into a "journal you speak into" rather than a neutral UI delivery vehicle,
/// and it never goes to a heavier weight than the face carries at 600 — the
/// warmth comes from the letterforms, not the weight.
///
/// Body, UI, buttons, and labels run on **Inter** — neutral, high-function
/// grotesk that lets the serif carry the personality.
class AppTypography {
  /// **Display (32px, SemiBold, Fraunces)** — hero metrics, splash titles.
  static TextStyle get display => GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        height: 1.05,
        color: AppColors.textPrimary,
      );

  /// **H1 (32px, SemiBold, Fraunces)** — screen-level headlines.
  static TextStyle get h1 => GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        height: 1.1,
        color: AppColors.textPrimary,
      );

  /// **H2 (18px, SemiBold, Inter)** — section / card titles.
  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  /// **Body Large (16px, Regular, Inter)** — intro paragraphs, companion voice.
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.textPrimary,
      );

  /// **Body Medium (14px, Regular, Inter)** — default running text, labels.
  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.textPrimary,
      );

  /// **Body Small (12px, Regular, Inter)** — captions, metadata.
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  /// **Label (12px, SemiBold, Inter)** — chips, micro-copy.
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// **Extra Small (10px, SemiBold, Inter)** — axis labels, bottom nav.
  static TextStyle get xs => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      );

  /// Material TextTheme mapping so legacy Material components pick the tokens.
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: display,
      headlineLarge: h1,
      headlineMedium: h2,
      bodyLarge: bodyLg,
      bodyMedium: bodyMd,
      bodySmall: bodySm,
      labelLarge: label,
      labelSmall: xs,
    );
  }

  // ── Fraunces convenience helpers (used by the new UI) ────────────────
  /// Large serif display reused for big hero scores / result emotions.
  static TextStyle fraunces({
    double size = 32,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double spacing = -0.6,
    double height = 1.05,
  }) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: height,
        color: color ?? AppColors.textPrimary,
      );
}
