import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/stat_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/book_cover.dart';
import '../controllers/statistik_controller.dart';

class StatistikView extends GetView<StatistikController> {
  const StatistikView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
        ),
        title: const Text('Statistik Karya & Pembaca',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Periode',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Obx(
                () => PopupMenuButton<String>(
                  onSelected: controller.changePeriod,
                  itemBuilder: (context) => controller.periods
                      .map((p) => PopupMenuItem(value: p, child: Text(p)))
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(controller.selectedPeriod.value,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.55,
            children: controller.summaries.map((s) => _StatCard(stat: s)).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tren Pembaca Harian',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: _TrendBarChart(points: controller.trend),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Karya Terpopuler',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const Text('Lihat Semua',
                  style: TextStyle(
                      color: AppColors.accentBlue, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...controller.popularWorks.map((w) => _PopularWorkTile(work: w)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatSummary stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (stat.title) {
      case 'Total Pembaca':
        icon = Icons.groups_rounded;
        break;
      case 'Total Ulasan':
        icon = Icons.forum_rounded;
        break;
      case 'Bookmark':
        icon = Icons.bookmark_rounded;
        break;
      default:
        icon = Icons.favorite_rounded;
    }
    final deltaColor = stat.isStable
        ? AppColors.textMuted
        : (stat.isPositive ? AppColors.success : AppColors.danger);

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
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(stat.title,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Spacer(),
          Text(stat.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Row(
            children: [
              if (!stat.isStable)
                Icon(Icons.trending_up_rounded, size: 13, color: deltaColor)
              else
                Icon(Icons.trending_flat_rounded, size: 13, color: deltaColor),
              const SizedBox(width: 2),
              Expanded(
                child: Text(stat.delta,
                    style: TextStyle(color: deltaColor, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendBarChart extends StatelessWidget {
  final List<DailyStatPoint> points;
  const _TrendBarChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxVal = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: maxVal * 1.25,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxVal / 3,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                final p = points[i];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    p.dayLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: p.highlighted ? FontWeight.w800 : FontWeight.w400,
                      color: p.highlighted ? AppColors.primaryNavy : AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(points.length, (i) {
          final p = points[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: p.value,
                width: 20,
                borderRadius: BorderRadius.circular(6),
                color: p.highlighted ? AppColors.accentBlue : AppColors.accentBlue.withOpacity(0.35),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PopularWorkTile extends StatelessWidget {
  final PopularWorkStat work;
  const _PopularWorkTile({required this.work});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          BookCover(
            gradient: work.coverGradient,
            width: 44,
            height: 60,
            borderRadius: 8,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(work.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(work.views,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.badgeForCategory(work.category).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(work.category,
                    style: TextStyle(
                        color: AppColors.badgeForCategory(work.category),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Text(work.delta,
                  style: const TextStyle(
                      color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
