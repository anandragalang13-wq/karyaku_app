import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:karyaku_app/app/data/models/book_model.dart';
import 'package:karyaku_app/app/data/models/user_model.dart';
import 'package:karyaku_app/app/data/models/work_model.dart';
import 'package:karyaku_app/app/modules/beranda/controllers/beranda_controller.dart';
import 'package:karyaku_app/app/modules/beranda/views/beranda_view.dart';
import 'package:karyaku_app/app/modules/main_nav/controllers/main_nav_controller.dart';
import 'package:karyaku_app/app/modules/pencarian/controllers/pencarian_controller.dart';
import 'package:karyaku_app/app/modules/pencarian/views/pencarian_view.dart';
import 'package:karyaku_app/app/modules/perpustakaan/controllers/perpustakaan_controller.dart';
import 'package:karyaku_app/app/modules/perpustakaan/views/perpustakaan_view.dart';
import 'package:karyaku_app/app/modules/profil/controllers/profil_controller.dart';
import 'package:karyaku_app/app/modules/profil/views/profil_view.dart';
import 'package:karyaku_app/app/services/book_service.dart';
import 'package:karyaku_app/app/services/locale_service.dart';
import 'package:karyaku_app/app/translations/app_translations.dart';

/// BookService tiruan: tidak menyentuh jaringan sama sekali.
class _FakeBookService extends BookService {
  _FakeBookService(this.books);

  final List<BookModel> books;

  @override
  SupabaseClient get supabase =>
      SupabaseClient('https://fake.supabase.co', 'anon-key');

  @override
  Future<List<BookModel>> getAllBooks() async => books;

  @override
  Future<List<WorkModel>> getApprovedWorks() async => <WorkModel>[];
}

/// Controller perpustakaan tiruan (data.history diisi manual).
class _FakeLibraryController extends PerpustakaanController {
  @override
  Future<void> loadLibrary() async {
    isLoading.value = false;
    errorMessage.value = '';
  }
}

/// Controller profil tiruan: dianggap sudah login, bukan penulis.
class _FakeProfilController extends ProfilController {
  // Nilai login memakai Rx agar terbaca sebagai observable di dalam Obx.
  final RxBool _loggedIn = true.obs;

  @override
  bool get isLoggedIn => _loggedIn.value;

  @override
  UserModel get user => const UserModel(
        id: 'u-1',
        name: 'Pembaca Uji',
        email: 'uji@mail.com',
        badge: 'Pembaca',
        karyaDibaca: 3,
        koleksi: 2,
        pengikut: 10,
      );
}

/// Controller profil tiruan untuk akun yang sudah jadi penulis.
class _FakeWriterController extends _FakeProfilController {
  @override
  UserModel get user => const UserModel(
        id: 'u-2',
        name: 'Penulis Uji',
        email: 'penulis@mail.com',
        badge: 'Pembaca Setia',
        karyaDibaca: 10,
        koleksi: 3,
        pengikut: 20,
        isWriter: true,
        penName: 'Penulis Uji',
      );
}

BookModel _book(String id, String title, {String status = 'Ongoing'}) =>
    BookModel(
      id: id,
      title: title,
      author: 'Penulis Uji',
      category: 'Novel',
      rating: 4.5,
      views: 100,
      totalChapters: 5,
      synopsis: 'Sinopsis uji.',
      tags: const ['Novel'],
      status: status,
      coverGradient: const [Colors.blue, Colors.indigo],
    );

