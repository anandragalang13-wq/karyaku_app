import 'package:flutter/material.dart';

import 'book_model.dart';

extension BookModelExtension on BookModel {
  // Factory untuk convert JSON dari Supabase (tabel `books`) ke BookModel
  static BookModel fromJson(Map<String, dynamic> json) {
    final category = json['category'] as String? ?? 'Novel';
    final totalChapters = (json['total_chapters'] as num?)?.toInt() ?? 0;
    final currentChapter = (json['current_chapter'] as num?)?.toInt() ?? 0;
    final progress = totalChapters > 0
        ? (currentChapter / totalChapters).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'No Title',
      author: json['author'] as String? ?? 'Unknown',
      category: category,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      views: (json['views_count'] as num?)?.toInt() ?? 0,
      totalChapters: totalChapters,
      currentChapter: currentChapter,
      synopsis: json['synopsis'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List? ?? []),
      status: json['status'] as String? ?? 'Ongoing',
      progress: progress,
      coverGradient: _getGradientByCategory(category),
      coverIcon: _getIconByCategory(category),
      // Cover dari database; kalau kosong, BookModel.coverAsset otomatis
      // mengisi dengan foto dari folder assets berdasarkan judul.
      coverAsset: json['cover_asset'] as String?,
    );
  }

  static List<Color> _getGradientByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'novel':
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case 'puisi':
        return [const Color(0xFFf093fb), const Color(0xFFf5576c)];
      case 'cerpen':
        return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
      case 'drama':
        return [const Color(0xFFfa709a), const Color(0xFFfee140)];
      case 'fiksi ilmiah':
        return [const Color(0xFF30cfd0), const Color(0xFF330867)];
      default:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
  }

  
  static IconData _getIconByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'novel':
        return Icons.menu_book_rounded;
      case 'puisi':
        return Icons.favorite_rounded;
      case 'cerpen':
        return Icons.description_rounded;
      case 'drama':
        return Icons.theater_comedy_rounded;
      case 'fiksi ilmiah':
        return Icons.science_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}
