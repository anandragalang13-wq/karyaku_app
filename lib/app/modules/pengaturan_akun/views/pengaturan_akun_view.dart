import 'package:flutter/material.dart';  
import 'package:get/get.dart';

import '../../../services/locale_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../controllers/pengaturan_akun_controller.dart';

class PengaturanAkunView extends GetView<PengaturanAkunController> {
  const PengaturanAkunView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
        ),
        title: Text('settings_title'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsCard(
            title: 'settings_account_section'.tr,
            children: [
              _NavRow(label: 'settings_edit_profile'.tr, onTap: () {}),
              const Divider(height: 20),
              _NavRow(label: 'settings_change_password'.tr, onTap: () {}),
              const Divider(height: 20),
              Obx(
                () => _SwitchRow(
                  label: 'settings_notifications'.tr,
                  value: controller.notifEnabled.value,
                  onChanged: controller.toggleNotif,
                ),
              ),
              const Divider(height: 20),
              _LanguageRow(controller: controller),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            title: 'settings_reading_preferences'.tr,
            children: [
              Text('settings_theme'.tr,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  children: ReaderTheme.values.map((t) {
                    final selected = controller.selectedTheme.value == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: GestureDetector(
                        onTap: () => controller.selectTheme(t),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: t.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppColors.accentBlue
                                  : AppColors.border,
                              width: selected ? 2.5 : 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text('settings_font_size'.tr,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Obx(
                () => Row(
                  children: [
                    const Text('A-', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: controller.fontSize.value,
                        min: 12,
                        max: 24,
                        activeColor: AppColors.primaryNavy,
                        onChanged: controller.changeFontSize,
                      ),
                    ),
                    const Text('A+', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            title: 'settings_storage_data'.tr,
            children: [
              _NavRow(
                label: '${'settings_clear_cache'.tr} (${controller.cacheSize})',
                onTap: controller.clearCache,
              ),
              const Divider(height: 20),
              Obx(
                () => _SwitchRow(
                  label: 'settings_wifi_only_download'.tr,
                  value: controller.wifiOnlyDownload.value,
                  onChanged: controller.toggleWifiOnly,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            title: 'settings_support_info'.tr,
            children: [
              _NavRow(label: 'settings_help_center'.tr, onTap: () {}),
              const Divider(height: 20),
              _NavRow(label: 'settings_privacy_policy'.tr, onTap: () {}),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('settings_app_version'.tr,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('v1.0', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: Text('settings_logout'.tr,
                  style: const TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// Baris "Bahasa" dengan dropdown EN/ID. Memilih salah satu langsung
/// mengganti bahasa seluruh aplikasi lewat [PengaturanAkunController].
class _LanguageRow extends StatelessWidget {
  final PengaturanAkunController controller;
  const _LanguageRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('settings_language'.tr, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                'settings_language_subtitle'.tr,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AppLanguage>(
                value: controller.selectedLanguage.value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                borderRadius: BorderRadius.circular(10),
                items: AppLanguage.values.map((lang) {
                  return DropdownMenuItem<AppLanguage>(
                    value: lang,
                    child: Text(
                      lang.shortLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (lang) {
                  if (lang != null) controller.changeLanguage(lang);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accentBlue,
        ),
      ],
    );
  }
}