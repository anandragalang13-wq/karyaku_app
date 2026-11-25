import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/book_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/book_cover.dart';
import '../../../widgets/category_badge.dart';
import '../controllers/perpustakaan_controller.dart';

class PerpustakaanView extends GetView<PerpustakaanController> {
  const PerpustakaanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  // LOGO APLIKASI (bukan ikon menu) + nama aplikasi di
                  // pojok kiri atas.
                  Image.asset(
                    'assets/images/logo.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.auto_stories,
                      size: 28,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('KARYAKU',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                          
                ],
              ),
            ),
            _TopTabs(controller: controller),
            const SizedBox(height: 12),
            _CategoryFilterRow(controller: controller),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                // Memuat data pertama kali (belum ada apa pun untuk tampil).
                if (controller.isLoading.value &&
                    controller.history.isEmpty &&
                    controller.collection.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Gagal terhubung ke database & belum ada data tersimpan.
                if (controller.errorMessage.value.isNotEmpty &&
                    controller.history.isEmpty &&
                    controller.collection.isEmpty) {
                  return _ErrorState(
                    message: controller.errorMessage.value,
                    onRetry: controller.loadLibrary,
                  );
                }

                return controller.tabIndex.value == 0
                    ? _HistoriList(controller: controller)
                    : _KoleksiGrid(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  final PerpustakaanController controller;
  const _TopTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _TabButton(
            label: 'library_history_tab'.tr,
            selected: controller.tabIndex.value == 0,
            onTap: () => controller.changeTab(0),
          ),
          _TabButton(
            label: 'library_collection_tab'.tr,
            selected: controller.tabIndex.value == 1,
            onTap: () => controller.changeTab(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primaryNavy : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: selected ? AppColors.primaryNavy : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterRow extends StatelessWidget {
  final PerpustakaanController controller;
  const _CategoryFilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            ...List.generate(controller.categories.length, (i) {
              final selected = controller.categoryIndex.value == i;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => controller.changeCategory(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.primaryNavy : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            selected ? AppColors.primaryNavy : AppColors.border,
                      ),
                    ),
                    child: Text(
                      controller.categories[i],
                      style: TextStyle(
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
            // TOMBOL FILTER — sekarang benar-benar aktif: membuka panel
            // filter status & urutan untuk riwayat baca maupun koleksi.
            InkWell(
              onTap: () => _openFilterSheet(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: controller.hasActiveFilter
                      ? AppColors.primaryNavy
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.hasActiveFilter
                        ? AppColors.primaryNavy
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded,
                        size: 16,
                        color: controller.hasActiveFilter
                            ? Colors.white
                            : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('library_filter'.tr,
                        style: TextStyle(
                            color: controller.hasActiveFilter
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Panel filter (status karya & urutan tampil) untuk tab Histori maupun
  /// Koleksi.
  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LibraryFilterSheet(controller: controller),
    );
  }
}

class _HistoriList extends StatelessWidget {
  final PerpustakaanController controller;
  const _HistoriList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filteredHistory;

      // Belum pernah membaca apa pun → keadaan kosong "belum ada riwayat".
      if (controller.history.isEmpty) {
        return _EmptyState(
          icon: Icons.history_rounded,
          title: 'library_empty_history_title'.tr,
          desc: 'library_no_history'.tr,
        );
      }

      // Filter karya pada kategori tertentu tidak menemukan apa pun.
      if (list.isEmpty) {
        return _EmptyState(
          icon: Icons.tune_rounded,
          title: 'library_empty_category'.tr,
          desc: '',
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final book = list[i];
          return GestureDetector(
            onTap: () => controller.openBookDetail(book),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCoverImage(
                    coverAsset: book.coverAsset,
                    gradient: book.coverGradient,
                    icon: book.coverIcon,
                    width: 56,
                    height: 76,
                    borderRadius: 8,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(book.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ),
                            CategoryBadge(category: book.category),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(book.author,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('library_reading_progress'.tr,
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 11)),
                            Text(book.progressLabel,
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: book.progress,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(
                              book.progress >= 1
                                  ? AppColors.success
                                  : AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _KoleksiGrid extends StatelessWidget {
  final PerpustakaanController controller;
  const _KoleksiGrid({required this.controller});

  /// Koleksi masih kosong → tampil keadaan kosong plus tombol untuk
  /// memilih karya yang akan ditambahkan ke koleksi.
  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Expanded(
            child: _EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'library_empty_collection_title'.tr,
              desc: 'library_empty_collection_desc'.tr,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _pickAndAddCollection(context),
              icon: const Icon(Icons.add_rounded),
              label: Text('library_add_collection'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membuka sheet pemilih karya approved, lalu menambahkan pilihan
  /// pertama ke koleksi user.
  Future<void> _pickAndAddCollection(BuildContext context) async {
    final book = await showModalBottomSheet<BookModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CollectionPickerSheet(controller: controller),
    );
    if (book != null) await controller.addToCollection(book);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Belum ada karya yang dikoleksi → keadaan kosong + tombol tambah.
      if (controller.collection.isEmpty) return _buildEmpty(context);

      final list = controller.filteredCollection;
      if (list.isEmpty) {
        return _EmptyState(
          icon: Icons.tune_rounded,
          title: 'library_empty_category'.tr,
          desc: '',
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'library_remove_collection_hint'.tr,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: list.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, i) {
                if (i == list.length) {
                  return GestureDetector(
                    onTap: () => _pickAndAddCollection(context),
                    child: const DottedAddCard(),
                  );
                }
                final book = list[i];
                // Tekan lama → hapus karya dari koleksi (dengan konfirmasi).
                return GestureDetector(
                  onTap: () => controller.openBookDetail(book),
                  onLongPress: () => controller.confirmRemoveCollection(book),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: BookCoverImage(
                          coverAsset: book.coverAsset,
                          gradient: book.coverGradient,
                          icon: book.coverIcon,
                          borderRadius: 12,
                        ),
                      ),
                      Positioned(
                          top: 8,
                          left: 8,
                          child: CategoryBadge(category: book.category)),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: LinearProgressIndicator(
                            value: book.progress,
                            minHeight: 4,
                            backgroundColor: Colors.white.withOpacity(0.25),
                            valueColor: AlwaysStoppedAnimation(
                              book.progress >= 1
                                  ? AppColors.success
                                  : AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(
                  book.status == 'Selesai' ? 'Selesai' : book.chapterLabel,
                  style: TextStyle(
                    color: book.status == 'Selesai'
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                  ],
                ),
              );
              },
            ),
          ),
        ],
      );
    });
  }
}

class DottedAddCard extends StatelessWidget {
  const DottedAddCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.4),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textMuted),
            ),
            child: Icon(Icons.add, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text('library_add_collection'.tr,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Keadaan kosong generik halaman Perpustakaan (riwayat/koleksi/filter).
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _EmptyState({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 34, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Keadaan gagal memuat data dari database, lengkap dengan tombol coba lagi.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('manage_works_retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet pemilih karya approved yang belum ada di koleksi user.
class _CollectionPickerSheet extends StatefulWidget {
  final PerpustakaanController controller;
  const _CollectionPickerSheet({required this.controller});

  @override
  State<_CollectionPickerSheet> createState() => _CollectionPickerSheetState();
}

class _CollectionPickerSheetState extends State<_CollectionPickerSheet> {
  late Future<List<BookModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.collectionCandidates();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'library_choose_collection'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: FutureBuilder<List<BookModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final books = snapshot.data ?? const <BookModel>[];
                if (books.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'library_collection_full'.tr,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final book = books[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: BookCoverImage(
                        coverAsset: book.coverAsset,
                        gradient: book.coverGradient,
                        icon: book.coverIcon,
                        width: 40,
                        height: 56,
                        borderRadius: 6,
                        iconSize: 16,
                      ),
                      title: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      subtitle: Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.add_circle_rounded,
                          color: AppColors.primaryNavy),
                      onTap: () => Navigator.of(context).pop(book),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel filter untuk Perpustakaan: menyaring status baca dan urutan
/// tampilan, baik untuk tab Histori maupun tab Koleksi.
class _LibraryFilterSheet extends StatelessWidget {
  final PerpustakaanController controller;
  const _LibraryFilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'library_filter_title'.tr,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionTitle('library_filter_status'.tr),
            const SizedBox(height: 10),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FilterChip(
                    label: 'library_filter_status_all'.tr,
                    selected: controller.statusFilter.value ==
                        LibraryStatusFilter.semua,
                    onTap: () => controller
                        .setStatusFilter(LibraryStatusFilter.semua),
                  ),
                  _FilterChip(
                    label: 'library_filter_status_reading'.tr,
                    selected: controller.statusFilter.value ==
                        LibraryStatusFilter.sedangDibaca,
                    onTap: () => controller
                        .setStatusFilter(LibraryStatusFilter.sedangDibaca),
                  ),
                  _FilterChip(
                    label: 'library_filter_status_finished'.tr,
                    selected: controller.statusFilter.value ==
                        LibraryStatusFilter.selesai,
                    onTap: () =>
                        controller.setStatusFilter(LibraryStatusFilter.selesai),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('library_filter_sort'.tr),
            const SizedBox(height: 10),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FilterChip(
                    label: 'library_filter_sort_recent'.tr,
                    selected: controller.sortBy.value == LibrarySort.terbaru,
                    onTap: () => controller.setSort(LibrarySort.terbaru),
                  ),
                  _FilterChip(
                    label: 'library_filter_sort_progress'.tr,
                    selected: controller.sortBy.value == LibrarySort.progres,
                    onTap: () => controller.setSort(LibrarySort.progres),
                  ),
                  _FilterChip(
                    label: 'library_filter_sort_title'.tr,
                    selected: controller.sortBy.value == LibrarySort.judul,
                    onTap: () => controller.setSort(LibrarySort.judul),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.resetFilters,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('library_filter_reset'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('library_filter_apply'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryNavy : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryNavy : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}