import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryNavy,
        secondary: AppColors.accentOrange,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      dividerColor: AppColors.border,
      useMaterial3: true,
    );
  }
}

/// Gaya font untuk mode baca (reader), dipilih user lewat Pengaturan Buku.
enum ReaderFont { merriweather, inter, georgia }

extension ReaderFontX on ReaderFont {
  String get label {
    switch (this) {
      case ReaderFont.merriweather:
        return 'Merriweather';
      case ReaderFont.inter:
        return 'Inter';
      case ReaderFont.georgia:
        return 'Georgia';
    }
  }

  TextStyle textStyle({required double fontSize, required Color color}) {
    switch (this) {
      case ReaderFont.merriweather:
        return GoogleFonts.merriweather(fontSize: fontSize, color: color, height: 1.7);
      case ReaderFont.inter:
        return GoogleFonts.inter(fontSize: fontSize, color: color, height: 1.7);
      case ReaderFont.georgia:
        return GoogleFonts.notoSerif(fontSize: fontSize, color: color, height: 1.7);
    }
  }
}

/// Tema tampilan halaman baca: terang / sepia / gelap.
enum ReaderTheme { light, sepia, dark }

extension ReaderThemeX on ReaderTheme {
  Color get background {
    switch (this) {
      case ReaderTheme.light:
        return AppColors.readerLightBg;
      case ReaderTheme.sepia:
        return AppColors.readerSepiaBg;
      case ReaderTheme.dark:
        return AppColors.readerDarkBg;
    }
  }

  Color get textColor {
    switch (this) {
      case ReaderTheme.light:
        return const Color(0xFF2A2A2A);
      case ReaderTheme.sepia:
        return const Color(0xFF3B3223);
      case ReaderTheme.dark:
        return const Color(0xFFE7E7E7);
    }
  }
}
