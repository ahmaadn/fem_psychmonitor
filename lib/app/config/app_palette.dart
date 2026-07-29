import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';

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

  /// primary-500 fill (light) / primary-400 interactive (dark ColorScheme map).
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
    secondaryText: AppColors.secondary600,
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
    shadowRaised: Color(0x142B211F),
    shadowFloating: Color(0x242B211F),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    primary: AppColors.primary400,
    primaryText: AppColors.primary400,
    primaryPressed: AppColors.primary500,
    primaryDisabled: AppColors.primary800,
    primarySoft: AppColors.primary800,
    primaryWash: AppColors.primary900,
    onPrimary: AppColors.canvasDark,
    secondary: AppColors.secondary400,
    secondaryText: AppColors.secondary400,
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
  Color get primaryFill =>
      isDark ? AppColors.primary500 : AppColors.primary500;

  Color get secondaryFill => AppColors.secondary500;

  LinearGradient get canvasGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          canvas,
          Color.lerp(canvas, primaryWash, isDark ? 0.35 : 0.45)!,
        ],
      );

  LinearGradient get strawberryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primarySoft,
          Color.lerp(primarySoft, primary, isDark ? 0.22 : 0.12)!,
        ],
      );

  LinearGradient get matchaGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          secondarySoft,
          Color.lerp(secondarySoft, secondary, isDark ? 0.2 : 0.1)!,
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
          ? Border.all(
              color: borderColor ?? divider,
              width: AppBorder.thin,
            )
          : null,
      boxShadow: elevated ? cardShadow : null,
    );
  }

  BoxDecoration panelStrawberry({double radius = AppRadius.lg}) {
    return BoxDecoration(
      gradient: strawberryGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: primary.withValues(alpha: isDark ? 0.28 : 0.18),
        width: AppBorder.thin,
      ),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: isDark ? 0.18 : 0.12),
          offset: const Offset(0, 8),
          blurRadius: 22,
        ),
      ],
    );
  }

  BoxDecoration panelMatcha({double radius = AppRadius.lg}) {
    return BoxDecoration(
      gradient: matchaGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: secondary.withValues(alpha: isDark ? 0.28 : 0.16),
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
        ? (useMatcha ? secondary : primary)
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
        color: borderColor ?? primary.withValues(alpha: 0.28),
        width: AppBorder.thin,
      ),
    );
  }

  BorderSide get hairlineSide =>
      BorderSide(color: divider, width: AppBorder.thin);

  BorderSide get focusSide =>
      BorderSide(color: AppColors.primary500, width: AppBorder.medium);

  BorderSide get primarySide =>
      BorderSide(color: primary, width: AppBorder.thin);

  BorderSide get secondarySide =>
      BorderSide(color: AppColors.secondary500, width: AppBorder.medium);

  ColorScheme toColorScheme() {
    if (isDark) {
      return ColorScheme.dark(
        primary: AppColors.primary400,
        onPrimary: AppColors.canvasDark,
        primaryContainer: AppColors.primary800,
        onPrimaryContainer: AppColors.textPrimaryDark,
        secondary: AppColors.secondary400,
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
      return {
        for (final e in EmotionLabelType.values) e: l(a[e]!, b[e]!),
      };
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
