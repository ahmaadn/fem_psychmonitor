import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Light + dark [ThemeData] with [AppPalette] extension (DESIGN.md §7).
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(AppPalette.light);

  static ThemeData get darkTheme => _build(AppPalette.dark);

  static ThemeData _build(AppPalette p) {
    final scheme = p.toColorScheme();
    final onSurface = p.textPrimary;
    final tertiary = p.textTertiary;

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      scaffoldBackgroundColor: p.canvas,
      colorScheme: scheme,
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
        titleTextStyle: AppTypography.title.copyWith(color: onSurface),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: p.surface1,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: p.isDark
              ? BorderSide.none
              : BorderSide(color: p.divider, width: AppBorder.thin),
        ),
        margin: const EdgeInsets.all(AppSpacing.xs),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primaryFill,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.isDark ? p.surface2 : p.primaryDisabled,
          disabledForegroundColor: tertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, AppSpacing.touch),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonX,
            vertical: AppSpacing.buttonY,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.button,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.secondaryFill,
          foregroundColor: p.onSecondary,
          elevation: 0,
          minimumSize: const Size(0, AppSpacing.touch),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonX,
            vertical: AppSpacing.buttonY,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.secondaryText,
          side: BorderSide(color: p.secondaryFill, width: AppBorder.medium),
          minimumSize: const Size(0, AppSpacing.touch),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonX,
            vertical: AppSpacing.buttonY,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primaryText,
          textStyle: AppTypography.button,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primaryFill,
        foregroundColor: p.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface2,
        selectedColor: p.primarySoft,
        secondarySelectedColor: p.secondarySoft,
        labelStyle: AppTypography.label.copyWith(color: onSurface),
        secondaryLabelStyle: AppTypography.label.copyWith(color: p.primaryText),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chip,
          side: BorderSide(color: p.divider, width: AppBorder.thin),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(color: p.divider, width: AppBorder.thin),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(color: p.divider, width: AppBorder.thin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(color: p.primaryFill, width: AppBorder.medium),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(color: p.error, width: AppBorder.medium),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(color: p.error, width: AppBorder.thick),
        ),
        hintStyle: AppTypography.body.copyWith(color: tertiary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface1,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        showDragHandle: false,
        elevation: p.isDark ? 0 : 8,
        shadowColor: p.shadowFloating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.isDark ? p.surface2 : p.surface1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        elevation: p.isDark ? 0 : 8,
        shadowColor: p.shadowFloating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface1,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: AppSpacing.navHeight + 4,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.label.copyWith(
            color: selected ? p.primaryText : tertiary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? p.primaryText : tertiary);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface1,
        selectedItemColor: p.primaryText,
        unselectedItemColor: tertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.label,
        unselectedLabelStyle: AppTypography.label,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primaryFill,
        linearTrackColor: p.surface3,
        circularTrackColor: p.surface3,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primaryFill;
          return tertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return p.isDark ? p.primarySoft : AppColors.primary200;
          }
          return p.surface3;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: p.divider,
        thickness: AppBorder.thin,
        space: AppSpacing.md,
      ),
      dividerColor: p.divider,
      splashColor: p.primary.withValues(alpha: 0.08),
      highlightColor: p.secondary.withValues(alpha: 0.06),
    );
  }
}
