import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/book_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/book_cover.dart';
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => controller.searchText.value = v,
                              decoration: InputDecoration(
                                hintText: 'search_hint'.tr,
                                border: InputBorder.none,
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
                        color: AppColors.primaryNavy,
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