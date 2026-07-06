import 'package:flutter/material.dart';

/// Aura Echo — warm-cream design tokens.
///
/// The palette is anchored on a cream-tinted canvas (US-21 "soft, calming")
/// with a sage primary and a clay/peach secondary. Every hex below is
/// intentionally warm-tinted rather than cool-neutral so the app reads as
/// a safe, journal-like space for voice emotion journaling — never the
/// cool-gray SaaS default.
class AppColors {
  AppColors._();

  // --- Brand (sage primary + clay secondary, both warm-tinted) ---
  /// Sage — pine/spanish green softened. Calm primary CTA.
  static const Color primary = Color(0xFF6FAE93);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFBFDDD0);
  static const Color primaryFixed = Color(0xFFD9ECE1);

  /// Chips / Selection (soft dusty-rose, the calm alternative to light blue)
  static const Color tertiary = Color(0xFFB58AAE);
  static const Color tertiaryFixed = Color(0xFFEEDFEC);
  static const Color tertiaryContainer = Color(0xFFDCC3D6);

  /// Secondary / Actions (clay-peach)
  static const Color secondary = Color(0xFFE8A085);
  static const Color secondaryContainer = Color(0xFFE8A085);
  static const Color secondaryFixed = Color(0xFFF6D8C8);
  static const Color onSecondaryFixed = Color(0xFF5C2A1A);

  // --- Surfaces (warm cream, never cool gray) ---
  /// Canvas — the warm cream floor.
  static const Color background = Color(0xFFFFF9F2);

  /// The Canvas — pure white cards on the cream floor.
  static const Color surface = Color(0xFFFFFDFA);

  /// Secondary Content — soft cream.
  static const Color surfaceContainerLow = Color(0xFFFBF3E8);

  /// Floating Cards / Pop — same as surface (white over cream).
  static const Color surfaceContainerLowest = Color(0xFFFFFDFA);

  /// Deep Context (Modals) — stronger cream.
  static const Color surfaceDim = Color(0xFFF1E7D6);

  /// Text Fields — warm fill.
  static const Color surfaceContainerHighest = Color(0xFFF5EDDD);

  /// Input fields — warm fill for text inputs.
  static const Color inputFill = Color(0xFFF5EDDD);

  // --- Text (warm near-black, never pure neutral) ---
  static const Color textPrimary = Color(0xFF2A2622);
  static const Color textSecondary = Color(0xFF6A5F55);
  static const Color textPrimaryInverse = Color(0xFFF7F1E6);
  static const Color onSurface = textPrimary;

  /// Fine-line icons / captions.
  static const Color onSurfaceVariant = textSecondary;
  static const Color onBackground = textPrimary;

  // --- Semantic (kept warm to sit on cream) ---
  static const Color success = Color(0xFF4F9A78);
  static const Color successSurface = Color(0xFFDCEFE3);

  static const Color info = Color(0xFF5B7FB0);
  static const Color infoSurface = Color(0xFFE2EAF3);

  static const Color warning = Color(0xFFC9655B);
  static const Color warningSurface = Color(0xFFF6E1DD);

  // --- Borders (warm hairline, not cool gray) ---
  static const Color outline = Color(0xFFE2D8C7);
  static const Color outlineVariant = Color(0xFFE2D8C7);

  /// Ambient shadow — 6% warm-black.
  static const Color shadow = Color(0x0F2A2622);

  // --- Emotion Colors (each slightly warmed; surfaces are cream-tinted) ---
  // 1. Marah (Anger)
  static const Color emotionAnger = Color(0xFFC9655B);
  static const Color emotionAngerSurface = Color(0xFFF6E1DD);
  static const Color onEmotionAnger = Color(0xFFFFFFFF);

  // 2. Sedih (Sadness)
  static const Color emotionSadness = Color(0xFF5B7FB0);
  static const Color emotionSadnessSurface = Color(0xFFE2EAF3);
  static const Color onEmotionSadness = Color(0xFFFFFFFF);

  // 3. Bahagia (Happiness)
  static const Color emotionHappiness = Color(0xFFE0A24A);
  static const Color emotionHappinessSurface = Color(0xFFF9EAD2);
  static const Color onEmotionHappiness = Color(0xFFFFFFFF);

  // 4. Jijik (Disgust)
  static const Color emotionDisgust = Color(0xFF5A9E83);
  static const Color emotionDisgustSurface = Color(0xFFDDEFE6);
  static const Color onEmotionDisgust = Color(0xFFFFFFFF);

  // 5. Takut (Fear)
  static const Color emotionFear = Color(0xFF8C76B8);
  static const Color emotionFearSurface = Color(0xFFECE5F2);
  static const Color onEmotionFear = Color(0xFFFFFFFF);

  // 6. Netral (Neutral)
  static const Color emotionNetral = Color(0xFF7A6F62);
  static const Color emotionNetralSurface = Color(0xFFEDE6DA);
  static const Color onEmotionNetral = Color(0xFFFFFFFF);

  static ColorScheme colorScheme = const ColorScheme.light(
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    secondary: secondary,
    onSecondary: onSurface,
    secondaryContainer: secondaryContainer,
    surface: surface,
    onSurface: onSurface,
    error: warning,
    onError: Colors.white,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: shadow,
  );
}
