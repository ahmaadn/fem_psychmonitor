import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: AppColors.colorScheme,
    textTheme: AppTypography.textTheme,
    fontFamily: 'BeVietnamPro',

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.textTheme.headlineMedium,
      iconTheme: const IconThemeData(color: AppColors.onSurface),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      margin: const EdgeInsets.all(AppSpacing.base),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: AppColors.shadow,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.relaxed,
          vertical: AppSpacing.base,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        textStyle: AppTypography.textTheme.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.15)),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.relaxed,
          vertical: AppSpacing.base,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.base,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      hintStyle: AppTypography.textTheme.bodySmall,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerLowest,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: const Color(0xFF94A3B8),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTypography.textTheme.labelSmall,
      unselectedLabelStyle: AppTypography.textTheme.labelSmall,
    ),

    dividerColor: Colors.transparent,
    splashColor: AppColors.primary.withAlpha((255 * 0.08).toInt()),
    highlightColor: Colors.transparent,
    // hoverColor: AppColors.surfaceContainerHigh,
  );
}
