import 'package:flutter/material.dart';
import 'package:karyaku_app/app/data/models/work_model.dart';
import 'package:karyaku_app/app/theme/app_colors.dart';

/// Kartu khusus untuk Puisi tanpa cover.
/// Menggunakan desain tipografi estetis dengan bait pertama sebagai preview,
/// aksen warna tema, dan latar belakang gradien lembut.
class PoetryCard extends StatelessWidget {
  final WorkModel work;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const PoetryCard({
    super.key,
    required this.work,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final firstVerse = _extractFirstVerse(work.content);
    final themeColor = _getThemeColor(work.tags);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              themeColor.withValues(alpha: 0.15),
              themeColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: themeColor.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dekorasi latar: garis-garis tipografi halus
            Positioned.fill(
              child: CustomPaint(
                painter: _PoetryBackgroundPainter(
                  color: themeColor.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Aksen warna di kiri
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),
            // Konten utama
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge "Puisi"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 12,
                          color: themeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Puisi',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: themeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Judul Puisi
                  Text(
                    work.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bait pertama sebagai preview
                  if (firstVerse.isNotEmpty) ...[
                    Text(
                      '"$firstVerse"',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Spacer(),
                  // Footer: penulis & tag pertama
                  Row(
                    children: [
                      if (work.authorName != null) ...[
                        Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            work.authorName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      if (work.tags.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            work.tags.first,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ekstrak bait pertama (baris non-kosong pertama) dari isi puisi
  String _extractFirstVerse(String content) {
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return '';
    // Ambil 1-2 baris pertama, batasi panjang
    final firstLines = lines.take(2).join(' / ');
    return firstLines.length > 80 ? '${firstLines.substring(0, 77)}...' : firstLines;
  }

  /// Dapatkan warna tema berdasarkan tag pertama atau default
  Color _getThemeColor(List<String> tags) {
    if (tags.isEmpty) return AppColors.badgePuisi;
    final tag = tags.first.toLowerCase();
    if (tag.contains('cinta') || tag.contains('romantis') || tag.contains('love')) {
      return const Color(0xFFE91E63); // Pink
    }
    if (tag.contains('malam') || tag.contains('gelap') || tag.contains('night')) {
      return const Color(0xFF673AB7); // Deep Purple
    }
    if (tag.contains('alam') || tag.contains('nature') || tag.contains('hijau')) {
      return const Color(0xFF4CAF50); // Green
    }
    if (tag.contains('sedih') || tag.contains('galau') || tag.contains('duka')) {
      return const Color(0xFF2196F3); // Blue
    }
    if (tag.contains('harapan') || tag.contains('semangat') || tag.contains('motivasi')) {
      return const Color(0xFFFF9800); // Orange
    }
    return AppColors.badgePuisi; // Default purple
  }
}

/// Painter untuk latar belakang tipografi halus (garis-garis mirip kertas tulis)
class _PoetryBackgroundPainter extends CustomPainter {
  final Color color;

  _PoetryBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    // Garis horizontal halus (seperti kertas tulis)
    const spacing = 24.0;
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Garis vertikal halus di sisi kiri (margin kertas)
    final marginX = 48.0;
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      paint..color = color.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kartu Puisi versi horizontal (untuk list horizontal di beranda)
class PoetryCardHorizontal extends StatelessWidget {
  final WorkModel work;
  final VoidCallback? onTap;

  const PoetryCardHorizontal({
    super.key,
    required this.work,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstVerse = _extractFirstVerse(work.content);
    final themeColor = _getThemeColor(work.tags);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              themeColor.withValues(alpha: 0.15),
              themeColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: themeColor.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            // Aksen warna di kiri
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge "Puisi"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 10,
                          color: themeColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Puisi',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Judul
                  Text(
                    work.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Preview bait pertama
                  if (firstVerse.isNotEmpty) ...[
                    Flexible(
                      child: Text(
                        '"$firstVerse"',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Footer
                  if (work.authorName != null)
                    Text(
                      work.authorName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractFirstVerse(String content) {
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return '';
    final firstLines = lines.take(2).join(' / ');
    return firstLines.length > 60 ? '${firstLines.substring(0, 57)}...' : firstLines;
  }

  Color _getThemeColor(List<String> tags) {
    if (tags.isEmpty) return AppColors.badgePuisi;
    final tag = tags.first.toLowerCase();
    if (tag.contains('cinta') || tag.contains('romantis') || tag.contains('love')) {
      return const Color(0xFFE91E63);
    }
    if (tag.contains('malam') || tag.contains('gelap') || tag.contains('night')) {
      return const Color(0xFF673AB7);
    }
    if (tag.contains('alam') || tag.contains('nature') || tag.contains('hijau')) {
      return const Color(0xFF4CAF50);
    }
    if (tag.contains('sedih') || tag.contains('galau') || tag.contains('duka')) {
      return const Color(0xFF2196F3);
    }
    if (tag.contains('harapan') || tag.contains('semangat') || tag.contains('motivasi')) {
      return const Color(0xFFFF9800);
    }
    return AppColors.badgePuisi;
  }
}