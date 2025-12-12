import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/audio_controller.dart';

class DownloadManagerWidget extends StatelessWidget {
  const DownloadManagerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.download, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'إدارة التحميلات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // مؤشر التحميل الحالي
          Obx(() {
            if (audioController.isDownloading.value) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircularProgressIndicator(strokeWidth: 2),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'جاري تحميل ${audioController.selectedReciter.value}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: audioController.downloadProgress.value,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(audioController.downloadProgress.value * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 16),

          // قائمة السور للتحميل
          Text(
            'تحميل السور',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),

          // أزرار تحميل سريع
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickDownloadButton('الفاتحة', 1, audioController),
              _buildQuickDownloadButton('البقرة', 2, audioController),
              _buildQuickDownloadButton('آل عمران', 3, audioController),
              _buildQuickDownloadButton('النساء', 4, audioController),
              _buildQuickDownloadButton('المائدة', 5, audioController),
            ],
          ),

          const SizedBox(height: 16),

          // زر تحميل مخصص
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCustomDownloadDialog(),
              icon: const Icon(Icons.download_for_offline),
              label: const Text('تحميل سورة مخصصة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDownloadButton(
      String name, int surahNumber, AudioController controller) {
    return Obx(() => ElevatedButton(
          onPressed: controller.isDownloading.value
              ? null
              : () => controller.downloadSurah(surahNumber),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(name, style: const TextStyle(fontSize: 12)),
        ));
  }

  void _showCustomDownloadDialog() {
    final TextEditingController surahController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('تحميل سورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل رقم السورة (1-114):'),
            const SizedBox(height: 8),
            TextField(
              controller: surahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'رقم السورة',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final surahNumber = int.tryParse(surahController.text);
              if (surahNumber != null &&
                  surahNumber >= 1 &&
                  surahNumber <= 114) {
                Get.back();
                Get.find<AudioController>().downloadSurah(surahNumber);
              } else {
                Get.snackbar('خطأ', 'رقم السورة غير صحيح');
              }
            },
            child: const Text('تحميل'),
          ),
        ],
      ),
    );
  }
}
