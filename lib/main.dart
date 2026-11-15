import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/config/supabase_config.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/auth_service.dart';
import 'app/services/book_service.dart';
import 'app/services/feedback_service.dart';
import 'app/services/locale_service.dart';
import 'app/services/reading_prefs_service.dart';
import 'app/services/supabase_auth_service.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  Get.put<SupabaseAuthService>(SupabaseAuthService(), permanent: true);
  Get.put<BookService>(BookService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(FeedbackService(), permanent: true);
  // Muat bahasa yang tersimpan (default: Bahasa Indonesia) sebelum
  // aplikasi dijalankan supaya tampilan pertama sudah sesuai pilihan user.
  final localeService = await Get.putAsync<LocaleService>(
    () => LocaleService().init(),
    permanent: true,
  );

  // Preferensi baca (warna background, jenis huruf, ukuran font) juga
  // dimuat sekali di awal supaya Reader & Pengaturan langsung memakai
  // pilihan terakhir user.
  await Get.putAsync<ReadingPrefsService>(
    () => ReadingPrefsService().init(),
    permanent: true,
  );

  runApp(KaryakuApp(initialLocale: localeService.currentLanguage.value.locale));
}

/// Root widget aplikasi KARYAKU dengan GetMaterialApp
class KaryakuApp extends StatelessWidget {
  final Locale initialLocale;

  const KaryakuApp({
    super.key,
    this.initialLocale = const Locale('id', 'ID'),
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KARYAKU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.pages,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: AppLanguage.indonesian.locale,
      supportedLocales:
          AppLanguage.values.map((language) => language.locale).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}