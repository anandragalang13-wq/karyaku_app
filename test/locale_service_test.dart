import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:karyaku_app/app/services/locale_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  test('memuat bahasa yang tersimpan saat aplikasi dibuka', () async {
    SharedPreferences.setMockInitialValues({LocaleService.prefKey: 'en'});

    final service = await LocaleService().init();

    expect(service.currentLanguage.value, AppLanguage.english);
    expect(Get.locale, AppLanguage.english.locale);
  });

  test('memakai Bahasa Indonesia jika belum pernah mengganti bahasa',
      () async {
    SharedPreferences.setMockInitialValues({});

    final service = await LocaleService().init();

    expect(service.currentLanguage.value, AppLanguage.indonesian);
  });

  test('pilihan bahasa tersimpan dan tetap ada saat aplikasi dibuka ulang',
      () async {
    SharedPreferences.setMockInitialValues({});
    final service = await LocaleService().init();

    await service.saveLanguage(AppLanguage.english);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocaleService.prefKey), 'en');

    // Simulasi aplikasi dibuka ulang: LocaleService baru harus membaca
    // kembali bahasa yang tersimpan.
    final reloaded = await LocaleService().init();
    expect(reloaded.currentLanguage.value, AppLanguage.english);
  });

  test('kode bahasa yang tidak dikenal kembali ke Bahasa Indonesia', () {
    expect(AppLanguage.fromCode('xx'), AppLanguage.indonesian);
    expect(AppLanguage.fromCode(null), AppLanguage.indonesian);
    expect(AppLanguage.fromCode('en'), AppLanguage.english);
  });
}
