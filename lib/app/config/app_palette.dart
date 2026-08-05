import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';

/// Row categories for the List / Settings Icon Chip Color Assignment system
/// (DESIGN.md §4).
///
/// A list of icon chips must draw from **at least three** families, chosen by
/// what the row actually does — never default every row to [primary] just
/// because it is the brand color. The same row type gets the same family
/// everywhere it appears, so pick from this enum rather than freehand.
enum IconChipFamily {
  /// Identity / profile actions — "Edit profil".
  primary,

  /// Preferences / appearance — "Tema", "Bahasa".
  secondary,

  /// Informational / neutral utility — help, licence, support links.
  info,

  /// Caution / resets — "Asesmen ulang", "Reset data".
  warning,

  /// Destructive — "Hapus akun", "Keluar".
  error,

  /// Positive / completed state.
  success,
}

/// Theme-aware Strawberry Match tokens (DESIGN.md §2 / §7).
/// Access: `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.primaryText,
    required this.primaryPressed,
    required this.primaryDisabled,
    required this.primarySoft,
    required this.primaryWash,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryText,
    required this.secondaryPressed,
    required this.secondaryDisabled,
    required this.secondarySoft,
    required this.secondaryWash,
    required this.onSecondary,
    required this.canvas,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.successText,
    required this.warning,
    required this.warningText,
    required this.error,
    required this.errorText,
    required this.info,
    required this.infoText,
    required this.emotion,
    required this.emotionOnSurface,
    required this.shadowRaised,
    required this.shadowFloating,
  });

  final Brightness brightness;

  /// primary-500 fill (light) / theme-safe primary text and icon color (dark).
  final Color primary;
  final Color primaryText;
  final Color primaryPressed;
  final Color primaryDisabled;
  final Color primarySoft;
  final Color primaryWash;
  final Color onPrimary;

  final Color secondary;
  final Color secondaryText;
  final Color secondaryPressed;
  final Color secondaryDisabled;
  final Color secondarySoft;
  final Color secondaryWash;
  final Color onSecondary;

  final Color canvas;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color divider;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final Color success;
  final Color successText;
  final Color warning;
  final Color warningText;
  final Color error;
  final Color errorText;
  final Color info;
  final Color infoText;

  final Map<EmotionLabelType, Color> emotion;
  final Map<EmotionLabelType, Color> emotionOnSurface;

  final Color shadowRaised;
  final Color shadowFloating;

  bool get isDark => brightness == Brightness.dark;

  Color emotionBase(EmotionLabelType e) => emotion[e]!;
  Color emotionText(EmotionLabelType e) => emotionOnSurface[e]!;

  /// Base (fill-source) color for a list/settings icon chip (DESIGN.md §4).
  Color iconChipBase(IconChipFamily family) => switch (family) {
    IconChipFamily.primary => primaryFill,
    IconChipFamily.secondary => secondaryFill,
    IconChipFamily.info => info,
    IconChipFamily.warning => warning,
    IconChipFamily.error => error,
    IconChipFamily.success => success,
  };

  /// Text-safe on-light/on-dark step for a chip's glyph (DESIGN.md §4).
  /// Never render the raw base as an icon color.
  Color iconChipIcon(IconChipFamily family) => switch (family) {
    IconChipFamily.primary => primaryText,
    IconChipFamily.secondary => secondaryText,
    IconChipFamily.info => infoText,
    IconChipFamily.warning => warningText,
    IconChipFamily.error => errorText,
    IconChipFamily.success => successText,
  };

  /// Chip fill: base color at 12–15% opacity, same rule as the Emotion Chip.
  Color iconChipFill(IconChipFamily family) =>
      iconChipBase(family).withValues(alpha: isDark ? 0.18 : 0.13);

  static const Map<EmotionLabelType, Color> _emotionBase = {
    EmotionLabelType.happy: AppColors.emotionHappy,
    EmotionLabelType.sad: AppColors.emotionSad,
    EmotionLabelType.anger: AppColors.emotionAnger,
    EmotionLabelType.fearful: AppColors.emotionFearful,
    EmotionLabelType.disgust: AppColors.emotionDisgust,
    EmotionLabelType.neutral: AppColors.emotionNeutral,
  };

  static const Map<EmotionLabelType, Color> _emotionOnLight = {
    EmotionLabelType.happy: AppColors.emotionHappyOnLight,
    EmotionLabelType.sad: AppColors.emotionSadOnLight,
    EmotionLabelType.anger: AppColors.emotionAngerOnLight,
    EmotionLabelType.fearful: AppColors.emotionFearfulOnLight,
    EmotionLabelType.disgust: AppColors.emotionDisgustOnLight,
    EmotionLabelType.neutral: AppColors.emotionNeutralOnLight,
  };

  static const Map<EmotionLabelType, Color> _emotionOnDark = {
    EmotionLabelType.happy: AppColors.emotionHappyOnDark,
    EmotionLabelType.sad: AppColors.emotionSadOnDark,
    EmotionLabelType.anger: AppColors.emotionAngerOnDark,
    EmotionLabelType.fearful: AppColors.emotionFearfulOnDark,
    EmotionLabelType.disgust: AppColors.emotionDisgustOnDark,
    EmotionLabelType.neutral: AppColors.emotionNeutralOnDark,
  };

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    primary: AppColors.primary500,
    primaryText: AppColors.primary600,
    primaryPressed: AppColors.primary700,
    primaryDisabled: AppColors.primary300,
    primarySoft: AppColors.primary100,
    primaryWash: AppColors.primary50,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary500,
    secondaryText: AppColors.secondary700,
    secondaryPressed: AppColors.secondary700,
    secondaryDisabled: AppColors.secondary300,
    secondarySoft: AppColors.secondary100,
    secondaryWash: AppColors.secondary50,
    onSecondary: AppColors.onSecondary,
    canvas: AppColors.canvasLight,
    surface1: AppColors.surfaceLight1,
    surface2: AppColors.surfaceLight2,
    surface3: AppColors.surfaceLight3,
    divider: AppColors.dividerLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    textTertiary: AppColors.textTertiaryLight,
    success: AppColors.success,
    successText: AppColors.successOnLight,
    warning: AppColors.warning,
    warningText: AppColors.warningOnLight,
    error: AppColors.error,
    errorText: AppColors.errorOnLight,
    info: AppColors.info,
    infoText: AppColors.infoOnLight,
    emotion: _emotionBase,
    emotionOnSurface: _emotionOnLight,
    // Neutral shadow — DESIGN.md §6. Previously 0x..2B0E12 (crimson-tinted),
    // which re-introduced a red wash under every card on the new neutral canvas.
    shadowRaised: Color(0x14000000),
    shadowFloating: Color(0x24000000),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    primary: AppColors.primary300,
    primaryText: AppColors.primary300,
    primaryPressed: AppColors.primary500,
    primaryDisabled: AppColors.primary800,
    primarySoft: AppColors.primary800,
    primaryWash: AppColors.primary900,
    onPrimary: AppColors.canvasDark,
    secondary: AppColors.secondary300,
    secondaryText: AppColors.secondary300,
    secondaryPressed: AppColors.secondary500,
    secondaryDisabled: AppColors.secondary800,
    secondarySoft: AppColors.secondary800,
    secondaryWash: AppColors.secondary900,
    onSecondary: AppColors.canvasDark,
    canvas: AppColors.canvasDark,
    surface1: AppColors.surfaceDark1,
    surface2: AppColors.surfaceDark2,
    surface3: AppColors.surfaceDark3,
    divider: AppColors.dividerDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textTertiary: AppColors.textTertiaryDark,
    success: AppColors.success,
    successText: AppColors.successOnDark,
    warning: AppColors.warning,
    warningText: AppColors.warningOnDark,
    error: AppColors.error,
    errorText: AppColors.errorOnDark,
    info: AppColors.info,
    infoText: AppColors.infoOnDark,
    emotion: _emotionBase,
    emotionOnSurface: _emotionOnDark,
    shadowRaised: Color(0x00000000),
    shadowFloating: Color(0x80000000),
  );

  /// Fill color for brand primary buttons (always seed -500 on light; seed on dark fills).
  Color get primaryFill => AppColors.primary500;

  /// Text/icon color on a [primaryFill] surface.
  ///
  /// [primaryFill] is theme-invariant (always `primary-500` crimson), so its
  /// on-color must be theme-invariant too. Do **not** use [onPrimary] here:
  /// on dark theme that token resolves to `canvas-dark` (#141414), which is
  /// paired with the light `primary-300` fill and fails contrast on crimson.
  Color get onPrimaryFill => AppColors.onPrimary;

  Color get secondaryFill => AppColors.secondary500;

  /// Solid canvas only — do not blend primaryWash into page backgrounds.
  LinearGradient get canvasGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [canvas, canvas],
  );

  /// Vertical brand-to-canvas wash for page headers.
  ///
  /// A brand-red tint at the top that dissolves into [canvas] at the bottom,
  /// so the header melts into the page body instead of reading as a separate
  /// bar. Derived by lerping [canvas] toward [primaryFill] rather than using a
  /// fixed ramp step, which guarantees the bottom stop matches the page
  /// background exactly on both themes.
  ///
  /// The tint is kept light enough that [textPrimary] still passes contrast on
  /// top of it — do not raise the lerp factor without re-checking header text.
  LinearGradient get brandFadeGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.lerp(canvas, primaryFill, isDark ? 0.26 : 0.20)!,
      Color.lerp(canvas, primaryFill, isDark ? 0.08 : 0.06)!,
      canvas,
    ],
    stops: const [0.0, 0.55, 1.0],
  );

  LinearGradient get strawberryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primarySoft,
      Color.lerp(primarySoft, primaryFill, isDark ? 0.22 : 0.12)!,
    ],
  );

  LinearGradient get matchaGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      secondarySoft,
      Color.lerp(secondarySoft, secondaryFill, isDark ? 0.2 : 0.1)!,
    ],
  );

  List<BoxShadow> get cardShadow => isDark
      ? const <BoxShadow>[]
      : [
          BoxShadow(
            color: shadowRaised,
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ];

  List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: shadowFloating,
      offset: const Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  BoxDecoration card({
    Color? color,
    Color? borderColor,
    double radius = AppRadius.lg,
    bool elevated = false,
  }) {
    final useBorder = !isDark || borderColor != null;
    return BoxDecoration(
      color: color ?? surface1,
      borderRadius: BorderRadius.circular(radius),
      border: useBorder
          ? Border.all(color: borderColor ?? divider, width: AppBorder.thin)
          : null,
      boxShadow: elevated ? cardShadow : null,
    );
  }

  BoxDecoration panelStrawberry({double radius = AppRadius.lg}) {
    return BoxDecoration(
      gradient: strawberryGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: primaryFill.withValues(alpha: isDark ? 0.28 : 0.18),
        width: AppBorder.thin,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryFill.withValues(alpha: isDark ? 0.18 : 0.12),
          offset: const Offset(0, 8),
          blurRadius: 22,
        ),
      ],
    );
  }

  /// Saturated brand gradient — `primary-500` seed into `primary-700`.
  ///
  /// Unlike [strawberryGradient] (a pale `primary-100`-based wash), this is a
  /// true brand fill, so anything drawn on it must use [onPrimaryFill].
  LinearGradient get strawberryGradientBold => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(primaryFill, AppColors.primary400, isDark ? 0.0 : 0.14)!,
      Color.lerp(primaryFill, AppColors.primary700, isDark ? 0.85 : 0.65)!,
    ],
  );

  /// High-emphasis brand panel — hero surfaces that must read as brand-red.
  BoxDecoration panelStrawberryBold({double radius = AppRadius.lg}) {
    return BoxDecoration(
      gradient: strawberryGradientBold,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: primaryFill.withValues(alpha: isDark ? 0.30 : 0.34),
          offset: const Offset(0, 10),
          blurRadius: 26,
        ),
      ],
    );
  }

  BoxDecoration panelMatcha({double radius = AppRadius.lg}) {
    return BoxDecoration(
      gradient: matchaGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: secondaryFill.withValues(alpha: isDark ? 0.28 : 0.16),
        width: AppBorder.thin,
      ),
    );
  }

  BoxDecoration panelSoft({double radius = AppRadius.lg}) {
    return BoxDecoration(
      color: primaryWash,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: divider, width: AppBorder.thin),
    );
  }

  BoxDecoration chip({required bool selected, bool useMatcha = false}) {
    final fill = selected
        ? (useMatcha ? secondaryFill : primaryFill)
        : surface2;
    final edge = selected
        ? (useMatcha ? secondaryPressed : primaryPressed)
        : divider;
    return BoxDecoration(
      color: fill,
      borderRadius: AppRadius.chip,
      border: Border.all(
        color: edge,
        width: selected ? AppBorder.thick : AppBorder.thin,
      ),
    );
  }

  BoxDecoration pillFill(Color color) {
    return BoxDecoration(color: color, borderRadius: AppRadius.button);
  }

  BoxDecoration pillOutline(Color color) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: AppRadius.button,
      border: Border.all(color: color, width: AppBorder.medium),
    );
  }

  BoxDecoration circle({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? primarySoft,
      shape: BoxShape.circle,
      border: Border.all(
        color: borderColor ?? primaryFill.withValues(alpha: 0.28),
        width: AppBorder.thin,
      ),
    );
  }

  BorderSide get hairlineSide =>
      BorderSide(color: divider, width: AppBorder.thin);

  BorderSide get focusSide =>
      BorderSide(color: AppColors.primary500, width: AppBorder.medium);

  BorderSide get primarySide =>
      BorderSide(color: primaryFill, width: AppBorder.thin);

  BorderSide get secondarySide =>
      BorderSide(color: AppColors.secondary500, width: AppBorder.medium);

  ColorScheme toColorScheme() {
    if (isDark) {
      return ColorScheme.dark(
        primary: AppColors.primary300,
        onPrimary: AppColors.canvasDark,
        primaryContainer: AppColors.primary800,
        onPrimaryContainer: AppColors.textPrimaryDark,
        secondary: AppColors.secondary300,
        onSecondary: AppColors.canvasDark,
        secondaryContainer: AppColors.secondary800,
        onSecondaryContainer: AppColors.textPrimaryDark,
        surface: AppColors.canvasDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.errorOnDark,
        onError: AppColors.canvasDark,
        outline: AppColors.dividerDark,
        outlineVariant: AppColors.surfaceDark3,
      );
    }
    return ColorScheme.light(
      primary: AppColors.primary500,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primary100,
      onPrimaryContainer: AppColors.primary800,
      secondary: AppColors.secondary500,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondary100,
      onSecondaryContainer: AppColors.secondary800,
      surface: AppColors.canvasLight,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.errorOnLight,
      onError: AppColors.onPrimary,
      outline: AppColors.dividerLight,
      outlineVariant: AppColors.surfaceLight3,
    );
  }

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? primary,
    Color? primaryText,
    Color? primaryPressed,
    Color? primaryDisabled,
    Color? primarySoft,
    Color? primaryWash,
    Color? onPrimary,
    Color? secondary,
    Color? secondaryText,
    Color? secondaryPressed,
    Color? secondaryDisabled,
    Color? secondarySoft,
    Color? secondaryWash,
    Color? onSecondary,
    Color? canvas,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? successText,
    Color? warning,
    Color? warningText,
    Color? error,
    Color? errorText,
    Color? info,
    Color? infoText,
    Map<EmotionLabelType, Color>? emotion,
    Map<EmotionLabelType, Color>? emotionOnSurface,
    Color? shadowRaised,
    Color? shadowFloating,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      primaryText: primaryText ?? this.primaryText,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      primaryDisabled: primaryDisabled ?? this.primaryDisabled,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryWash: primaryWash ?? this.primaryWash,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      secondaryText: secondaryText ?? this.secondaryText,
      secondaryPressed: secondaryPressed ?? this.secondaryPressed,
      secondaryDisabled: secondaryDisabled ?? this.secondaryDisabled,
      secondarySoft: secondarySoft ?? this.secondarySoft,
      secondaryWash: secondaryWash ?? this.secondaryWash,
      onSecondary: onSecondary ?? this.onSecondary,
      canvas: canvas ?? this.canvas,
      surface1: surface1 ?? this.surface1,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      success: success ?? this.success,
      successText: successText ?? this.successText,
      warning: warning ?? this.warning,
      warningText: warningText ?? this.warningText,
      error: error ?? this.error,
      errorText: errorText ?? this.errorText,
      info: info ?? this.info,
      infoText: infoText ?? this.infoText,
      emotion: emotion ?? this.emotion,
      emotionOnSurface: emotionOnSurface ?? this.emotionOnSurface,
      shadowRaised: shadowRaised ?? this.shadowRaised,
      shadowFloating: shadowFloating ?? this.shadowFloating,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    Map<EmotionLabelType, Color> lm(
      Map<EmotionLabelType, Color> a,
      Map<EmotionLabelType, Color> b,
    ) {
      return {for (final e in EmotionLabelType.values) e: l(a[e]!, b[e]!)};
    }

    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: l(primary, other.primary),
      primaryText: l(primaryText, other.primaryText),
      primaryPressed: l(primaryPressed, other.primaryPressed),
      primaryDisabled: l(primaryDisabled, other.primaryDisabled),
      primarySoft: l(primarySoft, other.primarySoft),
      primaryWash: l(primaryWash, other.primaryWash),
      onPrimary: l(onPrimary, other.onPrimary),
      secondary: l(secondary, other.secondary),
      secondaryText: l(secondaryText, other.secondaryText),
      secondaryPressed: l(secondaryPressed, other.secondaryPressed),
      secondaryDisabled: l(secondaryDisabled, other.secondaryDisabled),
      secondarySoft: l(secondarySoft, other.secondarySoft),
      secondaryWash: l(secondaryWash, other.secondaryWash),
      onSecondary: l(onSecondary, other.onSecondary),
      canvas: l(canvas, other.canvas),
      surface1: l(surface1, other.surface1),
      surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3),
      divider: l(divider, other.divider),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      success: l(success, other.success),
      successText: l(successText, other.successText),
      warning: l(warning, other.warning),
      warningText: l(warningText, other.warningText),
      error: l(error, other.error),
      errorText: l(errorText, other.errorText),
      info: l(info, other.info),
      infoText: l(infoText, other.infoText),
      emotion: lm(emotion, other.emotion),
      emotionOnSurface: lm(emotionOnSurface, other.emotionOnSurface),
      shadowRaised: l(shadowRaised, other.shadowRaised),
      shadowFloating: l(shadowFloating, other.shadowFloating),
    );
  }
}

extension AppThemeX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  ThemeData get appTheme => Theme.of(this);

  ColorScheme get scheme => Theme.of(this).colorScheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
