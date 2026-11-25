import 'package:flutter/material.dart';

/// Palet warna utama aplikasi KARYAKU, diambil dari referensi desain.
class AppColors {
  AppColors._();

  static const Color primaryNavy = Color(0xFF152642);
  static const Color primaryNavyLight = Color(0xFF1F3A5F);
  static const Color accentBlue = Color(0xFF1D5FBF);
  static const Color accentOrange = Color(0xFFE0A544);
  static const Color accentGreen = Color(0xFF2E9E5B);
  static const Color accentPurple = Color(0xFF7C5CBF);

  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E9F0);

  static const Color textPrimary = Color(0xFF152642);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color danger = Color(0xFFD64545);
  static const Color success = Color(0xFF2E9E5B);
  static const Color star = Color(0xFFF5A623);

  static const Color badgeNovel = Color(0xFF152642);
  static const Color badgePuisi = Color(0xFF1D5FBF);
  static const Color badgeCerpen = Color(0xFF2E9E5B);

  static Color badgeForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'novel':
        return badgeNovel;
      case 'puisi':
        return badgePuisi;
      case 'cerpen':
        return badgeCerpen;
      default:
        return primaryNavy;
    }
  }

  static Color darkBadgeForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'novel':
        return darkBadgeNovel;
      case 'puisi':
        return darkBadgePuisi;
      case 'cerpen':
        return darkBadgeCerpen;
      default:
        return darkPrimary;
    }
  }

  static const Color readerLightBg = Color(0xFFFFFFFF);
  static const Color readerSepiaBg = Color(0xFFEFE3CC);
  static const Color readerDarkBg = Color(0xFF121212);

  // ===== Dark Theme Colors =====
  static const Color darkBackground = Color(0xFF0B1526);
  static const Color darkSurface = Color(0xFF162036);
  static const Color darkBorder = Color(0xFF2A3A5A);

  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  static const Color darkPrimary = Color(0xFF3B82F6);
  static const Color darkAccentOrange = Color(0xFFF59E0B);
  static const Color darkAccentBlue = Color(0xFF60A5FA);
  static const Color darkAccentGreen = Color(0xFF34D399);
  static const Color darkAccentPurple = Color(0xFFA78BFA);
  static const Color darkDanger = Color(0xFFF87171);
  static const Color darkStar = Color(0xFFFBBF24);

  static const Color darkBadgeNovel = Color(0xFF60A5FA);
  static const Color darkBadgePuisi = Color(0xFF818CF8);
  static const Color darkBadgeCerpen = Color(0xFF4ADE80);
}
