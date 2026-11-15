import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:karyaku_app/app/data/models/book_model.dart';
import 'package:karyaku_app/app/modules/perpustakaan/controllers/perpustakaan_controller.dart';
import 'package:karyaku_app/app/modules/perpustakaan/views/perpustakaan_view.dart';
import 'package:karyaku_app/app/services/locale_service.dart';
import 'package:karyaku_app/app/translations/app_translations.dart';

/// Controller tiruan yang tidak menyentuh Supabase: `loadLibrary` hanya
/// mengisi daftar dari data yang sudah disiapkan test.
class _FakeLibraryController extends PerpustakaanController {
  List<BookModel> seedHistory = [];
  List<BookModel> seedCollection = [];

  @override
  Future<void> loadLibrary() async {
    isLoading.value = false;
    errorMessage.value = '';
    history.assignAll(seedHistory);
    collection.assignAll(seedCollection);
  }
}

BookModel _book(String id, String title, {double progress = 0}) => BookModel(
      id: id,
      title: title,
      author: 'Penulis Uji',
      category: 'Novel',
      rating: 4.5,
      views: 100,
      totalChapters: 5,
      synopsis: 'Sinopsis uji.',
      tags: const ['Novel'],
      progress: progress,
      coverGradient: const [Colors.blue, Colors.indigo],
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
      home: const PerpustakaanView(),
    ),
  );
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('perpustakaan kosong saat user belum pernah membaca',
      (tester) async {
    final controller = Get.put<PerpustakaanController>(_FakeLibraryController());

    await _pumpApp(tester);
    await tester.pumpAndSettle();

    // Tab Histori: keadaan kosong, bukan daftar karya dummy.
    expect(find.text('Belum ada riwayat baca'), findsOneWidget);
    expect(find.text('Penulis Uji'), findsNothing);
    expect(controller.history, isEmpty);

    // Tab Koleksi juga kosong + tombol tambah koleksi.
    await tester.tap(find.text('Koleksi'));
    await tester.pumpAndSettle();
    expect(find.text('Koleksi masih kosong'), findsOneWidget);
    expect(find.text('Tambah Koleksi'), findsOneWidget);
  });

  testWidgets('perpustakaan menampilkan riwayat baca milik user',
      (tester) async {
    final fake = _FakeLibraryController()
      ..seedHistory = [_book('b1', 'Laut Bercerita', progress: 0.4)];
    Get.put<PerpustakaanController>(fake);

    await _pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Laut Bercerita'), findsOneWidget);
    expect(find.text('Belum ada riwayat baca'), findsNothing);

    // Progres baca ikut ditampilkan dari data riwayat.
    expect(find.text('40%'), findsWidgets);
  });

  testWidgets('tab koleksi menampilkan karya yang dikoleksi user',
      (tester) async {
    final fake = _FakeLibraryController()
      ..seedCollection = [_book('b2', 'Bumi Manusia')];
    Get.put<PerpustakaanController>(fake);

    await _pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Koleksi'));
    await tester.pumpAndSettle();

    expect(find.text('Bumi Manusia'), findsOneWidget);
    expect(find.text('Koleksi masih kosong'), findsNothing);
  });
}
