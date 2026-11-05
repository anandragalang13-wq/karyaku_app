import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:karyaku_app/app/services/locale_service.dart';
import 'package:karyaku_app/app/translations/app_translations.dart';

void main() {
  testWidgets('teks aplikasi mengikuti bahasa yang aktif', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: AppLanguage.indonesian.locale,
        fallbackLocale: AppLanguage.indonesian.locale,
        supportedLocales:
            AppLanguage.values.map((language) => language.locale).toList(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (_) => Scaffold(
            body: Text('settings_language'.tr),
          ),
        ),
      ),
    );

    expect(find.text('Bahasa'), findsOneWidget);
  });
}
