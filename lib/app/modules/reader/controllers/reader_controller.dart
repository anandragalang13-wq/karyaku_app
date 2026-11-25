import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/chapter_content.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/work_model.dart';
import '../../../data/novel_chapters.dart';
import '../../../services/book_service.dart';
import '../../../services/reading_prefs_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Controller halaman membaca (Reader): navigasi bab novel, panel
/// "Pengaturan Buku" (tema, jenis huruf, ukuran font), dan gulir halaman.
///
/// Preferensi tampilan baca dibaca/ditulis langsung lewat
/// [ReadingPrefsService] supaya perubahan tersimpan di perangkat dan
/// tetap sama dengan yang dipilih di halaman Pengaturan & Akun.
class ReaderController extends GetxController {
  final ReadingPrefsService _prefs = Get.find<ReadingPrefsService>();

  late final BookModel book;

  /// Daftar bab yang tersedia untuk buku ini (5 bab).
  late final List<NovelChapter> chapters;

  /// Indeks bab yang sedang dibaca (berbasis 0).
  final RxInt currentChapterIndex = 0.obs;

  Rx<ReaderTheme> get theme => _prefs.theme;
  Rx<ReaderFont> get font => _prefs.font;
  RxDouble get fontSize => _prefs.fontSize;

  /// Dipakai view supaya berganti bab selalu kembali ke awal halaman.
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Dibuka tanpa argumen → pakai karya kosong (tanpa data dummy).
    book = Get.arguments is BookModel
        ? Get.arguments as BookModel
        : const BookModel(
            id: '',
            title: '',
            author: '',
            category: 'Novel',
            rating: 0,
            views: 0,
            totalChapters: 0,
            synopsis: '',
            tags: [],
            coverGradient: [Color(0xFF667eea), Color(0xFF764ba2)],
          );
    chapters = _chaptersFor(book);
    // Catat posisi baca awal untuk halaman Perpustakaan (best-effort).
    _recordReading();
  }

  /// Daftar bab sebuah karya — urutan prioritas:
  ///
  /// 1. **Isi dari database** (`books.content`): sumber utama, tiap karya
  ///    punya judul & isi bab yang berbeda sesuai data aslinya.
  /// 2. Konten lokal (hanya untuk judul yang memang punya konten lokal).
  /// 3. Sinopsis sebagai satu-satunya bila isi karya masih kosong.
  List<NovelChapter> _chaptersFor(BookModel target) {
    final blocks = ChapterContent.parse(target.content);
    if (blocks.isNotEmpty) {
      return [
        for (final block in blocks)
          NovelChapter(
            number: block.number,
            title: block.title,
            content: block.body,
          ),
      ];
    }

    final local = NovelContent.forBook(target.title);
    if (local.isNotEmpty) return local;

    final fallback = target.synopsis.trim();
    return [
      NovelChapter(
        number: 1,
        title: '',
        content: fallback.isEmpty ? '' : fallback,
      ),
    ];
  }

  /// Mencatat bab yang sedang dibaca user ke `reading_history` supaya
  /// karya muncul di tab Histori Perpustakaan dengan progres terkini.
  /// Kegagalan dicatat ke log tanpa mengganggu proses membaca.
  void _recordReading() {
    if (!Get.isRegistered<BookService>()) return;
    try {
      Get.find<BookService>().recordReading(
        bookId: book.id,
        chapter: currentChapterIndex.value + 1,
        totalChapters: chapters.length,
      );
    } catch (e) {
      print('Record reading error: $e');
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  NovelChapter get currentChapter => chapters[currentChapterIndex.value];

  bool get hasPreviousChapter => currentChapterIndex.value > 0;
  bool get hasNextChapter => currentChapterIndex.value < chapters.length - 1;

  /// Pindah ke bab tertentu (berbasis 0).
  void goToChapter(int index) {
    if (index < 0 || index >= chapters.length) return;
    if (currentChapterIndex.value == index) return;

    currentChapterIndex.value = index;
    _scrollToTop();
    // Perbarui posisi baca di riwayat (supaya progres di Perpustakaan ikut).
    _recordReading();
  }

  void nextChapter() => goToChapter(currentChapterIndex.value + 1);
  void previousChapter() => goToChapter(currentChapterIndex.value - 1);

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  /// Ganti warna background, jenis huruf, dan ukuran font — perubahannya
  /// langsung dipakai layar ini sekaligus disimpan ke perangkat.
  void setTheme(ReaderTheme t) => _prefs.setTheme(t);
  void setFont(ReaderFont f) => _prefs.setFont(f);
  void setFontSize(double v) => _prefs.setFontSize(v);

  /// Dapatkan TextStyle dengan height kustom (override height bawaan font).
  TextStyle fontTextStyle({
    required double fontSize,
    required Color color,
    double height = 1.7,
  }) {
    switch (_prefs.font.value) {
      case ReaderFont.merriweather:
        return GoogleFonts.merriweather(fontSize: fontSize, color: color, height: height);
      case ReaderFont.inter:
        return GoogleFonts.inter(fontSize: fontSize, color: color, height: height);
      case ReaderFont.georgia:
        return GoogleFonts.notoSerif(fontSize: fontSize, color: color, height: height);
    }
  }

  /// Bagikan karya (novel/cerpen/puisi) ke aplikasi lain.
  Future<void> shareWork(dynamic work) async {
    String title = '';
    String author = '';
    String link = '';

    if (work is BookModel) {
      title = work.title;
      author = work.author;
      link = 'karyaku://book/${work.id}';
    } else if (work is WorkModel) {
      title = work.title;
      author = work.authorName ?? 'Penulis';
      link = 'karyaku://book/${work.id}';
    }

    final text = 'Baca "$title" karya $author di KARYAKU: $link';
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      Get.snackbar(
        'Gagal Membagikan',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  /// Toggle bookmark untuk karya.
  Future<void> toggleBookmark(dynamic work) async {
    if (!Get.isRegistered<BookService>()) return;
    final service = Get.find<BookService>();
    final bookId = work is BookModel ? work.id : (work as WorkModel).id;
    final title = work is BookModel ? work.title : (work as WorkModel).title;

    try {
      final isSaved = await service.isSaved(bookId);
      if (isSaved) {
        await service.removeFromCollection(bookId);
        Get.snackbar(
          'Dihapus dari Simpanan',
          '"$title" dihapus dari daftar simpanan.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryNavy,
          colorText: Colors.white,
        );
      } else {
        await service.addToCollection(bookId);
        Get.snackbar(
          'Disimpan',
          '"$title" ditambahkan ke daftar simpanan.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }
}
