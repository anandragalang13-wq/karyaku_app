import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/book_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/book_cover.dart';
import '../../../widgets/poetry_card.dart';
import '../../../widgets/rating_stars.dart';
import '../controllers/pencarian_controller.dart';

class PencarianView extends GetView<PencarianController> {
  const PencarianView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Halaman Temukan
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'nav_discover'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jelajahi dan temukan karya sastra baru',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar & Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
  child: Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(Icons.search_rounded, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            onChanged: (v) => controller.searchText.value = v,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'search_hint'.tr,
              hintStyle: TextStyle(color: AppColors.textMuted),
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
      ],
    ),
  ),
),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _openFilterSheet(context),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.accentOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final list = controller.results;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'search_no_results'.tr,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, i) => _SearchResultTile(
                    book: list[i],
                    onTap: () => controller.openBookDetail(list[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    Get.bottomSheet(
      const _FilterSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  const _SearchResultTile({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Khusus Puisi: gunakan layout tipografi estetis
    if (book.category == 'Puisi') {
      return _PoetrySearchResultTile(book: book, onTap: onTap);
    }

    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCoverImage(
            coverAsset: book.coverAsset,
            gradient: book.coverGradient,
            icon: book.coverIcon,
            width: 64,
            height: 88,
            borderRadius: 10,
            iconSize: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  book.author,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.badgeForCategory(book.category).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        book.category,
                        style: TextStyle(
                          color: AppColors.badgeForCategory(book.category),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (book.status == 'Selesai'
                                ? AppColors.success
                                : AppColors.accentOrange)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        book.status == 'Selesai' ? 'search_status_finished'.tr : 'search_status_ongoing'.tr,
                        style: TextStyle(
                          color: book.status == 'Selesai'
                              ? AppColors.success
                              : AppColors.accentOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          RatingStars(rating: book.rating),
        ],
      ),
    );
  }
}

class _PoetrySearchResultTile extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  const _PoetrySearchResultTile({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor(book.category, book.tags);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              themeColor.withValues(alpha: 0.1),
              themeColor.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: themeColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail tipografi
            Container(
              width: 64,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    themeColor.withValues(alpha: 0.15),
                    themeColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: themeColor.withValues(alpha: 0.3)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.format_quote_rounded,
                      color: themeColor.withValues(alpha: 0.5),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.format_quote_rounded, size: 10, color: themeColor),
                            const SizedBox(width: 3),
                            Text(
                              'Puisi',
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  if (book.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: book.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: themeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            RatingStars(rating: book.rating),
          ],
        ),
      ),
    );
  }

  Color _getThemeColor(String category, List<String> tags) {
    if (tags.isEmpty) return AppColors.badgePuisi;
    final tag = tags.first.toLowerCase();
    if (tag.contains('cinta') || tag.contains('romantis') || tag.contains('love')) {
      return const Color(0xFFE91E63);
    }
    if (tag.contains('malam') || tag.contains('gelap') || tag.contains('night')) {
      return const Color(0xFF673AB7);
    }
    if (tag.contains('alam') || tag.contains('nature') || tag.contains('hijau')) {
      return const Color(0xFF4CAF50);
    }
    if (tag.contains('sedih') || tag.contains('galau') || tag.contains('duka')) {
      return const Color(0xFF2196F3);
    }
    if (tag.contains('harapan') || tag.contains('semangat') || tag.contains('motivasi')) {
      return const Color(0xFFFF9800);
    }
    return AppColors.badgePuisi;
  }
}

class _FilterSheet extends GetView<PencarianController> {
  const _FilterSheet();

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
                  'search_filter_sort'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: Get.back,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'search_category'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Wrap(
                spacing: 10,
                children: List.generate(controller.categories.length, (i) {
                  final selected = controller.filterCategoryIndex.value == i;
                  return GestureDetector(
                    onTap: () => controller.setCategory(i),
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
                        controller.categories[i],
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'search_sort_by'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            Obx(
              () => Column(
                children: [
                  RadioListTile<SortBy>(
                    value: SortBy.terpopuler,
                    groupValue: controller.sortBy.value,
                    onChanged: (v) => controller.setSort(v!),
                    title: Text('search_sort_popular'.tr),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryNavy,
                  ),
                  RadioListTile<SortBy>(
                    value: SortBy.terbaru,
                    groupValue: controller.sortBy.value,
                    onChanged: (v) => controller.setSort(v!),
                    title: Text('search_sort_newest'.tr),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryNavy,
                  ),
                  RadioListTile<SortBy>(
                    value: SortBy.ratingTertinggi,
                    groupValue: controller.sortBy.value,
                    onChanged: (v) => controller.setSort(v!),
                    title: Text('search_sort_top_rated'.tr),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryNavy,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.applyFilter,
                child: Text('search_apply_filter'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}