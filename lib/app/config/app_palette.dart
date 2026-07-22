import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:flutter/material.dart';

/// Theme-aware semantic colors. Prefer this over raw [AppColors] for UI chrome.
/// Access: `context.palette` (see [AppThemeX]).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.primaryFocus,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryFocus,
    required this.onSecondary,
    required this.canvas,
    required this.surface,
    required this.surfaceHigh,
    required this.strawberry,
    required this.strawberrySoft,
    required this.matcha,
    required this.matchaSoft,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.hairline,
    required this.border,
    required this.inputFill,
    required this.success,
    required this.successSurface,
    required this.warning,
    required this.warningSurface,
    required this.shadow,
  });

  final Brightness brightness;
  final Color primary;
  final Color primaryFocus;
  final Color onPrimary;
  final Color secondary;
  final Color secondaryFocus;
  final Color onSecondary;
  final Color canvas;
  final Color surface;
  final Color surfaceHigh;
  final Color strawberry;
  final Color strawberrySoft;
  final Color matcha;
  final Color matchaSoft;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color hairline;
  final Color border;
  final Color inputFill;
  final Color success;
  final Color successSurface;
  final Color warning;
  final Color warningSurface;
  final Color shadow;

  bool get isDark => brightness == Brightness.dark;

  // Aliases for gradual migration from AppColors names
  Color get background => canvas;
  Color get surfacePearl => surface;
  Color get strawberryBlush => strawberry;
  Color get strawberryMilk => strawberrySoft;
  Color get matchaMist => matcha;
  Color get softMatcha => secondary;
  Color get textPrimary => ink;
  Color get textSecondary => inkMuted;
  Color get onSurface => ink;
  Color get onSurfaceVariant => inkMuted;
  Color get outline => hairline;
  Color get outlineVariant => border;
  Color get surfaceContainerHighest => strawberry;
  Color get surfaceContainerLow => strawberrySoft;
  Color get canvasParchment => strawberry;
  Color get primaryFixed => strawberrySoft;
  Color get secondaryContainer => matchaSoft;
  Color get primaryContainer => strawberry;

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    primary: AppColors.primary,
    primaryFocus: AppColors.primaryFocus,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    secondaryFocus: AppColors.secondaryFocus,
    onSecondary: AppColors.onSecondary,
    canvas: AppColors.lightCanvas,
    surface: AppColors.lightSurface,
    surfaceHigh: AppColors.lightSurfaceHigh,
    strawberry: AppColors.lightStrawberry,
    strawberrySoft: AppColors.lightStrawberryMilk,
    matcha: AppColors.lightMatcha,
    matchaSoft: AppColors.lightMatchaSoft,
    ink: AppColors.lightInk,
    inkMuted: AppColors.lightInkMuted,
    inkFaint: AppColors.lightInkFaint,
    hairline: AppColors.lightHairline,
    border: AppColors.lightBorder,
    inputFill: AppColors.lightSurface,
    success: AppColors.secondary,
    successSurface: AppColors.lightMatchaSoft,
    warning: AppColors.primary,
    warningSurface: AppColors.lightStrawberry,
    shadow: AppColors.shadow,
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    primary: AppColors.primarySoft,
    primaryFocus: AppColors.primary,
    onPrimary: AppColors.darkCanvas,
    secondary: AppColors.secondarySoft,
    secondaryFocus: AppColors.secondary,
    onSecondary: AppColors.darkCanvas,
    canvas: AppColors.darkCanvas,
    surface: AppColors.darkSurface,
    surfaceHigh: AppColors.darkSurfaceHigh,
    strawberry: AppColors.darkStrawberry,
    strawberrySoft: Color(0xFF3D252B),
    matcha: AppColors.darkMatcha,
    matchaSoft: Color(0xFF263623),
    ink: AppColors.darkInk,
    inkMuted: AppColors.darkInkMuted,
    inkFaint: AppColors.darkInkFaint,
    hairline: AppColors.darkHairline,
    border: AppColors.darkBorder,
    inputFill: AppColors.darkSurfaceHigh,
    success: AppColors.secondarySoft,
    successSurface: AppColors.darkMatcha,
    warning: AppColors.primarySoft,
    warningSurface: AppColors.darkStrawberry,
    shadow: Color(0x48000000),
  );

  /// Soft ambient wash for page backgrounds (canvas → strawberry tint).
  LinearGradient get canvasGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          canvas,
          Color.lerp(canvas, strawberrySoft, isDark ? 0.35 : 0.45)!,
        ],
      );

  /// Hero / score panel: primary brand surface with gentle depth.
  LinearGradient get strawberryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          strawberry,
          Color.lerp(strawberry, primary, isDark ? 0.22 : 0.12)!,
        ],
      );

  /// Secondary brand panel.
  LinearGradient get matchaGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          matcha,
          Color.lerp(matcha, secondary, isDark ? 0.2 : 0.1)!,
        ],
      );

  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: shadow,
          offset: const Offset(0, 6),
          blurRadius: 20,
        ),
      ];

  BoxDecoration card({
    Color? color,
    Color? borderColor,
    double radius = AppRadius.lg,
    bool elevated = false,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? hairline,
        width: AppBorder.thin,
      ),
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
      color: strawberrySoft,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: AppBorder.thin),
    );
  }

  BoxDecoration chip({required bool selected, bool useMatcha = false}) {
    final fill = selected
        ? (useMatcha ? secondary : primary)
        : surface;
    final edge = selected
        ? (useMatcha ? secondaryFocus : primaryFocus)
        : hairline;
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
      border: Border.all(color: color, width: AppBorder.thin),
    );
  }

  BoxDecoration circle({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? strawberry,
      shape: BoxShape.circle,
      border: Border.all(
        color: borderColor ?? primary.withValues(alpha: 0.28),
        width: AppBorder.thin,
      ),
    );
  }

  BorderSide get hairlineSide =>
      BorderSide(color: hairline, width: AppBorder.thin);

  BorderSide get focusSide =>
      BorderSide(color: primaryFocus, width: AppBorder.thick);

  BorderSide get primarySide =>
      BorderSide(color: primary, width: AppBorder.thin);

  BorderSide get secondarySide =>
      BorderSide(color: secondary, width: AppBorder.thin);

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? primary,
    Color? primaryFocus,
    Color? onPrimary,
    Color? secondary,
    Color? secondaryFocus,
    Color? onSecondary,
    Color? canvas,
    Color? surface,
    Color? surfaceHigh,
    Color? strawberry,
    Color? strawberrySoft,
    Color? matcha,
    Color? matchaSoft,
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? hairline,
    Color? border,
    Color? inputFill,
    Color? success,
    Color? successSurface,
    Color? warning,
    Color? warningSurface,
    Color? shadow,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      primaryFocus: primaryFocus ?? this.primaryFocus,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      secondaryFocus: secondaryFocus ?? this.secondaryFocus,
      onSecondary: onSecondary ?? this.onSecondary,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      strawberry: strawberry ?? this.strawberry,
      strawberrySoft: strawberrySoft ?? this.strawberrySoft,
      matcha: matcha ?? this.matcha,
      matchaSoft: matchaSoft ?? this.matchaSoft,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      hairline: hairline ?? this.hairline,
      border: border ?? this.border,
      inputFill: inputFill ?? this.inputFill,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: l(primary, other.primary),
      primaryFocus: l(primaryFocus, other.primaryFocus),
      onPrimary: l(onPrimary, other.onPrimary),
      secondary: l(secondary, other.secondary),
      secondaryFocus: l(secondaryFocus, other.secondaryFocus),
      onSecondary: l(onSecondary, other.onSecondary),
      canvas: l(canvas, other.canvas),
      surface: l(surface, other.surface),
      surfaceHigh: l(surfaceHigh, other.surfaceHigh),
      strawberry: l(strawberry, other.strawberry),
      strawberrySoft: l(strawberrySoft, other.strawberrySoft),
      matcha: l(matcha, other.matcha),
      matchaSoft: l(matchaSoft, other.matchaSoft),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      inkFaint: l(inkFaint, other.inkFaint),
      hairline: l(hairline, other.hairline),
      border: l(border, other.border),
      inputFill: l(inputFill, other.inputFill),
      success: l(success, other.success),
      successSurface: l(successSurface, other.successSurface),
      warning: l(warning, other.warning),
      warningSurface: l(warningSurface, other.warningSurface),
      shadow: l(shadow, other.shadow),
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
