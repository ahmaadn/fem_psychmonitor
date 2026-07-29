import 'package:flutter/material.dart';

/// Static token table for Strawberry Match (DESIGN.md §2).
/// Theme-aware chrome: use [AppPalette] via `context.palette`.
class AppColors {
  AppColors._();

  // ── Primary ramp — Strawberry Rose seed #C66F80 ─────────────────────
  static const Color primary50 = Color(0xFFFCF6F7);
  static const Color primary100 = Color(0xFFF6E9EC);
  static const Color primary200 = Color(0xFFEDD1D6);
  static const Color primary300 = Color(0xFFE2B7C0);
  static const Color primary400 = Color(0xFFD697A4);
  static const Color primary500 = Color(0xFFC66F80);
  static const Color primary600 = Color(0xFFA25B69);
  static const Color primary700 = Color(0xFF7F4752);
  static const Color primary800 = Color(0xFF59323A);
  static const Color primary900 = Color(0xFF371F24);

  // ── Secondary ramp — Matcha Green seed #4A6644 ──────────────────────
  static const Color secondary50 = Color(0xFFF4F6F4);
  static const Color secondary100 = Color(0xFFE4E8E3);
  static const Color secondary200 = Color(0xFFC5CEC3);
  static const Color secondary300 = Color(0xFFA4B2A2);
  static const Color secondary400 = Color(0xFF7D9178);
  static const Color secondary500 = Color(0xFF4A6644);
  static const Color secondary600 = Color(0xFF3D5438);
  static const Color secondary700 = Color(0xFF2F412C);
  static const Color secondary800 = Color(0xFF212E1F);
  static const Color secondary900 = Color(0xFF151D13);

  // ── Light surfaces ──────────────────────────────────────────────────
  static const Color canvasLight = Color(0xFFFDF9F6);
  static const Color surfaceLight1 = Color(0xFFF7F1EE);
  static const Color surfaceLight2 = Color(0xFFF1E8E4);
  static const Color surfaceLight3 = Color(0xFFEAD9D3);
  static const Color dividerLight = Color(0xFFE6D5CF);

  // ── Dark surfaces ───────────────────────────────────────────────────
  static const Color canvasDark = Color(0xFF1C1614);
  static const Color surfaceDark1 = Color(0xFF241C1A);
  static const Color surfaceDark2 = Color(0xFF2E2422);
  static const Color surfaceDark3 = Color(0xFF3A2E2B);
  static const Color dividerDark = Color(0xFF453733);

  // ── Text ────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF2B211F);
  static const Color textSecondaryLight = Color(0xFF6B5854);
  static const Color textTertiaryLight = Color(0xFF9C8983);
  static const Color textPrimaryDark = Color(0xFFF7EDE9);
  static const Color textSecondaryDark = Color(0xFFC9B6B0);
  static const Color textTertiaryDark = Color(0xFF94807A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── Semantics ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF3C8B54);
  static const Color successOnLight = Color(0xFF2C6A3F);
  static const Color successOnDark = Color(0xFF6BB37D);
  static const Color warning = Color(0xFFC98A2E);
  static const Color warningOnLight = Color(0xFF8F6420);
  static const Color warningOnDark = Color(0xFFE3AB57);
  static const Color error = Color(0xFFC24B4B);
  static const Color errorOnLight = Color(0xFF9C3838);
  static const Color errorOnDark = Color(0xFFE08282);
  static const Color info = Color(0xFF4A78A6);
  static const Color infoOnLight = Color(0xFF385F84);
  static const Color infoOnDark = Color(0xFF7FA6C6);

  // ── Emotion base + text-safe (DESIGN.md §2.6) ───────────────────────
  static const Color emotionHappy = Color(0xFFE8A23C);
  static const Color emotionSad = Color(0xFF5C7FA6);
  static const Color emotionAnger = Color(0xFFD1483D);
  static const Color emotionFearful = Color(0xFF8B6FB0);
  static const Color emotionDisgust = Color(0xFF8C9A4A);
  static const Color emotionNeutral = Color(0xFF9C8F86);

  static const Color emotionHappyOnLight = Color(0xFF976927);
  static const Color emotionSadOnLight = Color(0xFF3F5A7A);
  static const Color emotionAngerOnLight = Color(0xFFA5382F);
  static const Color emotionFearfulOnLight = Color(0xFF6B5488);
  static const Color emotionDisgustOnLight = Color(0xFF697438);
  static const Color emotionNeutralOnLight = Color(0xFF756B64);

  static const Color emotionHappyOnDark = Color(0xFFF0BC70);
  static const Color emotionSadOnDark = Color(0xFF8FAAC7);
  static const Color emotionAngerOnDark = Color(0xFFE37A70);
  static const Color emotionFearfulOnDark = Color(0xFFB39ECF);
  static const Color emotionDisgustOnDark = Color(0xFFB0BE73);
  static const Color emotionNeutralOnDark = Color(0xFFBFB2AA);
}
