import 'package:flutter/material.dart';

/// Brand + tonal system derived from color theory.
///
/// Harmony: split-complementary (rose ~349° ↔ matcha ~110°).
/// Distribution: 60% neutrals / 30% soft brand surfaces / 10% accents.
/// Primary: #C66F80 · Secondary: #4A6644
///
/// For UI chrome that flips with light/dark, use [AppPalette] via context.
class AppColors {
  AppColors._();

  // ── Brand duo (10% accents) ──────────────────────────────────────────
  static const Color primary = Color(0xFFC66F80); // Strawberry Rose
  static const Color primaryFocus = Color(0xFFA85568); // pressed / focus
  static const Color primaryDeep = Color(0xFF8F4456); // strong emphasis
  static const Color primarySoft = Color(0xFFE8A3B0); // on dark
  static const Color secondary = Color(0xFF4A6644); // Matcha Green
  static const Color secondaryFocus = Color(0xFF3A5236);
  static const Color secondaryDeep = Color(0xFF2E412B);
  static const Color secondarySoft = Color(0xFF9FAA74); // on dark / mid

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ── Light neutrals (60% canvas / ink) ─────────────────────────────────
  // Warm parchment with rose undertone — more luminous than flat beige.
  static const Color lightCanvas = Color(0xFFF4EBE3);
  static const Color lightSurface = Color(0xFFFFFCFB); // pearl
  static const Color lightSurfaceHigh = Color(0xFFFFF5F7); // elevated
  static const Color lightStrawberry = Color(0xFFF5D0D8); // 30% brand tint
  static const Color lightStrawberryMilk = Color(0xFFFDF0F4);
  static const Color lightMatcha = Color(0xFFE2E6C8);
  static const Color lightMatchaSoft = Color(0xFFF0F3E6);
  // Ink hierarchy targets WCAG AA on warm cream (≥4.5:1 body).
  static const Color lightInk = Color(0xFF1F1816);
  static const Color lightInkMuted = Color(0xFF5C4A45);
  static const Color lightInkFaint = Color(0xFF8B7A74);
  static const Color lightHairline = Color(0xFFE5D9CF);
  static const Color lightBorder = Color(0xFFEDE4DB);

  // ── Dark neutrals (60%) ──────────────────────────────────────────────
  // Deep matcha-cocoa with cool-green bias for calm night reading.
  static const Color darkCanvas = Color(0xFF121814);
  static const Color darkSurface = Color(0xFF1C2420);
  static const Color darkSurfaceHigh = Color(0xFF28312C);
  static const Color darkStrawberry = Color(0xFF4A2C33);
  static const Color darkMatcha = Color(0xFF2F422C);
  static const Color darkInk = Color(0xFFFFF8F5);
  static const Color darkInkMuted = Color(0xFFD4C2BC);
  static const Color darkInkFaint = Color(0xFF8F7E79);
  static const Color darkHairline = Color(0xFF35403A);
  static const Color darkBorder = Color(0xFF2A332E);

  // ── Emotion (stable across themes, hue-wheel spaced) ─────────────────
  static const Color emotionAnger = Color(0xFFC66F80);
  static const Color emotionAngerSurface = Color(0xFFF5D0D8);
  static const Color emotionSadness = Color(0xFF6B8FB8);
  static const Color emotionSadnessSurface = Color(0xFFE6F0F8);
  static const Color emotionHappiness = Color(0xFF9FAA74);
  static const Color emotionHappinessSurface = Color(0xFFF0F3E6);
  static const Color emotionDisgust = Color(0xFF4A6644);
  static const Color emotionDisgustSurface = Color(0xFFE8EEDC);
  static const Color emotionFear = Color(0xFFA890C4);
  static const Color emotionFearSurface = Color(0xFFF3EBF8);
  static const Color emotionNetral = Color(0xFF8B7A74);
  static const Color emotionNetralSurface = Color(0xFFF4EBE3);

  static const Color info = Color(0xFF6B8FB8);
  static const Color infoSurface = Color(0xFFE6F0F8);

