import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/audio_controller.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioController>();
    final theme = Theme.of(context);

    return Obx(() {
      final hasCurrentAyah = audioController.currentAyah.value != null;

      if (!hasCurrentAyah) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.95),
              AppColors.primary.withOpacity(0.85),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // معلومات الآية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${audioController.currentAyah.value?['surahName'] ?? ''} - آية ${audioController.currentAyah.value?['ayah'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        audioController.selectedReciter.value,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // أزرار التحكم
            PopupMenuButton<String>(
              icon: Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: theme.primaryColor,
                  size: 18,
                ),
              ),
              onSelected: (reciter) {
                audioController.changeReciter(reciter);
              },
              itemBuilder: (context) {
                return audioController.availableReciters.map((reciter) {
                  return PopupMenuItem(
                    value: reciter,
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color:
                              audioController.selectedReciter.value == reciter
                                  ? theme.primaryColor
                                  : theme.textTheme.bodyMedium?.color,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          reciter,
                          style: TextStyle(
                            color:
                                audioController.selectedReciter.value == reciter
                                    ? theme.primaryColor
                                    : theme.textTheme.bodyMedium?.color,
                            fontWeight:
                                audioController.selectedReciter.value == reciter
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
              tooltip: 'اختيار القارئ',
            ),
            // Auto-play toggle button
            Obx(() => IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: audioController.autoPlayNext.value
                          ? theme.primaryColor.withOpacity(0.2)
                          : theme.dividerColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      audioController.autoPlayNext.value
                          ? Icons.playlist_play
                          : Icons.playlist_play_outlined,
                      color: audioController.autoPlayNext.value
                          ? theme.primaryColor
                          : theme.hintColor,
                      size: 18,
                    ),
                  ),
                  onPressed: () => audioController.toggleAutoPlay(),
                  tooltip: audioController.autoPlayNext.value
                      ? 'إيقاف التشغيل التلقائي'
                      : 'تفعيل التشغيل التلقائي',
                )),

            // السابق
            Obx(() => IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.skip_previous,
                      color: audioController.currentAyah.value != null
                          ? theme.primaryColor
                          : theme.disabledColor,
                    ),
                  ),
                  onPressed: audioController.currentAyah.value != null
                      ? () => audioController.previous()
                      : null,
                  tooltip: 'السابق',
                )),

            // تشغيل/إيقاف
            Obx(() => IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      audioController.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  onPressed: () => audioController.togglePlayPause(),
                  tooltip: audioController.isPlaying.value ? 'إيقاف' : 'تشغيل',
                )),

            // التالي
            Obx(() => IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.skip_next,
                      color: audioController.currentAyah.value != null
                          ? theme.primaryColor
                          : theme.disabledColor,
                    ),
                  ),
                  onPressed: audioController.currentAyah.value != null
                      ? () => audioController.next()
                      : null,
                  tooltip: 'التالي',
                )),

            const SizedBox(width: 1),

            // إغلاق
            IconButton(
              onPressed: () => audioController.stop(),
              icon: Icon(
                Icons.close,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
            ),
          ],
        ),
      );
    });
  }
}
