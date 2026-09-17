import 'package:flutter/material.dart';

/// Model utama untuk sebuah karya sastra (novel, puisi, atau cerpen).
class BookModel {
  final String id;
  final String title;
  final String author;
  final String category; // Novel, Puisi, Cerpen
  final double rating;
  final int views;
  final int totalChapters;
  final int currentChapter;
  final String synopsis;
  final List<String> tags;
  final String status; // Ongoing, Selesai
  final double progress; // 0.0 - 1.0, dipakai di Histori
  final List<Color> coverGradient;
  final IconData coverIcon;

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
  });

  String get progressLabel => '${(progress * 100).round()}%';
  String get chapterLabel => 'Bab $currentChapter/$totalChapters';

  /// Factory constructor untuk mapping data JSON dari Supabase
  factory BookModel.fromJson(Map<String, dynamic> json) {
    final int totalCh = json['total_chapters'] ?? 0;
    final int currentCh = json['current_chapter'] ?? 0;
    
    // Hitung progress membaca secara manual jika tidak ada di JSON
    final double calcProgress = totalCh > 0 ? (currentCh / totalCh) : 0.0;

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
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
      // Default gradient jika tidak disimpan di database
      coverGradient: const [
        Color(0xFF6A11CB),
        Color(0xFF2575FC),
      ],
      coverIcon: Icons.menu_book_rounded,
    );
  }

  /// Mengonversi instance BookModel menjadi Map JSON (untuk dikirim ke Supabase)
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
    };
  }

  /// Method copyWith untuk mempermudah update state di GetX
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
    );
  }
}