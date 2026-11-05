import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Halaman Profil tetap bisa dibuka tanpa login, tapi kontennya
      // dibatasi hanya Pengaturan, Bantuan & Umpan Balik, dan Jadi Penulis.
      if (!controller.isLoggedIn) {
        return _buildGuestScreen();
      }
      return _buildProfileScreen();
    });
  }

  Widget _buildProfileScreen() {
    final user = controller.user;
    final bool isWriter = controller.isWriter;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            Row(
              children: [
                const Spacer(),
                Text('profile_title'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: controller.openSettings,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD8E3F0), Color(0xFFB9C6D6)],
                      ),
                      border: Border.all(color: AppColors.surface, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.border,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 46, color: AppColors.primaryNavy),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(user.name,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            ),
            Center(
              child: Text(user.email,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 15, color: AppColors.accentOrange),
                    const SizedBox(width: 4),
                    Text(user.badge,
                        style: const TextStyle(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Statistik pembaca hanya ditampilkan untuk penulis
            if (isWriter)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _StatColumn(value: '${user.karyaDibaca}', label: 'profile_works_read'.tr),
                        _vDivider(),
                        _StatColumn(value: '${user.koleksi}', label: 'profile_collection'.tr),
                        _vDivider(),
                        _StatColumn(
                            value: '${(user.pengikut / 1000).toStringAsFixed(1)}k',
                            label: 'profile_followers'.tr),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            // Section Pusat Penulis / Jadi Penulis
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWriter ? 'profile_writer_hub'.tr : 'profile_become_author'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isWriter
                        ? 'profile_writer_hub_desc'.tr
                        : 'profile_become_author_desc'.tr,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: isWriter
                        ? controller.addNewWork
                        : controller.goToWriterRegistration,
                    icon: Icon(isWriter ? Icons.add : Icons.edit, size: 18),
                    label: Text(
                      isWriter
                          ? 'add_work_title'.tr
                          : 'author_signup_title'.tr,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ProfileMenuTile(
              icon: Icons.settings_outlined,
              label: 'profile_app_settings'.tr,
              onTap: controller.openSettings,
            ),
            // Menu Kelola Karya (draft + statistik buku) hanya untuk penulis
            if (isWriter)
              _ProfileMenuTile(
                icon: Icons.auto_stories_rounded,
                label: 'profile_manage_works'.tr,
                onTap: controller.openKelolaKarya,
              ),
            _ProfileMenuTile(
              icon: Icons.help_outline_rounded,
              label: 'profile_help_center'.tr,
              onTap: controller.openHelp,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                label: Text('profile_logout'.tr,
                    style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilan Profil untuk guest (belum login): tetap bisa dibuka, hanya
  // berisi CTA Masuk/Daftar + menu Pengaturan, Bantuan & Umpan Balik,
  // dan Jadi Penulis (tanpa data akun/statistik).
  Widget _buildGuestScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            Text('profile_title'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.goToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('profile_login_register'.tr,
                        style:
                            const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'profile_login_prompt'.tr,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 28),
            _ProfileMenuTile(
              icon: Icons.settings_outlined,
              label: 'profile_settings'.tr,
              onTap: controller.openSettings,
            ),
            _ProfileMenuTile(
              icon: Icons.headset_mic_outlined,
              label: 'profile_help_feedback'.tr,
              onTap: controller.openHelp,
            ),
            _ProfileMenuTile(
              icon: Icons.edit_note_rounded,
              label: 'profile_become_author'.tr,
              onTap: controller.goToWriterRegistration,
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 36, color: AppColors.border);
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileMenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryNavy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}