import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/config/supabase_config.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/auth_service.dart';
import 'app/services/book_service.dart';
import 'app/services/locale_service.dart';
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

  // Muat bahasa yang tersimpan (default: Bahasa Indonesia) sebelum
  // aplikasi dijalankan supaya tampilan pertama sudah sesuai pilihan user.
  final localeService = await Get.putAsync<LocaleService>(
    () => LocaleService().init(),
    permanent: true,
  );

  runApp(KaryakuApp(initialLocale: localeService.currentLanguage.value.locale));
}

/// Root widget aplikasi KARYAKU dengan GetMaterialApp
class KaryakuApp extends StatelessWidget {
  final Locale initialLocale;

  const KaryakuApp({super.key, required this.initialLocale});

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
      fallbackLocale: const Locale('id', 'ID'),
    );
  }
}