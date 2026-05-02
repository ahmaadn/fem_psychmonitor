class AppSpacing {
  AppSpacing._();

  // Grid dasar menggunakan kelipatan 8px
  static const double none = 0.0;

  // Design aliases (DESIGN.md)

  /// 4px, untuk jarak sangat kecil, seperti antara ikon dan teks dalam tombol.
  static const double xs = 4.0;

  /// 8px, untuk jarak kecil, seperti antara elemen dalam satu grup (misalnya, antara label dan input).
  static const double sm = 8.0;

  /// 16px, untuk jarak standar antar elemen utama (misalnya, antara form fields).
  static const double md = 16.0;

  /// 24px, untuk jarak lebih longgar antar grup elemen (misalnya, antara sections dalam satu page).
  static const double lg = 24.0;

  /// 32px, untuk jarak besar antar section utama (misalnya, antara header dan content).
  static const double xl = 32.0;

  /// Internal grouping, icon labels.
  static const double tight = 4.0;

  /// Elemen dalam card, padding input.
  static const double compact = 8.0;

  /// Gutter standar, jarak antar input.
  static const double base = 16.0;

  /// Jarak antar grup komponen utama.
  static const double relaxed = 24.0;

  /// Header section, margin card besar.
  static const double spacious = 32.0;

  /// Pemisah antar section (Page-level).
  static const double extraSpacious = 48.0;

  /// Margin aman atas/bawah.
  static const double safeArea = 64.0;
}

class AppRadius {
  AppRadius._();

  // Pembulatan sudut (Corner Radius) untuk kesan UI yang empatik dan lembut
  /// Checkboxes, tag kecil.
  static const double xs = 4.0;

  /// Checkboxes, tag kecil.
  static const double sm = 8.0;

  /// Tombol standar, input fields.
  static const double md = 16.0;

  /// Banner besar, modal bawah.
  static const double lg = 24.0;

  /// Content cards (legacy size).
  static const double xl = 24.0;

  /// Large feature cards, dashboard summaries.
  static const double xxl = 32.0;

  /// App Bars, elemen Splash Screen.
  static const double xxxl = 48.0;

  /// Avatars, pill-shaped buttons.
  static const double full = 9999.0;
}
