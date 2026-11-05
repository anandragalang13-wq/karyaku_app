import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Preferensi tampilan halaman baca: warna background (tema), jenis huruf,
/// dan ukuran font.
///
/// Disimpan di perangkat lewat [SharedPreferences] supaya pilihan user tetap
/// berlaku saat aplikasi dibuka kembali, dan dipakai bersama oleh halaman
/// **Pengaturan & Akun** serta panel **Pengaturan Buku** di Reader — keduanya
/// menunjuk ke Rx yang sama, jadi perubahan langsung sinkron.
class ReadingPrefsService extends GetxService {
  // Key SharedPreferences.
  static const themeKey = 'reading_theme';
  static const fontKey = 'reading_font';
  static const fontSizeKey = 'reading_font_size';

  // Nilai awal saat user belum pernah memilih apa pun.
  static const ReaderTheme defaultTheme = ReaderTheme.sepia;
  static const ReaderFont defaultFont = ReaderFont.merriweather;
  static const double defaultFontSize = 17;

  /// Batas ukuran font yang diizinkan (dipakai slider di Pengaturan & Reader
  /// supaya rentangnya selalu sama dan nilai tersimpan tidak pernah
  /// membuat slider gagal render).
  static const double minFontSize = 13;
  static const double maxFontSize = 26;

  final Rx<ReaderTheme> theme = defaultTheme.obs;
  final Rx<ReaderFont> font = defaultFont.obs;
  final RxDouble fontSize = defaultFontSize.obs;

  /// Memuat pilihan terakhir user. Dipanggil sekali di [main] sebelum
  /// aplikasi ditampilkan supaya tampilan tidak berkedip ke nilai default.
  Future<ReadingPrefsService> init() async {
    final prefs = await SharedPreferences.getInstance();

    theme.value = _themeFromName(prefs.getString(themeKey));
    font.value = _fontFromName(prefs.getString(fontKey));
    fontSize.value = _normalizeFontSize(prefs.getDouble(fontSizeKey));

    return this;
  }

  // ------------------------------------------------------------------
  // PENULISAN (langsung disimpan supaya pilihan tidak hilang)
  // ------------------------------------------------------------------

  Future<void> setTheme(ReaderTheme value) async {
    if (theme.value == value) return;
    theme.value = value;
    await _save((prefs) => prefs.setString(themeKey, value.name));
  }

  Future<void> setFont(ReaderFont value) async {
    if (font.value == value) return;
    font.value = value;
    await _save((prefs) => prefs.setString(fontKey, value.name));
  }

  Future<void> setFontSize(double value) async {
    final normalized = _normalizeFontSize(value);
    if (fontSize.value == normalized) return;
    fontSize.value = normalized;
    await _save((prefs) => prefs.setDouble(fontSizeKey, normalized));
  }

  /// Menyimpan dengan aman: kegagalan menulis preferensi tidak boleh
  /// menggagalkan aksi user di layar.
  Future<void> _save(
    Future<bool> Function(SharedPreferences prefs) write,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await write(prefs);
    } catch (e) {
      print('Gagal menyimpan preferensi baca: $e');
    }
  }

  // ------------------------------------------------------------------
  // PARSER
  // ------------------------------------------------------------------

  static ReaderTheme _themeFromName(String? name) {
    for (final value in ReaderTheme.values) {
      if (value.name == name) return value;
    }
    return defaultTheme;
  }

  static ReaderFont _fontFromName(String? name) {
    for (final value in ReaderFont.values) {
      if (value.name == name) return value;
    }
    return defaultFont;
  }

  /// Ukuran font dijaga tetap di dalam rentang [minFontSize]–[maxFontSize],
  /// karena nilai tersimpan bisa saja berasal dari versi aplikasi lain.
  static double _normalizeFontSize(double? value) {
    if (value == null || value.isNaN) return defaultFontSize;
    if (value < minFontSize) return minFontSize;
    if (value > maxFontSize) return maxFontSize;
    return value;
  }
}
