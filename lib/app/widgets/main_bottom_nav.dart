import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

/// Bottom navigation bar yang konsisten dipakai di seluruh halaman utama:
/// Histori, Temukan, Beranda, Profil.
class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static List<_NavItemData> get _items => [
        _NavItemData(icon: Icons.home_rounded, label: 'nav_home'.tr),
        _NavItemData(icon: Icons.history_rounded, label: 'nav_library'.tr),
        _NavItemData(icon: Icons.explore_outlined, label: 'nav_discover'.tr),
        _NavItemData(icon: Icons.person_outline_rounded, label: 'nav_profile'.tr),
      ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: List.generate(_items.length, (i) {
            final selected = i == currentIndex;
            final item = _items[i];
            final color =
                selected ? AppColors.accentBlue : AppColors.textMuted;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  _NavItemData({required this.icon, required this.label});
}