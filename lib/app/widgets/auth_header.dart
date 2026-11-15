import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Header navy dengan logo KARYAKU, dipakai bersama di halaman Login & Register.
class AuthHeader extends StatelessWidget {
  final String subtitle;
  const AuthHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryNavy, Color(0xFF0B1526)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // Kotak putih membuat logo (yang berwarna navy) terlihat
              // jelas dan kontras di atas header yang gelap.
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primaryNavy,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'KARYAKU',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
