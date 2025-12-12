import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioNotificationService {
  static void showReciterUnavailable(String reciterName) {
    Get.snackbar(
      'القارئ غير متاح',
      'لا يمكن الوصول إلى ملفات $reciterName حالياً',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.warning, color: Colors.white),
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text('حسناً', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  static void showPlaybackError(String error) {
    Get.snackbar(
      'خطأ في التشغيل',
      error,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  static void showDownloadProgress(String reciterName, double progress) {
    Get.showSnackbar(
      GetSnackBar(
        title: 'جاري التحميل',
        message: 'تحميل $reciterName - ${(progress * 100).toInt()}%',
        duration: const Duration(seconds: 1),
        showProgressIndicator: true,
        progressIndicatorBackgroundColor: Colors.white,
        progressIndicatorValueColor:
            const AlwaysStoppedAnimation<Color>(Colors.blue),
        snackPosition: SnackPosition.BOTTOM,
      ),
    );
  }

  static void showSuccessMessage(String message) {
    Get.snackbar(
      'نجح',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
}
