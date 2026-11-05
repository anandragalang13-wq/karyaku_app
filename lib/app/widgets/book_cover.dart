import 'package:flutter/material.dart';

/// Widget cover buku dengan dukungan:
/// - [coverAsset]: path gambar asset lokal (prioritas utama)
/// - [coverUrl]: URL gambar jaringan (fallback kedua)
/// - [gradient] + [icon]: placeholder gradient jika tidak ada gambar
class BookCoverImage extends StatelessWidget {
  final String? coverAsset;
  final String? coverUrl;
  final List<Color> gradient;
  final IconData icon;
  final double borderRadius;
  final double? width;
  final double? height;
  final double iconSize;

  const BookCoverImage({
    super.key,
    this.coverAsset,
    this.coverUrl,
    required this.gradient,
    this.icon = Icons.menu_book_rounded,
    this.borderRadius = 12,
    this.width,
    this.height,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    final isRemote = coverAsset != null &&
        (coverAsset!.startsWith('http://') || coverAsset!.startsWith('https://'));

    if (isRemote) {
      // Cover dari Supabase Storage tersimpan sebagai URL di kolom cover_asset.
      imageWidget = Image.network(
        coverAsset!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (coverAsset != null && coverAsset!.isNotEmpty) {
      imageWidget = Image.asset(
        coverAsset!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (coverUrl != null && coverUrl!.isNotEmpty) {
      imageWidget = Image.network(
        coverUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      imageWidget = _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: imageWidget),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
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

/// Widget lama — dipertahankan supaya tidak ada yang error.
/// Gunakan [BookCoverImage] untuk tampilan dengan dukungan gambar.
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