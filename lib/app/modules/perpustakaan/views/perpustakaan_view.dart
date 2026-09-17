import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                  Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                  const SizedBox(width: 14),
                  Text('KARYAKU',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  Icon(Icons.search_rounded, color: AppColors.textPrimary),
                ],
              ),
            ),
            _TopTabs(controller: controller),
            const SizedBox(height: 12),
            _CategoryFilterRow(controller: controller),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(
                () => controller.tabIndex.value == 0
                    ? _HistoriList(controller: controller)
                    : _KoleksiGrid(controller: controller),
              ),
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
            label: 'Histori',
            selected: controller.tabIndex.value == 0,
            onTap: () => controller.changeTab(0),
          ),
          _TabButton(
            label: 'Koleksi',
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
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Filter',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
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
      if (list.isEmpty) {
        return const Center(child: Text('Belum ada histori bacaan.'));
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
                  BookCover(
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
                                      fontWeight: FontWeight.w700, fontSize: 15)),
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
                            Text('Progres Bacaan',
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filteredCollection;
      return GridView.builder(
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
              onTap: controller.addCollection,
              child: DottedAddCard(),
            );
          }
          final book = list[i];
          return GestureDetector(
            onTap: () => controller.openBookDetail(book),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: BookCover(
                          gradient: book.coverGradient,
                          icon: book.coverIcon,
                          borderRadius: 12,
                        ),
                      ),
                      Positioned(
                          top: 8, left: 8, child: CategoryBadge(category: book.category)),
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
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
          Text('Tambah Koleksi',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
