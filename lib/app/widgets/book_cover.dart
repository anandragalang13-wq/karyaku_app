import 'package:flutter/material.dart';

/// Placeholder sampul buku berbasis gradient + ikon, dipakai di semua
/// halaman sebagai pengganti gambar sampul asli (tidak ada aset network).
class BookCover extends StatelessWidget {
  final List<Color> gradient;
  final IconData icon;
  final double borderRadius;
  final double? width;
  final double? height;
  final double iconSize;

  const BookCover({
    super.key,
    required this.gradient,
    this.icon = Icons.menu_book_rounded,
    this.borderRadius = 12,
    this.width,
    this.height,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white.withOpacity(0.85), size: iconSize),
    );
  }
}
