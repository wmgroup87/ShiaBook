import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<bool> requestNotificationPermissions() async {
    if (Platform.isIOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? result =
            await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
        return result ?? false;
      }
    }
    return false;
  }

  // طلب أذونات إضافية
  static Future<bool> requestAllPermissions() async {
    // طلب إذن الإشعارات
    final notificationPermission = await requestNotificationPermissions();

    // طلب إذن الموقع (للحصول على أوقات الصلاة الدقيقة)
    final locationPermission = await Permission.location.request();

    // طلب إذن تشغيل الصوت
    final audioPermission = await Permission.audio.request();

    return notificationPermission &&
        locationPermission.isGranted &&
        audioPermission.isGranted;
  }

  // التحقق من الأذونات
  static Future<Map<String, bool>> checkPermissions() async {
    return {
      'notifications': await Permission.notification.isGranted,
      'location': await Permission.location.isGranted,
      'audio': await Permission.audio.isGranted,
    };
  }
}
