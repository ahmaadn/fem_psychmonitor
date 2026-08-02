import 'package:flutter/material.dart';

/// Static token table for Strawberry Match (DESIGN.md §2).
/// Theme-aware chrome: use [AppPalette] via `context.palette`.
class AppColors {
  AppColors._();

  // ── Primary ramp — Cherry seed #B4182D ───────────────────────────────
  static const Color primary50 = Color(0xFFFCE8EB);
  static const Color primary100 = Color(0xFFF9D2D7);
  static const Color primary200 = Color(0xFFF4AEB7);
  static const Color primary300 = Color(0xFFEE8190);
  static const Color primary400 = Color(0xFFE64258);
  static const Color primary500 = Color(0xFFB4182D);
  static const Color primary600 = Color(0xFF901324);
  static const Color primary700 = Color(0xFF710F1C);
  static const Color primary800 = Color(0xFF510B14);
  static const Color primary900 = Color(0xFF36070E);

  // ── Secondary ramp — Jade seed #25B15F ───────────────────────────────
  static const Color secondary50 = Color(0xFFEAFBF1);
  static const Color secondary100 = Color(0xFFCDF4DD);
  static const Color secondary200 = Color(0xFFA2EBC1);
  static const Color secondary300 = Color(0xFF70E19F);
  static const Color secondary400 = Color(0xFF3DD67D);
  static const Color secondary500 = Color(0xFF25B15F);
  static const Color secondary600 = Color(0xFF1D8B4B);
  static const Color secondary700 = Color(0xFF166939);
  static const Color secondary800 = Color(0xFF104C29);
  static const Color secondary900 = Color(0xFF0B321B);

  // ── Light surfaces ──────────────────────────────────────────────────
  static const Color canvasLight = Color(0xFFFFF7F8);
  static const Color surfaceLight1 = Color(0xFFFDEEF0);
  static const Color surfaceLight2 = Color(0xFFFBE3E6);
  static const Color surfaceLight3 = Color(0xFFF6D0D5);
  static const Color dividerLight = Color(0xFFF2C2C8);

  // ── Dark surfaces ───────────────────────────────────────────────────
  static const Color canvasDark = Color(0xFF1A0C0F);
  static const Color surfaceDark1 = Color(0xFF24141A);
  static const Color surfaceDark2 = Color(0xFF301B22);
  static const Color surfaceDark3 = Color(0xFF3D242C);
  static const Color dividerDark = Color(0xFF4A2E36);

  // ── Text ────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF2B0E12);
  static const Color textSecondaryLight = Color(0xFF6E3A40);
  static const Color textTertiaryLight = Color(0xFFA17178);
  static const Color textPrimaryDark = Color(0xFFF9E9EA);
  static const Color textSecondaryDark = Color(0xFFD6BCC0);
  static const Color textTertiaryDark = Color(0xFFA8878C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF1A0C0F);

  // ── Semantics ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF1FAD9A);
  static const Color successOnLight = Color(0xFF147064);
  static const Color successOnDark = Color(0xFF41B9A9);
  static const Color warning = Color(0xFFF29A18);
  static const Color warningOnLight = Color(0xFF9D6410);
  static const Color warningOnDark = Color(0xFFF4A93B);
  static const Color error = Color(0xFFE04343);
  static const Color errorOnLight = Color(0xFFBE3939);
  static const Color errorOnDark = Color(0xFFE55F5F);
  static const Color info = Color(0xFF3A82C9);
  static const Color infoOnLight = Color(0xFF316EAB);
  static const Color infoOnDark = Color(0xFF5895D1);

  // ── Emotion base + text-safe (DESIGN.md §2.6) ───────────────────────
  static const Color emotionHappy = Color(0xFFFFB03C);
  static const Color emotionSad = Color(0xFF5388C4);
  static const Color emotionAnger = Color(0xFFF46325);
  static const Color emotionFearful = Color(0xFF946ACC);
  static const Color emotionDisgust = Color(0xFFA9C234);
  static const Color emotionNeutral = Color(0xFFB09989);

  static const Color emotionHappyOnLight = Color(0xFF8C6121);
  static const Color emotionSadOnLight = Color(0xFF4774A7);
  static const Color emotionAngerOnLight = Color(0xFFB74A1C);
  static const Color emotionFearfulOnLight = Color(0xFF7E5AAD);
  static const Color emotionDisgustOnLight = Color(0xFF5D6B1D);
  static const Color emotionNeutralOnLight = Color(0xFF726359);

  static const Color emotionHappyOnDark = Color(0xFFFFBC59);
  static const Color emotionSadOnDark = Color(0xFF6D9ACD);
  static const Color emotionAngerOnDark = Color(0xFFF67A46);
  static const Color emotionFearfulOnDark = Color(0xFFA480D4);
  static const Color emotionDisgustOnDark = Color(0xFFB6CB52);
  static const Color emotionNeutralOnDark = Color(0xFFBCA89B);
}
