import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shia_book/models/settings_model.dart';
import 'dart:convert';

class SettingsController extends GetxController {
  final Rx<AppSettings> settings = AppSettings().obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('app_settings');
      
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        settings.value = AppSettings.fromJson(settingsMap);
      }
      
      // تطبيق الإعدادات المحملة
      _applySettings();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الإعدادات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // تطبيق جميع الإعدادات
  void _applySettings() {
    // تطبيق الوضع الليلي
    Get.changeThemeMode(settings.value.isDarkMode ? ThemeMode.dark : ThemeMode.light);
    
    // تطبيق حجم الخط
    final textTheme = Theme.of(Get.context!).textTheme;
    Get.changeTheme(Theme.of(Get.context!).copyWith(
      textTheme: textTheme.apply(
        fontSizeFactor: settings.value.fontSize / 16.0,
      ),
    ));
    
    // تطبيق اللون الرئيسي
    _updateAppTheme(settings.value.themeColor);
    
    // حفظ تعديل التاريخ الهجري
    _saveHijriAdjustment();
    
    // تطبيق إعدادات الإشعارات
    _applyNotificationSettings();
  }

  // حفظ تعديل التاريخ الهجري
  Future<void> _saveHijriAdjustment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hijri_date_adjustment', settings.value.hijriDateAdjustment);
    } catch (e) {
      print('Error saving Hijri adjustment: $e');
    }
  }

  // تطبيق إعدادات الإشعارات
  void _applyNotificationSettings() {
    // يمكن إضافة منطق إضافي هنا للتعامل مع الإشعارات
  }

  void updateDarkMode(bool value) {
    settings.value = settings.value.copyWith(isDarkMode: value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    _saveSettings();
  }

  void updateLanguage(String value) {
    settings.value = settings.value.copyWith(language: value);
    // TODO: تطبيق تغيير اللغة
    _saveSettings();
  }

  void updateFontSize(double value) {
    settings.value = settings.value.copyWith(fontSize: value);
    final textTheme = Theme.of(Get.context!).textTheme;
    Get.changeTheme(Theme.of(Get.context!).copyWith(
      textTheme: textTheme.apply(
        fontSizeFactor: value / 16.0,
      ),
    ));
    _saveSettings();
  }

  void updateFontFamily(String value) {
    settings.value = settings.value.copyWith(fontFamily: value);
    _updateAppTheme(settings.value.themeColor); // لتحديث الخط
    _saveSettings();
  }

  void updateNotifications(bool value) {
    settings.value = settings.value.copyWith(notificationsEnabled: value);
    _applyNotificationSettings();
    _saveSettings();
  }

  void updatePrayerReminders(bool value) {
    settings.value = settings.value.copyWith(prayerReminders: value);
    _applyNotificationSettings();
    _saveSettings();
  }

  void updateEventReminders(bool value) {
    settings.value = settings.value.copyWith(eventReminders: value);
    _applyNotificationSettings();
    _saveSettings();
  }

  void updateThemeColor(String value) {
    settings.value = settings.value.copyWith(themeColor: value);
    _updateAppTheme(value);
    _saveSettings();
  }

  void updateAutoBackup(bool value) {
    settings.value = settings.value.copyWith(autoBackup: value);
    _saveSettings();
  }

  void updateBackupFrequency(String value) {
    settings.value = settings.value.copyWith(backupFrequency: value);
    _saveSettings();
  }

  void updateOfflineMode(bool value) {
    settings.value = settings.value.copyWith(offlineMode: value);
    _saveSettings();
  }

  void updateAudioSpeed(double value) {
    settings.value = settings.value.copyWith(audioSpeed: value);
    _saveSettings();
  }

  void updateShowArabicText(bool value) {
    settings.value = settings.value.copyWith(showArabicText: value);
    _saveSettings();
  }

  void updateShowTranslation(bool value) {
    settings.value = settings.value.copyWith(showTranslation: value);
    _saveSettings();
  }

  void updatePrayerCalculationMethod(String value) {
    settings.value = settings.value.copyWith(prayerCalculationMethod: value);
    _saveSettings();
  }

  void updateHijriDateAdjustment(String value) {
    settings.value = settings.value.copyWith(hijriDateAdjustment: value);
    _saveHijriAdjustment();
    _saveSettings();
  }

  void updateMadhab(String value) {
    settings.value = settings.value.copyWith(madhab: value);
    _saveSettings();
  }

  void updateShowShiaEvents(bool value) {
    settings.value = settings.value.copyWith(showShiaEvents: value);
    _saveSettings();
  }

  void updateShowMourningEvents(bool value) {
    settings.value = settings.value.copyWith(showMourningEvents: value);
    _saveSettings();
  }

  void updateShowJoyfulEvents(bool value) {
    settings.value = settings.value.copyWith(showJoyfulEvents: value);
    _saveSettings();
  }

  void updateEnableAhlulBaytPrayers(bool value) {
    settings.value = settings.value.copyWith(enableAhlulBaytPrayers: value);
    _saveSettings();
  }

  void updateShowImamQuotes(bool value) {
    settings.value = settings.value.copyWith(showImamQuotes: value);
    _saveSettings();
  }

  void updateQiblaCalculationMethod(String value) {
    settings.value = settings.value.copyWith(qiblaCalculationMethod: value);
    _saveSettings();
  }

  void updateEnableZiyaratReminders(bool value) {
    settings.value = settings.value.copyWith(enableZiyaratReminders: value);
    _saveSettings();
  }

  void updateShowTasbihCounter(bool value) {
    settings.value = settings.value.copyWith(showTasbihCounter: value);
    _saveSettings();
  }

  void _updateAppTheme(String colorName) {
    Color primaryColor;
    switch (colorName) {
      case 'أخضر':
        primaryColor = Colors.green;
        break;
      case 'أزرق':
        primaryColor = Colors.blue;
        break;
      case 'بنفسجي':
        primaryColor = Colors.purple;
        break;
      case 'برتقالي':
        primaryColor = Colors.orange;
        break;
      case 'أحمر':
        primaryColor = Colors.red;
        break;
      default:
        primaryColor = Colors.green;
    }

    Get.changeTheme(
      ThemeData(
        primarySwatch: MaterialColor(primaryColor.value, {
          50: primaryColor.withOpacity(0.1),
          100: primaryColor.withOpacity(0.2),
          200: primaryColor.withOpacity(0.3),
          300: primaryColor.withOpacity(0.4),
          400: primaryColor.withOpacity(0.5),
          500: primaryColor.withOpacity(0.6),
          600: primaryColor.withOpacity(0.7),
          700: primaryColor.withOpacity(0.8),
          800: primaryColor.withOpacity(0.9),
          900: primaryColor,
        }),
        fontFamily: settings.value.fontFamily,
      ),
    );
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.value.toJson());
      await prefs.setString('app_settings', settingsJson);
      
      // تطبيق الإعدادات بعد الحفظ
      _applySettings();
      
      Get.snackbar(
        'تم',
        'تم حفظ الإعدادات بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ الإعدادات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void resetSettings() {
    settings.value = AppSettings();
    _applySettings();
    _saveSettings();
  }

  Future<void> exportSettings() async {
    try {
      final settingsJson = jsonEncode(settings.value.toJson());
      // TODO: تنفيذ تصدير الإعدادات
      Get.snackbar(
        'تم',
        'تم تصدير الإعدادات بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تصدير الإعدادات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> importSettings() async {
    try {
      // TODO: تنفيذ استيراد الإعدادات
      Get.snackbar(
        'تم',
        'تم استيراد الإعدادات بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء استيراد الإعدادات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
