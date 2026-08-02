import 'package:flutter/material.dart';

/// 4dp base unit scale (DESIGN.md §5). Design canvas 390×844.
class AppSpacing {
  AppSpacing._();

  static const double none = 0.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double section = 64.0;

  static const double tight = xxs;
  static const double compact = xs;
  static const double base = md;
  static const double relaxed = xl;
  static const double spacious = xxl;
  static const double extraSpacious = huge;
  static const double safeArea = 64.0;

  /// Screen side inset
  static const double pageX = 16.0;
  static const double card = 16.0;
  static const double stack = 16.0;
  static const double buttonY = 14.0;
  static const double buttonX = 24.0;
  static const double touch = 48.0;
  static const double navHeight = 60.0;

  /// Sheet drag-handle width (layout, not the 4dp spacing scale).
  static const double sheetHandleW = 40.0;
}

/// Radii (DESIGN.md §4–5): cards 16–20, inputs 12, pills full.
class AppRadius {
  AppRadius._();

  static const double none = 0.0;
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 12.0;
  static const double lg = 18.0;
  static const double xl = 20.0;
  static const double pill = 9999.0;
  static const double full = 9999.0;
  static const double xxl = 28.0;
  static const double xxxl = 32.0;

  static final BorderRadius card = BorderRadius.circular(lg);
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  static final BorderRadius field = BorderRadius.circular(md);
  static final BorderRadius chip = BorderRadius.circular(pill);
  static final BorderRadius button = BorderRadius.circular(pill);
  static final BorderRadius tile = BorderRadius.circular(md);
}

class AppBorder {
  AppBorder._();

  static const double thin = 1.0;
  static const double medium = 1.5;
  static const double thick = 2.0;
}
