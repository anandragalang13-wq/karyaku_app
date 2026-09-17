import 'package:get/get.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/stat_models.dart';

/// Controller halaman Statistik Karya & Pembaca (dashboard penulis).
class StatistikController extends GetxController {
  final RxString selectedPeriod = '7 Hari Terakhir'.obs;
  final periods = const ['7 Hari Terakhir', '30 Hari Terakhir', '3 Bulan Terakhir'];

  final List<StatSummary> summaries = MockData.statSummaries;
  final List<DailyStatPoint> trend = MockData.weeklyTrend;
  final List<PopularWorkStat> popularWorks = MockData.statPopularWorks;

  void changePeriod(String p) => selectedPeriod.value = p;
}
