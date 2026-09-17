import 'package:flutter/material.dart';
import 'book_model.dart';

extension BookModelExtension on BookModel {
  // Factory constructor untuk convert JSON dari Supabase ke BookModel
  static BookModel fromJson(Map<String, dynamic> json) {
    // Generate gradient berdasarkan category
    final category = json['category'] as String? ?? 'Novel';
    final gradient = _getGradientByCategory(category);
    
    // Generate icon berdasarkan category
    final icon = _getIconByCategory(category);

    return BookModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'No Title',
      author: json['author'] as String? ?? 'Unknown',
      category: category,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      views: json['views_count'] as int? ?? 0,
      totalChapters: json['total_chapters'] as int? ?? 0,
      currentChapter: json['current_chapter'] as int? ?? 0,
      synopsis: json['synopsis'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List? ?? []),
      status: json['status'] as String? ?? 'Ongoing',
      progress: ((json['current_chapter'] as int? ?? 0) / 
                 (json['total_chapters'] as int? ?? 1))
          .clamp(0.0, 1.0),
      coverGradient: gradient,
      coverIcon: icon,
    );
  }

  // Helper: Generate gradient berdasarkan category
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

  // Helper: Generate icon berdasarkan category
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