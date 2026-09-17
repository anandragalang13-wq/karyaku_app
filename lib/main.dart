import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/config/supabase_config.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/auth_service.dart';
import 'app/services/book_service.dart';
import 'app/services/supabase_auth_service.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  Get.put<SupabaseAuthService>(SupabaseAuthService(), permanent: true);
  Get.put<BookService>(BookService(), permanent: true);
  Get.put(AuthService(), permanent: true);

  runApp(const KaryakuApp());
}

/// Root widget aplikasi KARYAKU dengan GetMaterialApp
class KaryakuApp extends StatelessWidget {
  const KaryakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KARYAKU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.pages,
    );
  }
}