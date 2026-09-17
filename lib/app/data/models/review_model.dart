import 'package:flutter/material.dart';

/// Model ulasan / komentar pembaca pada sebuah karya.
class ReviewModel {
  final String name;
  final Color avatarColor;
  final int rating;
  final String timeAgo;
  final String comment;
  final int likes;

  const ReviewModel({
    required this.name,
    required this.avatarColor,
    required this.rating,
    required this.timeAgo,
    required this.comment,
    required this.likes,
  });
}
