import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/book_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/book_service.dart';
import '../../main_nav/controllers/main_nav_controller.dart';

/// Status baca yang bisa dipakai untuk menyaring riwayat/koleksi.
enum LibraryStatusFilter { semua, sedangDibaca, selesai }

/// Urutan daftar riwayat/koleksi.
enum LibrarySort { terbaru, progres, judul }

/// Controller halaman Perpustakaan (tab Histori & Koleksi).
///
/// Sumber datanya sepenuhnya dari Supabase, bukan data mock:
/// - **Histori** → tabel `reading_history`: hanya karya yang pernah
///   dibuka/dibaca oleh user tersebut. Belum pernah membaca apa pun →
///   daftar kosong dan halaman menampilkan keadaan "belum ada riwayat".
/// - **Koleksi** → tabel `user_collections`: hanya karya yang memang
///   ditambahkan user ke koleksinya.
class PerpustakaanController extends GetxController {
  final RxInt tabIndex = 0.obs; // 0 = Histori, 1 = Koleksi
  final RxInt categoryIndex = 0.obs; // 0=Semua,1=Novel,2=Puisi,3=Cerpen

  final categories = const ['Semua', 'Novel', 'Puisi', 'Cerpen'];

  final RxList<BookModel> history = <BookModel>[].obs;
  final RxList<BookModel> collection = <BookModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter tambahan (dipakai lewat tombol "Filter" di header).
  final Rx<LibraryStatusFilter> statusFilter = LibraryStatusFilter.semua.obs;
  final Rx<LibrarySort> sortBy = LibrarySort.terbaru.obs;

  List<BookModel> get filteredHistory => _filter(history);
  List<BookModel> get filteredCollection => _filter(collection);

  /// Berapa filter aktif (kategori + status + urutan) — dipakai untuk
  /// memberi tanda pada tombol Filter.
  int get activeFilterCount {
    var count = 0;
    if (categoryIndex.value != 0) count++;
    if (statusFilter.value != LibraryStatusFilter.semua) count++;
    if (sortBy.value != LibrarySort.terbaru) count++;
    return count;
  }

  /// Apakah ada filter yang sedang aktif (selain urutan bawaan).
  bool get hasActiveFilter =>
      categoryIndex.value != 0 ||
      statusFilter.value != LibraryStatusFilter.semua ||
      sortBy.value != LibrarySort.terbaru;

  BookService get _books => Get.find<BookService>();

  @override
  void onInit() {
    super.onInit();
    loadLibrary();
  }

  /// Memuat ulang riwayat baca & koleksi dari database.
  Future<void> loadLibrary() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        _books.getReadingHistory(),
        _books.getCollectionBooks(),
      ]);
      history.assignAll(results[0]);
      collection.assignAll(results[1]);
    } catch (e) {
      errorMessage.value = 'Gagal memuat perpustakaan: $e';
      print('Error loading library: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Menyaring daftar (riwayat/koleksi) berdasarkan kategori, status baca,
  /// dan urutan tampil. Dipakai baik oleh tab Histori maupun tab Koleksi.
  List<BookModel> _filter(List<BookModel> source) {
    var list = source.toList();

    // Filter kategori (chip di atas).
    if (categoryIndex.value != 0) {
      final cat = categories[categoryIndex.value];
      list = list.where((b) => b.category == cat).toList();
    }

    // Filter status karya (dari panel "Filter").
    switch (statusFilter.value) {
      case LibraryStatusFilter.semua:
        break;
      case LibraryStatusFilter.selesai:
        list = list.where((b) => b.status == 'Selesai').toList();
        break;
      case LibraryStatusFilter.sedangDibaca:
        list = list.where((b) => b.status != 'Selesai').toList();
        break;
    }

    // Urutan tampilan.
    switch (sortBy.value) {
      case LibrarySort.terbaru:
        break; // urutan bawaan dari database (terakhir dibaca/ditambahkan)
      case LibrarySort.judul:
        list.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case LibrarySort.progres:
        list.sort((a, b) => b.progress.compareTo(a.progress));
        break;
    }

    return list;
  }

  void changeTab(int i) => tabIndex.value = i;
  void changeCategory(int i) => categoryIndex.value = i;

  /// Setter filter yang dipakai panel "Filter".
  void setStatusFilter(LibraryStatusFilter value) =>
      statusFilter.value = value;
  void setSort(LibrarySort value) => sortBy.value = value;

  /// Mengembalikan semua filter ke kondisi awal.
  void resetFilters() {
    categoryIndex.value = 0;
    statusFilter.value = LibraryStatusFilter.semua;
    sortBy.value = LibrarySort.terbaru;
  }

  /// Membuka halaman Temukan (Pencarian) dari tombol search di header.
  void openSearch() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(2);
    }
  }

  // ------------------------------------------------------------------
  // AKSI
  // ------------------------------------------------------------------

  /// Membuka detail karya; saat kembali, perpustakaan dimuat ulang supaya
  /// progres baca (mis. bab baru di Reader) langsung terlihat.
  Future<void> openBookDetail(BookModel book) async {
    await Get.toNamed(Routes.DETAIL_BUKU, arguments: book);
    await loadLibrary();
  }

  /// Karya approved yang belum ada di koleksi user — dipakai sheet
  /// pemilih karya pada tombol "Tambah Koleksi".
  Future<List<BookModel>> collectionCandidates() async {
    final all = await _books.getAllBooks();
    final existingIds = collection.map((b) => b.id).toSet();
    return all.where((b) => !existingIds.contains(b.id)).toList();
  }

  /// Menambahkan karya ke koleksi user (tersimpan di `user_collections`).
  Future<void> addToCollection(BookModel book) async {
    try {
      await _books.addToCollection(book.id);
      collection.insert(0, book);
      Get.snackbar(
        'library_collection_tab'.tr,
        'library_add_collection_success'.trArgs([book.title]),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'library_add_collection_failed'.tr,
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  /// Konfirmasi lalu menghapus karya dari koleksi user.
  Future<void> confirmRemoveCollection(BookModel book) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('library_remove_collection_title'.tr),
        content: Text(
          'library_remove_collection_message'.trArgs([book.title]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('library_remove_collection_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'library_remove_collection_confirm'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _books.removeFromCollection(book.id);
      collection.removeWhere((b) => b.id == book.id);
    } catch (e) {
      Get.snackbar(
        'library_remove_collection_failed'.tr,
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }
}
