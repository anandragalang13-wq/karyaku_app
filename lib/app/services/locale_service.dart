import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bahasa yang didukung aplikasi.
enum AppLanguage {
  indonesian('id', 'ID', 'Bahasa Indonesia', Locale('id', 'ID')),
  english('en', 'EN', 'English', Locale('en', 'US'));

  final String code; // 'id' / 'en'
  final String shortLabel; // 'ID' / 'EN' - dipakai di dropdown
  final String displayName;
  final Locale locale;

  const AppLanguage(this.code, this.shortLabel, this.displayName, this.locale);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLanguage.indonesian,
    );
  }
}

/// Service yang menyimpan & menerapkan bahasa aplikasi secara global.
class LocaleService extends GetxService {
  static const _prefKey = 'app_language_code';

  final Rx<AppLanguage> currentLanguage = AppLanguage.indonesian.obs;

  Future<LocaleService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefKey);
    currentLanguage.value = AppLanguage.fromCode(savedCode);
    return this;
  }

  /// Ganti bahasa aplikasi dan langsung terapkan ke seluruh halaman.
  Future<void> changeLanguage(AppLanguage language) async {
    if (currentLanguage.value == language) return;

    currentLanguage.value = language;
    Get.updateLocale(language.locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, language.code);
  }
}