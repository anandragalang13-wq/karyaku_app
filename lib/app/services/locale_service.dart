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
  /// Key SharedPreferences tempat pilihan bahasa disimpan.
  static const prefKey = 'app_language_code';

  final Rx<AppLanguage> currentLanguage = AppLanguage.indonesian.obs;

  /// Muat bahasa terakhir yang dipilih user. Dipanggil sekali di [main]
  /// sebelum aplikasi ditampilkan supaya bahasa tidak berubah-ubah saat
  /// halaman pertama dibuka.
  Future<LocaleService> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentLanguage.value = AppLanguage.fromCode(prefs.getString(prefKey));
    Get.locale = currentLanguage.value.locale;
    return this;
  }

  /// Ganti bahasa aplikasi, terapkan ke seluruh halaman, lalu simpan
  /// pilihannya agar tetap dipakai saat aplikasi dibuka kembali.
  Future<void> changeLanguage(AppLanguage language) async {
    if (currentLanguage.value == language) return;

    currentLanguage.value = language;

    // Simpan lebih dulu supaya pilihan tidak hilang jika aplikasi langsung
    // ditutup tepat setelah user mengganti bahasa.
    await saveLanguage(language);

    await Get.updateLocale(language.locale);
  }

  /// Menyimpan pilihan bahasa ke penyimpanan lokal.
  Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, language.code);
  }
}