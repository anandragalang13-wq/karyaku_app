import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Menampilkan ikon bintang + angka rating, misalnya "4.9".
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  const RatingStars({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.star, size: size + 2),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Baris bintang interaktif/statik penuh (dipakai di Detail Buku - ulasan).
class FullRatingStars extends StatelessWidget {
  final double rating;
  final double size;
  const FullRatingStars({super.key, required this.rating, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i && rating < i + 1;
        return Icon(
          half ? Icons.star_half_rounded : Icons.star_rounded,
          color: (filled || half) ? AppColors.star : AppColors.border,
          size: size,
        );
      }),
    );
  }
}
