import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/work_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/book_cover.dart';
import '../controllers/kelola_karya_controller.dart';

/// Halaman "Kelola Karya": daftar cerita draft yang bisa dilanjutkan menulis
/// bab baru + statistik setiap buku milik penulis (pembaca, rating, bab,
/// ulasan).
class KelolaKaryaView extends GetView<KelolaKaryaController> {
  const KelolaKaryaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
        ),
        title: Text('stats_title'.tr,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (!controller.isLoggedIn) return const _LoginPrompt();

        if (controller.isLoading.value && controller.works.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.works.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadData,
          );
        }

        if (controller.works.isEmpty) {
          return _EmptyState(onAdd: controller.openAddWork);
        }

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              _buildSummary(context),
              const SizedBox(height: 24),
              _buildContinueSection(context),
              const SizedBox(height: 24),
              _buildStatsSection(context),
            ],
          ),
        );
      }),
    );
  }

  // ------------------------------------------------------------------
  // RINGKASAN
  // ------------------------------------------------------------------

  Widget _buildSummary(BuildContext context) {
    final summaries = [
      _SummaryData(
        icon: Icons.menu_book_rounded,
        value: '${controller.works.length}',
        label: 'manage_works_total_works'.tr,
      ),
      _SummaryData(
        icon: Icons.edit_note_rounded,
        value: '${controller.draftWorks.length}',
        label: 'manage_works_active_drafts'.tr,
      ),
      _SummaryData(
        icon: Icons.remove_red_eye_rounded,
        value: KelolaKaryaController.formatCount(controller.totalViews),
        label: 'manage_works_total_readers'.tr,
      ),
      _SummaryData(
        icon: Icons.star_rounded,
        value: controller.averageRating.toStringAsFixed(1),
        label: 'manage_works_avg_rating'.tr,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.55,
      children: summaries.map((s) => _SummaryCard(data: s)).toList(),
    );
  }

  // ------------------------------------------------------------------
  // LANJUTKAN MENULIS (DRAFT)
  // ------------------------------------------------------------------

  Widget _buildContinueSection(BuildContext context) {
    final drafts = controller.draftWorks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'manage_works_continue_section'.tr,
          subtitle: 'manage_works_continue_subtitle'.tr,
        ),
        const SizedBox(height: 12),
        if (drafts.isEmpty)
          _EmptyDraftCard(onAdd: controller.openAddWork)
        else
          ...drafts.map((work) => _DraftCard(
                work: work,
                chapters: controller.chapterCountOf(work),
                onWrite: () => controller.openStoryProgress(work),
                onDelete: () => controller.confirmDeleteWork(work),
              )),
      ],
    );
  }

  // ------------------------------------------------------------------
  // STATISTIK KARYA
  // ------------------------------------------------------------------

  Widget _buildStatsSection(BuildContext context) {
    final chartWorks = controller.chartWorks;
    final statWorks = controller.statWorks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'manage_works_stats_section'.tr,
          subtitle: 'manage_works_stats_subtitle'.tr,
        ),
        if (chartWorks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('manage_works_chart_title'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40.0 + chartWorks.length * 42,
                  child: _ViewsBarChart(works: chartWorks),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...statWorks.map((work) => _WorkStatCard(
              work: work,
              chapters: controller.chapterCountOf(work),
              reviews: controller.reviewCountOf(work),
              onDelete: () => controller.confirmDeleteWork(work),
            )),
      ],
    );
  }
}

// ======================================================================
// WIDGET BERSAMA
// ======================================================================

