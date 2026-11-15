import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:karyaku_app/app/data/models/book_model.dart';
import 'package:karyaku_app/app/modules/detail_buku/controllers/detail_buku_controller.dart';
import 'package:karyaku_app/app/routes/app_routes.dart';
import 'package:karyaku_app/app/services/locale_service.dart';
import 'package:karyaku_app/app/translations/app_translations.dart';

BookModel _book() => const BookModel(
      id: 'b-1',
      title: 'Laut Bercerita',
      author: 'Leila S. Chudori',
      category: 'Novel',
      rating: 4.9,
      views: 1000,
      totalChapters: 5,
      synopsis: 'Sinopsis uji.',
      tags: ['Novel'],
      coverGradient: [Colors.blue, Colors.indigo],
    );

Future<void> _pumpApp(WidgetTester tester) async {
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
      // Route login supaya "Masuk dulu" bisa dinavigasikan di lingkup test.
      getPages: [
        GetPage(
          name: Routes.LOGIN,
          page: () => const Scaffold(body: Text('halaman-login')),
        ),
      ],
      home: const Scaffold(body: SizedBox()),
    ),
  );
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('tombol Bagikan memakai judul, penulis, dan deep link karya',
      (tester) async {
    await _pumpApp(tester);
    Get.routing.args = _book();

    final controller = Get.put(DetailBukuController());

    expect(controller.shareLink, 'karyaku://book/b-1');
    expect(controller.shareText, contains('Laut Bercerita'));
    expect(controller.shareText, contains('Leila S. Chudori'));
    expect(controller.shareText, contains('karyaku://book/b-1'));
  });

  testWidgets('tanpa argumen halaman tidak menampilkan data dummy',
      (tester) async {
    await _pumpApp(tester);
    Get.routing.args = null;

    final controller = Get.put(DetailBukuController());

    expect(controller.book.id, isEmpty);
    expect(controller.book.title, isEmpty);
    expect(controller.book.content, isEmpty);
  });

  testWidgets('Save meminta login dulu saat user belum masuk',
      (tester) async {
    await _pumpApp(tester);
    Get.routing.args = _book();

    final controller = Get.put(DetailBukuController());
    expect(controller.isBookmarked.value, isFalse);

    controller.toggleBookmark();
    await tester.pumpAndSettle();

    // Status simpanan tidak berubah dan user diarahkan untuk masuk.
    expect(controller.isBookmarked.value, isFalse);
    expect(find.text('Masuk dulu'), findsOneWidget);

    // Biarkan notifikasi snackbar habis masa tampilnya.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
