import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Brand Colors ---
  static const Color primary = Color(0xFF1B6B51);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF78C2A4);
  static const Color primaryFixed = Color(0xFFA6F2D2);

  // Chips / Selection
  static const Color tertiary = Color(0xFF6D5096);
  static const Color tertiaryFixed = Color(0xFFEDDCFF);
  static const Color tertiaryContainer = Color(0xFFC5A5F1);

  // Secondary / Actions
  static const Color secondary = Color(0xFFFED172);
  static const Color secondaryContainer = Color(0xFFFED172);
  static const Color secondaryFixed = Color(0xFFFFDF9F);
  static const Color onSecondaryFixed = Color(0xFF261A00);

  // --- Background & Surface (Stacked Silk / Sanctuary Vibe) ---
  /// Base Layer
  static const Color background = Color(0xFFF7F8FA);

  /// The Canvas
  static const Color surface = Color(0xFFFFFFFF);

  /// Secondary Content
  static const Color surfaceContainerLow = Color(0xFFF7F8FA);

  /// Floating Cards / Pop
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  /// Deep Context (Modals)
  static const Color surfaceDim = Color(0xFFEAEAEA);

  /// Text Fields
  static const Color surfaceContainerHighest = Color(0xFFF3F3F3);

  /// Input fields
  static const Color inputFill = Color(0xFFF3F3F3);

  // Text & Icon Colors
  static const Color textPrimary = Color(0xFF1A1C1C);
  static const Color textSecondary = Color(0xFF212529);
  static const Color textPrimaryInverse = Color(0xFFEAEAEA);
  static const Color onSurface = textPrimary;

  /// Untuk fine-line icons
  static const Color onSurfaceVariant = textSecondary;
  static const Color onBackground = textPrimary;

  // Success
  // Indikator progres positif, keberhasilan upload.
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successSurface = Color(0xFFD1FAE5); // Emerald 100

  // Info
  // Informasi tambahan atau bantuan.
  static const Color info = Color(0xFF2563EB); // Blue 600
  static const Color infoSurface = Color(0xFFDBEAFE); // Blue 100

  // Error/Warning
  // Peringatan atau emosi negatif yang kuat.
  static const Color warning = Color(0xFFDC2626); // Red 600
  static const Color warningSurface = Color(0xFFFEE2E2); // Red 100

  // Border / Outline
  // The "Ghost Border" (Gunakan dengan opacity 15% pada UI)
  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Ambient Shadow: 6% opacity dari on_surface (#1A1C1C)
  static const Color shadow = Color(0x0F1A1C1C);

  // --- Emotion Colors ---
  // 1. Marah (Anger)
  static const Color emotionAnger = warning; // Red 600
  static const Color emotionAngerSurface = warningSurface;
  static const Color onEmotionAnger = Color(0xFFFFFFFF); // Teks Putih

  // 2. Sedih (Sadness)
  static const Color emotionSadness = info; // Blue 600
  static const Color emotionSadnessSurface = infoSurface;
  static const Color onEmotionSadness = Color(0xFFFFFFFF); // Teks Putih

  // 3. Bahagia (Happiness)
  static const Color emotionHappiness = Color(0xFFF59E0B); // Amber 500
  static const Color emotionHappinessSurface = Color(0xFFFEF3C7); // Amber 100
  static const Color onEmotionHappiness = Color(0xFFFFFFFF); // Teks Putih

  // 4. Jijik (Disgust)
  static const Color emotionDisgust = success; // Emerald 600
  static const Color emotionDisgustSurface = successSurface;
  static const Color onEmotionDisgust = Color(0xFFFFFFFF); // Teks Putih

  // 5. Takut (Fear)
  static const Color emotionFear = Color(0xFF7C3AED); // Violet 600
  static const Color emotionFearSurface = Color(0xFFEDE9FE); // Violet 100
  static const Color onEmotionFear = Color(0xFFFFFFFF); // Teks Putih

  // 6. Netral (Neutral)
  static const Color emotionNetral = Color(0xFF475569); // Slate 600
  static const Color emotionNetralSurface = Color(0xFFF1F5F9); // Slate 100
  static const Color onEmotionNetral = Color(0xFFFFFFFF); // Teks Putih

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
