import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:karyaku_app/app/data/models/work_model.dart';
import 'package:karyaku_app/app/modules/progres_cerita/controllers/progres_cerita_controller.dart';
import 'package:karyaku_app/app/modules/progres_cerita/views/progres_cerita_view.dart';
import 'package:karyaku_app/app/services/locale_service.dart';
import 'package:karyaku_app/app/translations/app_translations.dart';

WorkModel _draftWork() => WorkModel(
      id: 'work-1',
      authorId: 'user-1',
      title: 'Laut Bercerita',
      type: WorkType.novel,
      content: 'Malam itu Jakarta tidak pernah benar-benar tidur.',
      tags: const ['Novel'],
      createdAt: DateTime(2026, 1, 1),
      approvalStatus: ApprovalStatus.draft,
      chapterCount: 1,
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
      home: const ProgresCeritaView(),
    ),
  );
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('tombol Edit pada kartu bab membuka form edit',
      (tester) async {
    final controller = Get.put(ProgresCeritaController());
    controller.work.value = _draftWork();

    await _pumpApp(tester);
    await tester.pumpAndSettle();

    // Kartu bab pertama menampilkan isi bab + tombol Edit.
    expect(find.text('Malam itu Jakarta tidak pernah benar-benar tidur.'),
        findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // Form edit terbuka: judul + isi bab, dan aksi utama pindah ke dalam
    // kartu (tombol "Tambah Bab Baru" disembunyikan selama edit).
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(find.text('Tambah Bab Baru'), findsNothing);

    Get.reset();
  });

  testWidgets('form edit bisa dibatalkan kembali ke tampilan baca',
      (tester) async {
    final controller = Get.put(ProgresCeritaController());
    controller.work.value = _draftWork();

    await _pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));

    // Tombol aksi ada di bawah form — pastikan terlihat sebelum ditekan.
    await tester.ensureVisible(find.text('Batal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Tambah Bab Baru'), findsOneWidget);

    Get.reset();
  });
}
