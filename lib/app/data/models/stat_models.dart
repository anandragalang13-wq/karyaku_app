import 'package:flutter/material.dart';

/// Titik data untuk grafik tren pembaca harian.
class DailyStatPoint {
  final String dayLabel;
  final double value;
  final bool highlighted;

  const DailyStatPoint({
    required this.dayLabel,
    required this.value,
    this.highlighted = false,
  });
}

/// Baris "Karya Terpopuler" pada halaman Statistik Pembaca.
class PopularWorkStat {
  final String title;
  final String category;
  final String views;
  final String delta;

  /// Foto cover buku dari folder `assets/images/`.
  final String cover;

  final List<Color> coverGradient;

  const PopularWorkStat({
    required this.title,
    required this.category,
    required this.views,
    required this.delta,
    required this.cover,
    required this.coverGradient,
  });
}

/// Kartu ringkasan statistik (Total Pembaca, Total Ulasan, dst).
class StatSummary {
  final String title;
  final String value;
  final String delta;
  final bool isPositive;
  final bool isStable;

  const StatSummary({
    required this.title,
    required this.value,
    required this.delta,
    this.isPositive = true,
    this.isStable = false,
  });
}
