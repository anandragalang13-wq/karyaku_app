import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../book_covers.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String category;
  final double rating;
  final int views;
  final int totalChapters;
  final int currentChapter;
  final String synopsis;
  final List<String> tags;
  final String status;
  final double progress;
  final List<Color> coverGradient;
  final IconData coverIcon;
  final String? _coverAsset;   // <-- tambah ini

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.rating,
    required this.views,
    required this.totalChapters,
    this.currentChapter = 0,
    required this.synopsis,
    required this.tags,
    this.status = 'Ongoing',
    this.progress = 0.0,
    required this.coverGradient,
    this.coverIcon = Icons.menu_book_rounded,
    String? coverAsset,          // <-- tambah ini
  }) : _coverAsset = coverAsset;

  /// Cover buku. Kalau data aslinya kosong, otomatis mengambil foto dari
  /// folder `assets/images/` berdasarkan judul, jadi setiap buku yang
  /// tampil di aplikasi selalu punya cover foto.
  String? get coverAsset => BookCovers.resolve(cover: _coverAsset, title: title);

  String get progressLabel => '${(progress * 100).round()}%';
  String get chapterLabel => 'Bab $currentChapter/$totalChapters';

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final int totalCh = json['total_chapters'] ?? 0;
    final int currentCh = json['current_chapter'] ?? 0;
    final double calcProgress = totalCh > 0 ? (currentCh / totalCh) : 0.0;
    final String title = json['title'] ?? '';

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: title,
      author: json['author'] ?? '',
      category: json['category'] ?? 'Novel',
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 0.0,
      views: json['views_count'] ?? json['views'] ?? 0,
      totalChapters: totalCh,
      currentChapter: currentCh,
      synopsis: json['synopsis'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      status: json['status'] ?? 'Ongoing',
      progress: (json['progress'] != null)
          ? (json['progress'] as num).toDouble()
          : calcProgress,
      coverGradient: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
      coverIcon: Icons.menu_book_rounded,
      coverAsset: json['cover_asset'] as String?,  // <-- tambah ini
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'rating': rating,
      'views_count': views,
      'total_chapters': totalChapters,
      'current_chapter': currentChapter,
      'synopsis': synopsis,
      'tags': tags,
      'status': status,
      'cover_asset': coverAsset,   // <-- tambah ini
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    double? rating,
    int? views,
    int? totalChapters,
    int? currentChapter,
    String? synopsis,
    List<String>? tags,
    String? status,
    double? progress,
    List<Color>? coverGradient,
    IconData? coverIcon,
    String? coverAsset,    // <-- tambah ini
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      views: views ?? this.views,
      totalChapters: totalChapters ?? this.totalChapters,
      currentChapter: currentChapter ?? this.currentChapter,
      synopsis: synopsis ?? this.synopsis,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      coverGradient: coverGradient ?? this.coverGradient,
      coverIcon: coverIcon ?? this.coverIcon,
      coverAsset: coverAsset ?? this.coverAsset,  // <-- tambah ini
    );
  }
}