  // ── Legacy aliases (prefer AppPalette / context.palette) ─────────────
  static const Color primaryOnDark = primarySoft;
  static const Color secondaryOnDark = secondarySoft;
  static const Color secondaryFocusLegacy = secondaryFocus;
  static const Color onDark = white;
  static const Color ink = lightInk;
  static const Color body = lightInk;
  static const Color bodyOnDark = darkInk;
  static const Color bodyMuted = darkInkMuted;
  static const Color inkMuted80 = lightInkMuted;
  static const Color inkMuted48 = lightInkFaint;
  static const Color canvas = lightCanvas;
  static const Color canvasParchment = lightStrawberry;
  static const Color surfacePearl = lightSurface;
  static const Color strawberryBlush = lightStrawberry;
  static const Color strawberryMilk = lightStrawberryMilk;
  static const Color warmCream = lightCanvas;
  static const Color matchaMist = lightMatcha;
  static const Color softMatcha = secondarySoft;
  static const Color surfaceTile1 = darkCanvas;
  static const Color surfaceTile2 = darkSurface;
  static const Color surfaceTile3 = darkSurfaceHigh;
  static const Color surfaceBlack = black;
  static const Color surfaceChipTranslucent = lightStrawberry;
  static const Color dividerSoft = lightStrawberry;
  static const Color hairline = lightHairline;
  static const Color borderSubtle = lightBorder;
  static const Color background = lightCanvas;
  static const Color surface = lightSurface;
  static const Color surfaceContainerLow = lightStrawberryMilk;
  static const Color surfaceContainerLowest = lightSurface;
  static const Color surfaceDim = lightCanvas;
  static const Color surfaceContainerHighest = lightStrawberry;
  static const Color inputFill = lightSurface;
  static const Color textPrimary = lightInk;
  static const Color textSecondary = lightInkMuted;
  static const Color textPrimaryInverse = darkInk;
  static const Color onSurface = lightInk;
  static const Color onSurfaceVariant = lightInkMuted;
  static const Color onBackground = lightInk;
  static const Color outline = lightHairline;
  static const Color outlineVariant = lightBorder;
  static const Color shadow = Color(0x1AC66F80);
  static const Color success = secondary;
  static const Color successSurface = lightMatchaSoft;
  static const Color warning = primary;
  static const Color warningSurface = lightStrawberry;
  static const Color primaryContainer = lightStrawberry;
  static const Color primaryFixed = lightStrawberryMilk;
  static const Color secondaryContainer = lightMatchaSoft;
  static const Color secondaryFixed = lightMatcha;
  static const Color onSecondaryFixed = Color(0xFF2A3A27);
  static const Color tertiary = primary;
  static const Color tertiaryFixed = primaryFixed;
  static const Color tertiaryContainer = lightStrawberry;
  static const Color onEmotionAnger = white;
  static const Color onEmotionSadness = white;
  static const Color onEmotionHappiness = white;
  static const Color onEmotionDisgust = white;
  static const Color onEmotionFear = white;
  static const Color onEmotionNetral = white;

  static List<BoxShadow> get productShadow => const [
        BoxShadow(
          color: Color(0x1AC66F80),
          offset: Offset(0, 8),
          blurRadius: 24,
        ),
      ];

  static ColorScheme get colorScheme => const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: lightStrawberry,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: lightMatchaSoft,
        tertiary: secondary,
        onTertiary: onSecondary,
        tertiaryContainer: lightMatcha,
        surface: lightSurface,
        onSurface: lightInk,
        error: primaryFocus,
        onError: onPrimary,
        outline: lightHairline,
        outlineVariant: lightBorder,
        shadow: shadow,
      );

  static ColorScheme get darkColorScheme => const ColorScheme.dark(
        primary: primarySoft,
        onPrimary: darkCanvas,
        primaryContainer: darkStrawberry,
        secondary: secondarySoft,
        onSecondary: darkCanvas,
        secondaryContainer: darkMatcha,
        tertiary: secondarySoft,
        onTertiary: darkCanvas,
        tertiaryContainer: darkMatcha,
        surface: darkSurface,
        onSurface: darkInk,
        error: primarySoft,
        onError: black,
        outline: darkHairline,
        outlineVariant: darkBorder,
        shadow: shadow,
      );
}
