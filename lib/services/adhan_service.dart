import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;

class AdhanService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // تهيئة الخدمة
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // إنشاء قناة الإشعارات لـ Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'adhan_channel',
        'أذان الصلاة',
        description: 'إشعارات أوقات الصلاة والأذان',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // طلب الأذونات لـ iOS
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    }

    // طلب الأذونات لـ Android
    if (Platform.isAndroid) {
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
  }

  // معالجة النقر على الإشعار
  static void _onNotificationTap(NotificationResponse response) async {
    if (response.payload != null) {
      // تشغيل الأذان عند النقر على الإشعار
      await playAdhan();
    }
  }

  // تشغيل الأذان
  static Future<void> playAdhan() async {
    try {
      final settings = await getAdhanSettings();
      final volume = settings['volume'] as double;

      // إعداد جلسة الصوت لـ iOS
      if (Platform.isIOS) {
        await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      }

      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play(AssetSource('audio/adhan.mp3'));

      print('تم تشغيل الأذان بمستوى صوت: ${(volume * 100).round()}%');
    } catch (e) {
      print('خطأ في تشغيل الأذان: $e');
    }
  }

  // الحصول على أوقات الصلاة للمذهب الجعفري (مؤقتاً)
  static Future<Map<String, String>> _getPrayerTimes() async {
    // هذه أوقات مؤقتة للمذهب الجعفري - يجب استبدالها بأوقات حقيقية
    return {
      'فجر': '05:30',
      'ظهر': '12:15',
      'مغرب': '18:45',
    };
  }

  // جدولة الأذان لجميع الصلوات (المذهب الجعفري)
  static Future<void> scheduleAllAdhans() async {
    final settings = await getAdhanSettings();

    if (!settings['enabled']) {
      await cancelAllAdhans();
      return;
    }

    // إلغاء الجدولة السابقة أولاً
    await cancelAllAdhans();

    // أوقات الصلاة للمذهب الجعفري
    final prayerTimes = await _getPrayerTimes();

    // جدولة أذان الفجر
    if (settings['fajr']) {
      await _scheduleAdhan('فجر', prayerTimes['فجر']!, 1);
    }

    // جدولة أذان الظهر
    if (settings['dhuhr']) {
      await _scheduleAdhan('ظهر', prayerTimes['ظهر']!, 2);
    }

    // جدولة أذان المغرب
    if (settings['maghrib']) {
      await _scheduleAdhan('مغرب', prayerTimes['مغرب']!, 3);
    }

    print('تم جدولة جميع الأذانات المفعلة للمذهب الجعفري');
  }

  // جدولة أذان واحد
  static Future<void> _scheduleAdhan(
      String prayerName, String timeStr, int id) async {
    try {
      final now = DateTime.now();
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // إذا كان الوقت قد مضى اليوم، جدوله للغد
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // إعدادات الإشعار لـ Android
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'adhan_channel',
        'أذان الصلاة',
        channelDescription: 'إشعارات أوقات الصلاة والأذان',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );

      // إعدادات الإشعار لـ iOS
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'adhan.mp3',
        interruptionLevel: InterruptionLevel.critical,
        categoryIdentifier: 'adhan_category',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // جدولة الإشعار
      await _notifications.zonedSchedule(
        id,
        'حان وقت الأذان',
        'حان الآن وقت صلاة $prayerName',
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: prayerName,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print(
          'تم جدولة أذان $prayerName للساعة ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');
    } catch (e) {
      print('خطأ في جدولة الأذان لـ $prayerName: $e');
    }
  }

  // جدولة إشعارات يومية متكررة للمذهب الجعفري
  static Future<void> scheduleDailyAdhans() async {
    final settings = await getAdhanSettings();

    if (!settings['enabled']) {
      await cancelAllAdhans();
      return;
    }

    await cancelAllAdhans();
    final prayerTimes = await _getPrayerTimes();

    // جدولة أذان الفجر يومياً
    if (settings['fajr']) {
      await _scheduleDailyAdhan('فجر', prayerTimes['فجر']!, 1);
    }

    // جدولة أذان الظهر يومياً
    if (settings['dhuhr']) {
      await _scheduleDailyAdhan('ظهر', prayerTimes['ظهر']!, 2);
    }

    // جدولة أذان المغرب يومياً
    if (settings['maghrib']) {
      await _scheduleDailyAdhan('مغرب', prayerTimes['مغرب']!, 3);
    }

    print('تم جدولة جميع الأذانات اليومية للمذهب الجعفري');
  }

  // جدولة أذان يومي متكرر
  static Future<void> _scheduleDailyAdhan(
      String prayerName, String timeStr, int id) async {
    try {
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // إذا كان الوقت قد مضى اليوم، ابدأ من الغد
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'adhan_channel',
        'أذان الصلاة',
        channelDescription: 'إشعارات أوقات الصلاة والأذان',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'adhan.mp3',
        interruptionLevel: InterruptionLevel.critical,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // جدولة إشعار يومي متكرر
      await _notifications.zonedSchedule(
        id,
        'حان وقت الأذان',
        'حان الآن وقت صلاة $prayerName',
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: prayerName,
        matchDateTimeComponents:
            DateTimeComponents.time, // يتكرر يومياً في نفس الوقت
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print(
          'تم جدولة أذان $prayerName اليومي للساعة $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      print('خطأ في جدولة الأذان اليومي لـ $prayerName: $e');
    }
  }

  // إلغاء جميع الأذانات المجدولة
  static Future<void> cancelAllAdhans() async {
    await _notifications.cancelAll();
    print('تم إلغاء جميع الأذانات المجدولة');
  }

  // عرض الإشعارات المجدولة (للتطوير والاختبار)
  static Future<void> showScheduledNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _notifications.pendingNotificationRequests();

    print('الإشعارات المجدولة: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      print('ID: ${notification.id}, العنوان: ${notification.title}');
    }
  }

  // الحصول على مفتاح الصلاة
  static String _getPrayerKey(String prayerName) {
    switch (prayerName) {
      case 'فجر':
        return 'fajr';
      case 'ظهر':
        return 'dhuhr';
      case 'مغرب':
        return 'maghrib';
      default:
        return 'fajr';
    }
  }

  // الحصول على إعدادات الأذان للمذهب الجعفري
  static Future<Map<String, dynamic>> getAdhanSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool('adhan_enabled') ?? true,
      'volume': prefs.getDouble('adhan_volume') ?? 0.8,
      'fajr': prefs.getBool('adhan_fajr') ?? true,
      'dhuhr': prefs.getBool('adhan_dhuhr') ?? true,
      'maghrib': prefs.getBool('adhan_maghrib') ?? true,
    };
  }

  // تفعيل/إلغاء تفعيل الأذان
  static Future<void> setAdhanEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhan_enabled', enabled);

    if (enabled) {
      await scheduleDailyAdhans();
      print('تم تفعيل الأذان وجدولة الإشعارات اليومية');
    } else {
      await cancelAllAdhans();
      print('تم إلغاء تفعيل الأذان وإلغاء جميع الإشعارات');
    }
  }

  // تعديل مستوى الصوت
  static Future<void> setAdhanVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('adhan_volume', volume);
    print('تم تعديل مستوى الصوت إلى: ${(volume * 100).round()}%');
  }

  // تفعيل/إلغاء تفعيل أذان صلاة معينة
  static Future<void> setPrayerAdhanEnabled(String prayer, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'adhan_${_getPrayerKey(prayer)}';
    await prefs.setBool(key, enabled);

    print('تم ${enabled ? 'تفعيل' : 'إلغاء تفعيل'} أذان $prayer');

    // إعادة جدولة الأذانات اليومية
    await scheduleDailyAdhans();
  }

  // اختبار الأذان فوراً
  static Future<void> testAdhan() async {
    print('اختبار تشغيل الأذان...');
    await playAdhan();
  }

  // إيقاف تشغيل الأذان
  static Future<void> stopAdhan() async {
    try {
      await _audioPlayer.stop();
      print('تم إيقاف تشغيل الأذان');
    } catch (e) {
      print('خطأ في إيقاف الأذان: $e');
    }
  }

  // التحقق من حالة تشغيل الأذان
  static Future<bool> isAdhanPlaying() async {
    try {
      return _audioPlayer.state == PlayerState.playing;
    } catch (e) {
      print('خطأ في التحقق من حالة الأذان: $e');
      return false;
    }
  }

  // جدولة إشعار فوري للاختبار
  static Future<void> scheduleTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'adhan_channel',
      'أذان الصلاة',
      channelDescription: 'إشعارات أوقات الصلاة والأذان',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'adhan.mp3',
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      'اختبار الأذان',
      'هذا إشعار تجريبي لاختبار الأذان',
      notificationDetails,
      payload: 'test',
    );

    print('تم إرسال إشعار تجريبي');
  }

  // الحصول على الوقت التالي للأذان (المذهب الجعفري)
  static Future<Map<String, dynamic>?> getNextAdhanTime() async {
    final settings = await getAdhanSettings();

    if (!settings['enabled']) {
      return null;
    }

    final prayerTimes = await _getPrayerTimes();
    final now = DateTime.now();

    // قائمة الصلوات مع حالة التفعيل (المذهب الجعفري)
    final prayers = [
      {'name': 'فجر', 'time': prayerTimes['فجر']!, 'enabled': settings['fajr']},
      {
        'name': 'ظهر',
        'time': prayerTimes['ظهر']!,
        'enabled': settings['dhuhr']
      },
      {
        'name': 'مغرب',
        'time': prayerTimes['مغرب']!,
        'enabled': settings['maghrib']
      },
    ];

    // البحث عن الصلاة التالية
    for (var prayer in prayers) {
      if (!prayer['enabled']) continue;

      final timeStr = prayer['time'] as String;
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      var prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

      // إذا كان الوقت قد مضى اليوم، اجعله للغد
      if (prayerTime.isBefore(now)) {
        prayerTime = prayerTime.add(const Duration(days: 1));
      }

      return {
        'name': prayer['name'],
        'time': timeStr,
        'dateTime': prayerTime,
        'remainingMinutes': prayerTime.difference(now).inMinutes,
      };
    }

    return null;
  }

  // تحديث أوقات الصلاة للمذهب الجعفري
  static Future<void> updatePrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    // هنا يمكنك إضافة استدعاء API لحساب أوقات الصلاة الحقيقية للمذهب الجعفري
    // مثال: استخدام مكتبة adhan مع إعدادات المذهب الجعفري

    print('تحديث أوقات الصلاة للمذهب الجعفري للموقع: $latitude, $longitude');

    // بعد الحصول على الأوقات الجديدة، أعد جدولة الأذانات
    await scheduleDailyAdhans();
  }

  // حفظ موقع المستخدم
  static Future<void> saveUserLocation(
      double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_latitude', latitude);
    await prefs.setDouble('user_longitude', longitude);

    // تحديث أوقات الصلاة بناءً على الموقع الجديد
    await updatePrayerTimes(latitude: latitude, longitude: longitude);
  }

  // الحصول على موقع المستخدم المحفوظ
  static Future<Map<String, double>?> getUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('user_latitude');
    final longitude = prefs.getDouble('user_longitude');

    if (latitude != null && longitude != null) {
      return {
        'latitude': latitude,
        'longitude': longitude,
      };
    }

    return null;
  }

  // الحصول على قائمة الإشعارات المجدولة (للتطوير والاختبار)
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // إلغاء أذان صلاة معينة
  static Future<void> cancelPrayerAdhan(String prayerName) async {
    int id;
    switch (prayerName) {
      case 'فجر':
        id = 1;
        break;
      case 'ظهر':
        id = 2;
        break;
      case 'مغرب':
        id = 3;
        break;
      default:
        return;
    }

    await _notifications.cancel(id);
    print('تم إلغاء أذان $prayerName');
  }

  // تحديث إعدادات الأذان مع إعادة الجدولة
  static Future<void> updateAdhanSettings({
    bool? enabled,
    double? volume,
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? maghribEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (enabled != null) {
      await prefs.setBool('adhan_enabled', enabled);
    }

    if (volume != null) {
      await prefs.setDouble('adhan_volume', volume);
    }

    if (fajrEnabled != null) {
      await prefs.setBool('adhan_fajr', fajrEnabled);
    }

    if (dhuhrEnabled != null) {
      await prefs.setBool('adhan_dhuhr', dhuhrEnabled);
    }

    if (maghribEnabled != null) {
      await prefs.setBool('adhan_maghrib', maghribEnabled);
    }

    // إعادة جدولة الأذانات بناءً على الإعدادات الجديدة
    await scheduleDailyAdhans();

    print('تم تحديث إعدادات الأذان وإعادة الجدولة');
  }

  // تنظيف الموارد
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      print('تم تنظيف موارد خدمة الأذان');
    } catch (e) {
      print('خطأ في تنظيف الموارد: $e');
    }
  }

  // دالة مساعدة لتحويل الوقت إلى نص قابل للقراءة
  static String formatTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  // دالة للحصول على أيقونة الصلاة
  static IconData getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'فجر':
        return Icons.wb_sunny_outlined;
      case 'ظهر':
        return Icons.wb_sunny;
      case 'مغرب':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  // دالة للحصول على لون الصلاة
  static Color getPrayerColor(String prayerName) {
    switch (prayerName) {
      case 'فجر':
        return Colors.orange;
      case 'ظهر':
        return Colors.yellow;
      case 'مغرب':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }
}
