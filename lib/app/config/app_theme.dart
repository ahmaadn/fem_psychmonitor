import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central ThemeData — light/dark + [AppPalette] extension.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(AppPalette.light, AppColors.colorScheme);
  static ThemeData get darkTheme =>
      _build(AppPalette.dark, AppColors.darkColorScheme);

  static ThemeData _build(AppPalette p, ColorScheme scheme) {
    final onSurface = p.ink;
    final muted = p.inkMuted;

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      scaffoldBackgroundColor: p.canvas,
      colorScheme: scheme.copyWith(
        surface: p.surface,
        onSurface: p.ink,
        primary: p.primary,
        onPrimary: p.onPrimary,
        secondary: p.secondary,
        onSecondary: p.onSecondary,
        outline: p.hairline,
        outlineVariant: p.border,
      ),
      extensions: <ThemeExtension<dynamic>>[p],
      textTheme: AppTypography.textTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.tagline.copyWith(color: onSurface),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: p.hairline, width: AppBorder.thin),
        ),
        margin: const EdgeInsets.all(AppSpacing.xs),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, AppSpacing.touch),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonX,
            vertical: AppSpacing.buttonY,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.body,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.secondary,
          foregroundColor: p.onSecondary,
          elevation: 0,
          minimumSize: const Size(0, AppSpacing.touch),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonX,
            vertical: AppSpacing.buttonY,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.body,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: p.primarySide,
          minimumSize: const Size(0, AppSpacing.touch),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonX,
            vertical: AppSpacing.buttonY,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.body,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: AppTypography.body,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.strawberry,
        selectedColor: p.primary,
        secondarySelectedColor: p.secondary,
        labelStyle: AppTypography.caption.copyWith(color: onSurface),
        secondaryLabelStyle:
            AppTypography.caption.copyWith(color: p.onPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chip,
          side: BorderSide(color: p.hairline, width: AppBorder.thin),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(color: p.hairline, width: AppBorder.thin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: p.focusSide,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(
            color: p.primaryFocus,
            width: AppBorder.medium,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(
            color: p.primaryFocus,
            width: AppBorder.thick,
          ),
        ),
        hintStyle: AppTypography.caption.copyWith(color: muted),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.strawberry,
        elevation: 0,
        height: AppSpacing.navHeight + 4,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.navLink.copyWith(
            color: selected ? p.primary : muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? p.primary : muted);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.navLink,
        unselectedLabelStyle: AppTypography.navLink,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.strawberry,
        circularTrackColor: p.matcha,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return p.inkFaint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.strawberry;
          return p.matchaSoft;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: p.hairline,
        thickness: AppBorder.thin,
        space: AppSpacing.md,
      ),
      dividerColor: p.hairline,
      splashColor: p.primary.withValues(alpha: 0.08),
      highlightColor: p.secondary.withValues(alpha: 0.06),
    );
  }
}