Future<void> _pumpApp(WidgetTester tester, Widget home) async {
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
      home: home,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  tearDown(Get.reset);

  group('Beranda — pencarian', () {
    testWidgets('kolom pencarian tampil dan membuka tab Temukan',
        (tester) async {
      Get.put<BookService>(_FakeBookService([]));
      Get.put(MainNavController());
      Get.put(BerandaController());

      await _pumpApp(tester, const BerandaView());

      // Ada kolom pencarian di bagian atas (bukan cuma ikon kecil).
      expect(find.text('Cari judul atau penulis...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsWidgets);

      await tester.tap(find.text('Cari judul atau penulis...'));
      await tester.pumpAndSettle();

      // Berpindah ke tab Temukan (index 2).
      expect(Get.find<MainNavController>().currentIndex.value, 2);
    });
  });

  group('Perpustakaan — header & filter', () {
    testWidgets('header memakai logo + KARYAKU, bukan ikon menu', (tester) async {
      Get.put<PerpustakaanController>(_FakeLibraryController());

      await _pumpApp(tester, const PerpustakaanView());

      expect(find.byIcon(Icons.menu_rounded), findsNothing);
      expect(find.text('KARYAKU'), findsOneWidget);
    });

    testWidgets('tombol filter aktif menyaring riwayat baca', (tester) async {
      final controller = Get.put<PerpustakaanController>(_FakeLibraryController());
      controller.history.assignAll([
        _book('b1', 'Karya Selesai', status: 'Selesai'),
        _book('b2', 'Karya Ongoing'),
      ]);

      await _pumpApp(tester, const PerpustakaanView());

      expect(find.text('Karya Selesai'), findsOneWidget);
      expect(find.text('Karya Ongoing'), findsOneWidget);

      // Buka panel filter.
      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      expect(find.text('Filter Perpustakaan'), findsOneWidget);

      // Pilih status "Selesai".
      await tester.tap(find.text('Selesai').last);
      await tester.pumpAndSettle();

      expect(controller.statusFilter.value, LibraryStatusFilter.selesai);
      expect(controller.filteredHistory.length, 1);
      expect(controller.filteredHistory.first.title, 'Karya Selesai');
    });

    testWidgets('urutan judul A-Z bisa dipilih', (tester) async {
      final controller = Get.put<PerpustakaanController>(_FakeLibraryController());
      controller.history.assignAll([
        _book('b1', 'Buku Zebra'),
        _book('b2', 'Buku Apel'),
      ]);

      await _pumpApp(tester, const PerpustakaanView());

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Judul (A-Z)').last);
      await tester.pumpAndSettle();

      expect(controller.sortBy.value, LibrarySort.judul);
      expect(
        controller.filteredHistory.map((b) => b.title).toList(),
        ['Buku Apel', 'Buku Zebra'],
      );
    });
  });

  group('Temukan — filter & ikon', () {
    testWidgets('ikon globe dihapus dan opsi status tidak ada',
        (tester) async {
      Get.put<BookService>(_FakeBookService([_book('b1', 'Karya Satu')]));
      Get.put(PencarianController());

      await _pumpApp(tester, const PencarianView());

      // Ikon globe/bahasa sudah dihapus.
      expect(find.byIcon(Icons.language_rounded), findsNothing);

      // Panel filter tidak punya lagi opsi status (Ongoing/Selesai).
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      expect(find.textContaining('Status'), findsNothing);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Urutkan Berdasarkan'), findsOneWidget);
    });
  });

  group('Profil — menu & umpan balik', () {
    /// Menu di Profil berada di dalam ListView, jadi item di bawah lipatan
    /// layar harus digulir dulu sebelum bisa diklik.
    Future<void> scrollTo(WidgetTester tester, Finder finder) async {
      await tester.scrollUntilVisible(
        finder,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('menu "Jadi Penulis" dihapus', (tester) async {
      Get.put<ProfilController>(_FakeProfilController());

      await _pumpApp(tester, const ProfilView());

      expect(find.text('Jadi Penulis'), findsNothing);
      expect(find.text('Become an Author'), findsNothing);
    });

    testWidgets('pembaca tetap punya jalan untuk mulai menulis karya',
        (tester) async {
      Get.put<ProfilController>(_FakeProfilController());

      await _pumpApp(tester, const ProfilView());

      // Tidak ada lagi menu "Jadi Penulis", tapi fitur menulis karya tetap
      // bisa diakses lewat kartu "Mulai Menulis".
      expect(find.text('Mulai Menulis'), findsOneWidget);
      expect(find.text('Daftar Sebagai Penulis'), findsOneWidget);
    });

    testWidgets('penulis melihat Tambah Karya dan Kelola Karya',
        (tester) async {
      Get.put<ProfilController>(_FakeWriterController());

      await _pumpApp(tester, const ProfilView());

      expect(find.text('Pusat Penulis'), findsOneWidget);
      expect(find.text('Tambah Karya Sastra Baru'), findsOneWidget);

      await scrollTo(tester, find.text('Kelola Karya'));
      expect(find.text('Kelola Karya'), findsOneWidget);
    });

    testWidgets('tombol Umpan Balik membuka form yang berfungsi',
        (tester) async {
      Get.put<ProfilController>(_FakeProfilController());

      await _pumpApp(tester, const ProfilView());

      await scrollTo(tester, find.text('Kirim Umpan Balik'));
      expect(find.text('Kirim Umpan Balik'), findsOneWidget);

      await tester.tap(find.text('Kirim Umpan Balik'));
      await tester.pumpAndSettle();

      // Form umpan balik benar-benar terbuka (bukan dialog info).
      expect(
        find.textContaining('Tuliskan masukan, laporan bug'),
        findsOneWidget,
      );
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Pesan'), findsOneWidget);
      expect(find.text('Kirim'), findsOneWidget);
    });
  });
}
