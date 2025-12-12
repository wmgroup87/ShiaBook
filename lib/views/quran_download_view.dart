import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/quran_controller.dart';
import 'package:shia_book/services/quran_download_service.dart';

class QuranDownloadView extends StatelessWidget {
  const QuranDownloadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحميل السور'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildReciterSelector(),
          _buildSurahsList(),
        ],
      ),
    );
  }

  Widget _buildReciterSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.white),
          const SizedBox(width: 12),
          const Text(
            'القارئ المختار',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          GetBuilder<QuranController>(
            id: 'reciter_selector',
            builder: (controller) => DropdownButton<String>(
              value: controller.audioController.selectedReciter.value,
              dropdownColor: AppColors.primary,
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(
                height: 2,
                color: Colors.white,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.audioController.changeReciter(newValue);
                  controller.update(['reciter_selector', 'surah_list']);
                }
              },
              items: controller.audioController.availableReciters
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahsList() {
    return Expanded(
      child: GetBuilder<QuranController>(
        id: 'surah_list',
        builder: (controller) {
          final surahs = controller.getUniqueSurahs();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              return _buildSurahCard(surah, controller);
            },
          );
        },
      ),
    );
  }

  Widget _buildSurahCard(Map<String, dynamic> surah, QuranController controller) {
    return FutureBuilder<bool>(
      future: Get.find<QuranDownloadService>().isSurahDownloaded(
        surah['surahNumber'],
        controller.audioController.selectedReciter.value,
      ),
      builder: (context, snapshot) {
        final isDownloaded = snapshot.data ?? false;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${surah['surahNumber']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              surah['surahName'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${surah['ayahCount']} آية',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                _buildDownloadProgress(surah, controller),
              ],
            ),
            trailing: _buildActionButton(surah, controller, isDownloaded),
          ),
        );
      },
    );
  }

  Widget _buildDownloadProgress(Map<String, dynamic> surah, QuranController controller) {
    return GetBuilder<QuranController>(
      id: 'download_progress_${surah['surahNumber']}',
      builder: (controller) {
        if (controller.audioController.isDownloading.value &&
            controller.audioController.currentAyah.value?['surah'] == surah['surahNumber']) {
          final progress = controller.audioController.downloadProgress.value;
          final totalAyahs = surah['ayahCount'] as int;
          final downloadedAyahs = (progress * totalAyahs).round();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$downloadedAyahs / $totalAyahs',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'جاري تحميل الآيات...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActionButton(Map<String, dynamic> surah, QuranController controller, bool isDownloaded) {
    return isDownloaded
        ? IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              controller.audioController.deleteSurah(surah['surahNumber']);
              controller.update(['surah_list']);
            },
          )
        : IconButton(
            icon: const Icon(Icons.download, color: AppColors.primary),
            onPressed: () {
              controller.audioController.downloadSurah(surah['surahNumber']);
              controller.update(['download_progress_${surah['surahNumber']}']);
            },
          );
  }
} 