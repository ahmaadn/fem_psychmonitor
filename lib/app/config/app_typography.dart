import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  /// **Display (32px, Bold)**
  ///
  /// Gunakan untuk:
  /// * Judul pada Splash Screen.
  /// * Metrik hero/utama (misal: skor emosional berukuran besar).
  /// * Ringkasan status emosional utama.
  static TextStyle get display => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.64, // -2% Tracking
    color: AppColors.onSurface,
  );

  /// **H1 (24px, Bold)**
  ///
  /// Gunakan untuk:
  /// * Header layar utama (Misal: Judul halaman "Dashboard" atau "Profile").
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  /// **H2 (20px, Semi-bold)**
  ///
  /// Gunakan untuk:
  /// * Header/Judul dari sebuah section (bagian).
  /// * Judul di dalam Card (Card titles).
  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  /// **Body Large (18px, Medium)**
  ///
  /// Gunakan untuk:
  /// * Teks body utama.
  /// * Paragraf pengantar (Intro paragraphs).
  /// * **Pesan "Companion"**: Nasihat langsung atau *insight* psikologis yang diberikan kepada pengguna.
  static TextStyle get bodyLg => GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  /// **Body Medium (16px, Regular)**
  ///
  /// Gunakan untuk:
  /// * Teks body standar.
  /// * Label pada form input.
  static TextStyle get bodyMd => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  /// **Body Small (14px, Regular)**
  ///
  /// Gunakan untuk:
  /// * Deskripsi sekunder/tambahan.
  /// * *Captions* di bawah gambar atau grafik.
  /// * Metadata untuk item di dalam *list* (daftar).
  static TextStyle get bodySm => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  /// **Label (12px, Semi-bold)**
  ///
  /// Gunakan untuk:
  /// * Teks di dalam tombol (Button text).
  /// * *Tags* atau *Chips* kategori.
  /// * *Micro-copy* (teks instruksi singkat).
  static TextStyle get label => GoogleFonts.beVietnamPro(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  /// **Extra Small / XS (10px, Semi-bold)**
  ///
  /// Gunakan untuk:
  /// * Label data berukuran sangat kecil (misal: angka pada sumbu grafik).
  /// * Metadata minor.
  /// * Label pada *Bottom Navigation Bar*.
  static TextStyle get xs => GoogleFonts.beVietnamPro(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  /// Menggabungkan semua style di atas ke dalam [TextTheme] Material Design.
  /// Ini memungkinkan komponen bawaan Flutter mengenali tipografi desain Anda.
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: display,
      headlineLarge: h1,
      headlineMedium: h2,
      bodyLarge: bodyLg,
      bodyMedium: bodyMd,
      bodySmall: bodySm,
      labelLarge: label,
      labelSmall: xs,
    );
  }
}
