import 'package:flutter/material.dart';
import 'review_model.dart';

extension ReviewModelExtension on ReviewModel {
  static ReviewModel fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      name: json['user_name'] as String? ?? 'Anonymous',
      avatarColor: _getColorFromUserId(json['user_id'] as String? ?? ''),
      rating: json['rating'] as int? ?? 5,
      timeAgo: _formatTimeAgo(json['created_at'] as String?),
      comment: json['comment'] as String? ?? '',
      likes: json['likes_count'] as int? ?? 0,
    );
  }

  // Helper: Generate warna avatar dari user ID
  static Color _getColorFromUserId(String userId) {
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFFf093fb),
      const Color(0xFF4facfe),
      const Color(0xFFfa709a),
      const Color(0xFF30cfd0),
      const Color(0xFFfee140),
    ];
    
    if (userId.isEmpty) return colors[0];
    
    final hash = userId.codeUnits.reduce((a, b) => a + b);
    return colors[hash % colors.length];
  }

  // Helper: Convert timestamp ke "time ago" format
  static String _formatTimeAgo(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Baru saja';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d lalu';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w lalu';
      } else {
        final months = (difference.inDays / 30).floor();
        return '${months}mo lalu';
      }
    } catch (e) {
      return 'Baru saja';
    }
  }
}