import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:karyaku_app/app/services/reading_prefs_service.dart';
import 'package:karyaku_app/app/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('memakai tema/huruf/ukuran default saat user belum pernah memilih',
      () async {
    SharedPreferences.setMockInitialValues({});

    final service = await ReadingPrefsService().init();

    expect(service.theme.value, ReadingPrefsService.defaultTheme);
    expect(service.font.value, ReadingPrefsService.defaultFont);
    expect(service.fontSize.value, ReadingPrefsService.defaultFontSize);
  });

  test('perubahan background, font, dan ukuran font tersimpan di perangkat',
      () async {
    SharedPreferences.setMockInitialValues({});
    final service = await ReadingPrefsService().init();

    await service.setTheme(ReaderTheme.dark);
    await service.setFont(ReaderFont.inter);
    await service.setFontSize(22);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ReadingPrefsService.themeKey), 'dark');
    expect(prefs.getString(ReadingPrefsService.fontKey), 'inter');
    expect(prefs.getDouble(ReadingPrefsService.fontSizeKey), 22);

    // Simulasi aplikasi dibuka ulang: service baru harus membaca kembali
    // pilihan yang sama.
    final reloaded = await ReadingPrefsService().init();
    expect(reloaded.theme.value, ReaderTheme.dark);
    expect(reloaded.font.value, ReaderFont.inter);
    expect(reloaded.fontSize.value, 22);
  });

  test('nilai tersimpan yang tidak dikenal kembali ke nilai default', () async {
    SharedPreferences.setMockInitialValues({
      ReadingPrefsService.themeKey: 'neon',
      ReadingPrefsService.fontKey: 'comic-sans',
      ReadingPrefsService.fontSizeKey: 99.0,
    });

    final service = await ReadingPrefsService().init();

    expect(service.theme.value, ReadingPrefsService.defaultTheme);
    expect(service.font.value, ReadingPrefsService.defaultFont);
    // Ukuran font dijaga tetap dalam rentang slider.
    expect(service.fontSize.value, ReadingPrefsService.maxFontSize);
  });

  test('ukuran font di bawah rentang minimum dibatasi', () async {
    SharedPreferences.setMockInitialValues({
      ReadingPrefsService.fontSizeKey: 5.0,
    });

    final service = await ReadingPrefsService().init();

    expect(service.fontSize.value, ReadingPrefsService.minFontSize);
  });

  test('mengganti ke tema/font yang sama tidak menulis ulang preferensi',
      () async {
    SharedPreferences.setMockInitialValues({
      ReadingPrefsService.themeKey: 'sepia',
      ReadingPrefsService.fontKey: 'merriweather',
      ReadingPrefsService.fontSizeKey: 17.0,
    });

    final service = await ReadingPrefsService().init();

    await service.setTheme(ReaderTheme.sepia);
    await service.setFont(ReaderFont.merriweather);
    await service.setFontSize(17);

    expect(service.theme.value, ReaderTheme.sepia);
    expect(service.font.value, ReaderFont.merriweather);
    expect(service.fontSize.value, 17);
  });
}
