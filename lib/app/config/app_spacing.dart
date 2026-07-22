import 'package:flutter/material.dart';

/// Spacing scale (iOS-on-Android, 4/8 rhythm). Never hardcode gaps in UI.
class AppSpacing {
  AppSpacing._();

  static const double none = 0.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double section = 64.0;

  static const double tight = xxs;
  static const double compact = xs;
  static const double base = md;
  static const double relaxed = lg;
  static const double spacious = xl;
  static const double extraSpacious = xxl;
  static const double safeArea = 64.0;

  static const double pageX = 20.0;
  static const double card = 16.0;
  static const double stack = 12.0;
  static const double buttonY = 14.0;
  static const double buttonX = 22.0;
  static const double touch = 48.0;
  static const double navHeight = 60.0;
}

/// Border radius scale — iOS soft corners. Never hardcode radii in UI.
class AppRadius {
  AppRadius._();

  static const double none = 0.0;
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
  static const double pill = 9999.0;
  static const double full = 9999.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  static final BorderRadius card = BorderRadius.circular(lg);
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(xl));
  static final BorderRadius field = BorderRadius.circular(md);
  static final BorderRadius chip = BorderRadius.circular(pill);
  static final BorderRadius button = BorderRadius.circular(pill);
  static final BorderRadius tile = BorderRadius.circular(md);
}

/// Border widths only. Colors come from [AppPalette] sides.
class AppBorder {
  AppBorder._();

  static const double thin = 1.0;
  static const double medium = 1.5;
  static const double thick = 2.0;
}
