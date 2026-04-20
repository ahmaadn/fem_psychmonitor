import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Brand Colors ---
  static const Color primary = Color(0xFF1B6B51);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF78C2A4);

  // "Gradient Soul" base colors
  static const Color primaryFixed = Color(0xFFA6F2D2);
  static const Color tertiaryContainer = Color(0xFFC5A5F1);

  // Chips / Selection
  static const Color tertiaryFixed = Color(0xFFEDDCFF);

  // Secondary / Actions
  static const Color secondary = Color(0xFFFED172);
  static const Color secondaryContainer = Color(0xFFFED172);
  static const Color secondaryFixed = Color(0xFFFFDF9F);
  static const Color onSecondaryFixed = Color(0xFF261A00);

  // --- Background & Surface (Stacked Silk / Sanctuary Vibe) ---
  /// Base Layer
  static const Color background = Color(0xFFF9F9F9);

  /// The Canvas
  static const Color surface = Color(0xFFF9F9F9);

  /// Secondary Content
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);

  /// Floating Cards / Pop
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  /// Deep Context (Modals)
  static const Color surfaceDim = Color(0xFFDADADA);

  /// Text Fields
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);

  // Text & Icon Colors
  static const Color onSurface = Color(0xFF1A1C1C);

  /// Untuk fine-line icons
  static const Color onSurfaceVariant = Color(0xFF1A1C1C);
  static const Color onBackground = Color(0xFF1A1C1C);

  // Success
  // Indikator progres positif, keberhasilan upload.
  static const Color success = Color(0xFF8BA888);
  static const Color successSurface = Color(0xFFE8EFE8);

  // Info
  // Informasi tambahan atau bantuan.
  static const Color info = Color(0xFFAEC6CF);
  static const Color infoSurface = Color(0xFFEEF3F5);

  // Error/Warning
  // Peringatan atau emosi negatif yang kuat.
  static const Color warning = Color(0xFFD67D7D);
  static const Color warningSurface = Color(0xFFF8EFEF);

  // Border / Outline
  // The "Ghost Border" (Gunakan dengan opacity 15% pada UI)
  static const Color outline = Color(0xFFBEC9C2);
  static const Color outlineVariant = Color(0xFFBEC9C2);

  // Ambient Shadow: 6% opacity dari on_surface (#1A1C1C)
  static const Color shadow = Color(0x0F1A1C1C);

  static ColorScheme colorScheme = const ColorScheme.light(
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    secondary: secondary,
    onSecondary: onSurface,
    secondaryContainer: secondaryContainer,
    surface: surface,
    onSurface: onSurface,
    error: warning, // Menggunakan Muted Coral untuk error
    onError: Colors.white,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: shadow,
  );
}
