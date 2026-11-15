import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:karyaku_app/app/data/models/book_model.dart';
import 'package:karyaku_app/app/modules/reader/controllers/reader_controller.dart';
import 'package:karyaku_app/app/modules/reader/views/reader_view.dart';
import 'package:karyaku_app/app/services/locale_service.dart';
import 'package:karyaku_app/app/services/reading_prefs_service.dart';
import 'package:karyaku_app/app/translations/app_translations.dart';

BookModel _book({
  String content = '',
  String synopsis = '',
  String title = 'Karya Unik',
}) =>
    BookModel(
      id: 'book-1',
      title: title,
      author: 'Penulis Uji',
      category: 'Novel',
      rating: 4.5,
      views: 10,
      totalChapters: 1,
      synopsis: synopsis,
      tags: const ['Novel'],
      coverGradient: const [Colors.blue, Colors.indigo],
      content: content,
    );

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  tearDown(Get.reset);

  /// Shell awal (membuat routing GetX) dengan terjemahan terpasang supaya
  /// label tombol di Reader memakai teks pendek, bukan key mentah.
  Future<void> pumpShell(WidgetTester tester) async {
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
        home: const Scaffold(body: SizedBox()),
      ),
    );
  }

  /// Setelah controller siap, tampilkan halaman Reader sungguhan.
  Future<void> pumpReader(WidgetTester tester) async {
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
        home: const ReaderView(),
      ),
    );
    await tester.pump();
  }

  testWidgets('Reader memakai bab dari content database, bukan data contoh',
      (tester) async {
    await pumpShell(tester);
    Get.put(ReadingPrefsService());
    Get.routing.args = _book(
      content: '1|Pembukaan\n\nIsi bab pertama milik karya ini.\n\n[[BAB]]\n\n'
          '2|Lanjutan\n\nIsi bab kedua milik karya ini.',
    );

    final controller = Get.put(ReaderController());

    expect(controller.chapters, hasLength(2));
    expect(controller.chapters[0].title, 'Pembukaan');
    expect(controller.chapters[1].title, 'Lanjutan');
    expect(controller.currentChapter.content,
        contains('Isi bab pertama milik karya ini'));

    await pumpReader(tester);
    expect(find.textContaining('Isi bab pertama milik karya ini'),
        findsOneWidget);
  });

  testWidgets('karya tanpa content tidak jatuh ke novel contoh yang seragam',
      (tester) async {
    await pumpShell(tester);
    Get.put(ReadingPrefsService());
    Get.routing.args = _book(synopsis: 'Sinopsis milik karya ini.');

    final controller = Get.put(ReaderController());

    expect(controller.chapters, hasLength(1));
    expect(controller.currentChapter.content, 'Sinopsis milik karya ini.');
    // Bukan lagi 5 bab "Laut Bercerita" yang dulu dipakai untuk semua buku.
    expect(controller.currentChapter.content,
        isNot(contains('Kelompok Winatra')));
  });

  testWidgets('navigasi bab memakai daftar bab milik karya itu sendiri',
      (tester) async {
    await pumpShell(tester);
    Get.put(ReadingPrefsService());
    Get.routing.args = _book(
      content: '1|Satu\n\nIsi satu.\n\n[[BAB]]\n\n2|Dua\n\nIsi dua.\n\n'
          '[[BAB]]\n\n3|Tiga\n\nIsi tiga.',
    );
    final controller = Get.put(ReaderController());
    await pumpReader(tester);

    controller.nextChapter();
    await tester.pump();

    expect(controller.currentChapterIndex.value, 1);
    expect(find.textContaining('Isi dua'), findsOneWidget);

    controller.goToChapter(2);
    await tester.pump();

    expect(find.textContaining('Isi tiga'), findsOneWidget);
    expect(find.textContaining('Isi dua'), findsNothing);
  });
}
