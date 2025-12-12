import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionService {
  static Future<bool> requestLocationPermissions() async {
    try {
      // فحص الأذونات الحالية
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // طلب الإذن للمرة الأولى
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'إذن الموقع مطلوب',
            'يرجى السماح للتطبيق بالوصول إلى موقعك لتتبع مشي الأربعين',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // إذا تم رفض الإذن نهائياً، اطلب من المستخدم الذهاب للإعدادات
        Get.dialog(
          AlertDialog(
            title: const Text('إذن الموقع مطلوب'),
            content: const Text(
              'تم رفض إذن الموقع نهائياً. يرجى الذهاب إلى إعدادات التطبيق والسماح بالوصول إلى الموقع لاستخدام ميزة مشي الأربعين.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await openAppSettings();
                },
                child: const Text('فتح الإعدادات'),
              ),
            ],
          ),
        );
        return false;
      }

      // طلب إذن الموقع في الخلفية للـ iOS
      if (GetPlatform.isIOS) {
        final backgroundPermission = await Permission.locationAlways.request();
        if (backgroundPermission.isDenied) {
          Get.dialog(
            AlertDialog(
              title: const Text('إذن الموقع في الخلفية'),
              content: const Text(
                'للحصول على أفضل تجربة في تتبع مشي الأربعين، يُنصح بالسماح بالوصول للموقع حتى عند إغلاق التطبيق.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('تخطي'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await Permission.locationAlways.request();
                  },
                  child: const Text('السماح'),
                ),
              ],
            ),
          );
        }
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء طلب أذونات الموقع: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<void> showLocationServiceDialog() async {
    Get.dialog(
      AlertDialog(
        title: const Text('خدمة الموقع غير مفعلة'),
        content: const Text(
          'يرجى تفعيل خدمة الموقع (GPS) في إعدادات الجهاز لاستخدام ميزة مشي الأربعين.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openLocationSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  static Future<bool> checkAndRequestPermissions() async {
    // فحص تفعيل خدمة الموقع
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      await showLocationServiceDialog();
      return false;
    }

    // طلب أذونات الموقع
    return await requestLocationPermissions();
  }
}
