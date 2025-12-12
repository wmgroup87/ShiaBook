import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/audio_controller.dart';

class ReciterSelectionWidget extends StatelessWidget {
  const ReciterSelectionWidget({super.key});

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
              Icon(Icons.record_voice_over, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'اختيار القارئ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // القراء الشيعة
          _buildReciterSection(
            'القراء الشيعة',
            [
              'كريم منصوري',
              'ميثم التمار',
              'باسم الكربلائي',
              'أحمد الوائلي',
            ],
            Colors.green,
            audioController,
          ),

          const SizedBox(height: 16),

          // القراء التقليديون
          _buildReciterSection(
            'القراء التقليديون',
            [
              'محمد صديق المنشاوي',
              'محمود خليل الحصري',
            ],
            Colors.blue,
            audioController,
          ),
        ],
      ),
    );
  }

  Widget _buildReciterSection(
    String title,
    List<String> reciters,
    Color color,
    AudioController audioController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...reciters.map((reciter) => Obx(() => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: color,
                    size: 20,
                  ),
                ),
                title: Text(
                  reciter,
                  style: TextStyle(
                    fontWeight: audioController.selectedReciter.value == reciter
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: audioController.selectedReciter.value == reciter
                    ? Icon(Icons.check_circle, color: color)
                    : null,
                selected: audioController.selectedReciter.value == reciter,
                selectedTileColor: color.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => audioController.changeReciter(reciter),
              ),
            ))),
      ],
    );
  }
}