class _SummaryData {
  final IconData icon;
  final String value;
  final String label;
  const _SummaryData({
    required this.icon,
    required this.value,
    required this.label,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;
  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(data.label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Spacer(),
          Text(data.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 3),
        Text(subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ApprovalStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
            color: status.color,
            fontSize: 11,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.badgeForCategory(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(category,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ======================================================================
// KARTU DRAFT
// ======================================================================

class _DraftCard extends StatelessWidget {
  final WorkModel work;
  final int chapters;
  final VoidCallback onWrite;
  final VoidCallback onDelete;

  const _DraftCard({
    required this.work,
    required this.chapters,
    required this.onWrite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCoverImage(
                coverAsset: work.cover,
                gradient: _gradientFor(work),
                width: 46,
                height: 64,
                borderRadius: 8,
                iconSize: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(work.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _CategoryBadge(category: work.type.label),
                        _StatusChip(status: work.approvalStatus),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'manage_works_chapters_written'
                          .trArgs(['$chapters']),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDelete,
                tooltip: 'manage_works_delete'.tr,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 20, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onWrite,
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: Text('manage_works_edit_work'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// KARTU STATISTIK KARYA
// ======================================================================

class _WorkStatCard extends StatelessWidget {
  final WorkModel work;
  final int chapters;
  final int reviews;
  final VoidCallback onDelete;

  const _WorkStatCard({
    required this.work,
    required this.chapters,
    required this.reviews,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _MiniStat(
        label: 'manage_works_views'.tr,
        value: KelolaKaryaController.formatCount(work.views),
      ),
      _MiniStat(
        label: 'manage_works_rating'.tr,
        value: work.rating.toStringAsFixed(1),
      ),
      _MiniStat(label: 'manage_works_chapters'.tr, value: '$chapters'),
      _MiniStat(label: 'manage_works_reviews'.tr, value: '$reviews'),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BookCoverImage(
                coverAsset: work.cover,
                gradient: _gradientFor(work),
                width: 40,
                height: 56,
                borderRadius: 8,
                iconSize: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(work.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _CategoryBadge(category: work.type.label),
                        _StatusChip(status: work.approvalStatus),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDelete,
                tooltip: 'manage_works_delete'.tr,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 20, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                for (final item in items) ...[
                  Expanded(child: item),
                  if (item != items.last) Container(width: 1, height: 26, color: AppColors.border),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ======================================================================
// GRAFIK BATANG (PEMBACA PER KARYA)
// ======================================================================

class _ViewsBarChart extends StatelessWidget {
  final List<WorkModel> works;
  const _ViewsBarChart({required this.works});

  @override
  Widget build(BuildContext context) {
    final maxValue =
        works.map((w) => w.views).reduce((a, b) => a > b ? a : b);
    final interval = maxValue <= 0 ? 1.0 : (maxValue / 2).ceilToDouble();

    return BarChart(
      BarChartData(
        maxY: maxValue <= 0 ? 1 : maxValue * 1.15,
        barTouchData: BarTouchData(enabled: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 96,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= works.length) return const SizedBox.shrink();
                final title = works[i].title;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    title.length > 14 ? '${title.substring(0, 14)}…' : title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  KelolaKaryaController.formatCount(value),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < works.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: works[i].views.toDouble(),
                  width: 14,
                  borderRadius: BorderRadius.circular(5),
                  color: i == 0
                      ? AppColors.accentBlue
                      : AppColors.accentBlue.withOpacity(0.45),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ======================================================================
// STATE KOSONG / ERROR / LOGIN
// ======================================================================

class _EmptyDraftCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyDraftCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: const Icon(Icons.edit_note_rounded,
                size: 26, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Text('manage_works_empty_draft_title'.tr,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            'manage_works_empty_draft_desc'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text('manage_works_add_new'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryNavy,
              side: const BorderSide(color: AppColors.primaryNavy),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: const Icon(Icons.auto_stories_rounded,
                  size: 34, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Text('manage_works_empty_title'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              'manage_works_empty_desc'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('manage_works_add_new'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 34, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('manage_works_retry'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                side: const BorderSide(color: AppColors.primaryNavy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KelolaKaryaController>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 32, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Text('manage_works_login_title'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              'manage_works_login_desc'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: controller.goToLogin,
              icon: const Icon(Icons.login_rounded, size: 18),
              label: Text('manage_works_login_button'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// HELPER
// ======================================================================

/// Gradasi placeholder cover berdasarkan kategori karya.
List<Color> _gradientFor(WorkModel work) {
  switch (work.type) {
    case WorkType.puisi:
      return const [Color(0xFF1D5FBF), Color(0xFF0E2E63)];
    case WorkType.cerpen:
      return const [Color(0xFF2E9E5B), Color(0xFF14512F)];
    case WorkType.novel:
      return const [Color(0xFF1F3A5F), Color(0xFF0B1526)];
  }
}
