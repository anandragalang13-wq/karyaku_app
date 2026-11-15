import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../controllers/umpan_balik_controller.dart';

/// Bottom sheet form umpan balik. Dipakai dari halaman Profil
/// (menu "Bantuan & Umpan Balik").
class UmpanBalikSheet extends GetView<UmpanBalikController> {
  const UmpanBalikSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'feedback_title'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: Get.back,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'feedback_desc'.tr,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'feedback_category'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  UmpanBalikController.categoryKeys.length,
                  (i) {
                    final selected =
                        controller.selectedCategoryIndex.value == i;
                    return GestureDetector(
                      onTap: () => controller.selectedCategoryIndex.value = i,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryNavy
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryNavy
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          controller.labelFor(i),
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'feedback_message_label'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.messageController,
              maxLines: 5,
              minLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'feedback_message_hint'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Obx(
              () => controller.errorText.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        controller.errorText.value,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => _submit(context),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text('feedback_submit'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mengirim umpan balik lalu menampilkan notifikasi hasilnya.
  Future<void> _submit(BuildContext context) async {
    final ok = await controller.submit();
    if (!ok) return;

    Get.back();
    Get.snackbar(
      'feedback_success_title'.tr,
      'feedback_success_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }
}
