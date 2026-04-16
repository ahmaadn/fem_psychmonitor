import 'package:fem_psychmonitor/app/utils/theme_extensions.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme(
      brightness: Brightness.light,

      primary: Color(0xFF005EA0),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF4A90C2),
      onPrimaryContainer: Colors.white,

      secondary: Color(0xFFFFD709),
      onSecondary: Color(0xFF2C2F32),
      secondaryContainer: Color(0xFFFFF1A6),
      onSecondaryContainer: Color(0xFF2C2F32),

      tertiary: Color(0xFF7C40A1),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE1BEE7),
      onTertiaryContainer: Color(0xFF2C2F32),

      error: Colors.red,
      onError: Colors.white,

      surface: Color(0xFFF5F7FA),
      onSurface: Color(0xFF2C2F32),

      surfaceContainerHighest: Color(0xFFE3E8EF),
      surfaceContainerHigh: Color(0xFFEAF0F6),
      surfaceContainer: Color(0xFFF0F4F8),
      surfaceContainerLow: Color(0xFFF7F9FC),
      surfaceContainerLowest: Colors.white,

      outline: Color(0xFF2C2F32),
      outlineVariant: Color(0xFF2C2F32).withAlpha((255 * 0.12).toInt()),

      shadow: Colors.transparent,
      scrim: Colors.black26,

      inverseSurface: Color(0xFF2C2F32),
      onInverseSurface: Colors.white,

      inversePrimary: Color(0xFF82B1FF),
    ),

    scaffoldBackgroundColor: const Color(0xFFF5F7FA),

    // =======================
    // TYPOGRAPHY
    // =======================
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 56, // 3.5rem approx
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      displayMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 40,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 16,
        height: 1.6,
      ),
      bodyMedium: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14),
      labelLarge: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // =======================
    // SHAPE (SOFT & LIQUID)
    // =======================
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // xl
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none, // NO BORDER RULE
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
    ),

    // =======================
    // BUTTON THEMES
    // =======================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999), // full rounded
          ),
        ),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return const Color(0xFF005EA0);
        }),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(const Color(0xFF005EA0)),
        overlayColor: WidgetStateProperty.all(
          const Color(0xFF2C2F32).withAlpha((255 * 0.05).toInt()),
        ),
      ),
    ),

    // =======================
    // FAB (Ambient Shadow)
    // =======================
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: Color(0xFF005EA0),
      foregroundColor: Colors.white,
    ),

    // =======================
    // APP BAR (GLASS STYLE)
    // =======================
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0.7),
      foregroundColor: const Color(0xFF2C2F32),
      centerTitle: false,
    ),

    // =======================
    // DIVIDER (DISABLED STYLE)
    // =======================
    dividerTheme: const DividerThemeData(
      thickness: 0,
      space: 0,
      color: Colors.transparent,
    ),
    extensions: [
      PulseThemeExtension(
        primaryGradient: const LinearGradient(
          colors: [Color(0xFF005EA0), Color(0xFF4A90C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        ambientShadow: BoxShadow(
          color: const Color(0xFF2C2F32).withAlpha((255 * 0.1).toInt()),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ),
    ],
  );
}
