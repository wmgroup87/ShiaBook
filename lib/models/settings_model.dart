import 'package:flutter/material.dart';

class SettingsModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final SettingsType type;
  final dynamic value;
  final List<String>? options;
  final Function(dynamic)? onChanged;

  SettingsModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    this.value,
    this.options,
    this.onChanged,
  });
}

enum SettingsType {
  toggle,
  dropdown,
  slider,
  navigation,
  colorPicker,
  textField,
}

class AppSettings {
  bool isDarkMode;
  String language;
  double fontSize;
  String fontFamily;
  bool notificationsEnabled;
  bool prayerReminders;
  bool eventReminders;
  String themeColor;
  bool autoBackup;
  String backupFrequency;
  bool offlineMode;
  double audioSpeed;
  bool showArabicText;
  bool showTranslation;
  String prayerCalculationMethod;
  String hijriDateAdjustment;
  String madhab;
  bool showShiaEvents;
  bool showMourningEvents;
  bool showJoyfulEvents;
  bool enableAhlulBaytPrayers;
  bool showImamQuotes;
  String qiblaCalculationMethod;
  bool enableZiyaratReminders;
  bool showTasbihCounter;

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'notificationsEnabled': notificationsEnabled,
      'prayerReminders': prayerReminders,
      'eventReminders': eventReminders,
      'themeColor': themeColor,
      'autoBackup': autoBackup,
      'backupFrequency': backupFrequency,
      'offlineMode': offlineMode,
      'audioSpeed': audioSpeed,
      'showArabicText': showArabicText,
      'showTranslation': showTranslation,
      'prayerCalculationMethod': prayerCalculationMethod,
      'hijriDateAdjustment': hijriDateAdjustment,
      'madhab': madhab,
      'showShiaEvents': showShiaEvents,
      'showMourningEvents': showMourningEvents,
      'showJoyfulEvents': showJoyfulEvents,
      'enableAhlulBaytPrayers': enableAhlulBaytPrayers,
      'showImamQuotes': showImamQuotes,
      'qiblaCalculationMethod': qiblaCalculationMethod,
      'enableZiyaratReminders': enableZiyaratReminders,
      'showTasbihCounter': showTasbihCounter,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      language: json['language'] ?? 'العربية',
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      fontFamily: json['fontFamily'] ?? 'Cairo',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      prayerReminders: json['prayerReminders'] ?? true,
      eventReminders: json['eventReminders'] ?? true,
      themeColor: json['themeColor'] ?? 'أخضر',
      autoBackup: json['autoBackup'] ?? false,
      backupFrequency: json['backupFrequency'] ?? 'أسبوعياً',
      offlineMode: json['offlineMode'] ?? false,
      audioSpeed: (json['audioSpeed'] ?? 1.0).toDouble(),
      showArabicText: json['showArabicText'] ?? true,
      showTranslation: json['showTranslation'] ?? true,
      prayerCalculationMethod: json['prayerCalculationMethod'] ?? 'أم القرى',
      hijriDateAdjustment: json['hijriDateAdjustment'] ?? '0',
      madhab: json['madhab'] ?? 'جعفري',
      showShiaEvents: json['showShiaEvents'] ?? true,
      showMourningEvents: json['showMourningEvents'] ?? true,
      showJoyfulEvents: json['showJoyfulEvents'] ?? true,
      enableAhlulBaytPrayers: json['enableAhlulBaytPrayers'] ?? true,
      showImamQuotes: json['showImamQuotes'] ?? true,
      qiblaCalculationMethod: json['qiblaCalculationMethod'] ?? 'دقيق',
      enableZiyaratReminders: json['enableZiyaratReminders'] ?? true,
      showTasbihCounter: json['showTasbihCounter'] ?? true,
    );
  }

  AppSettings({
    this.isDarkMode = false,
    this.language = 'العربية',
    this.fontSize = 16.0,
    this.fontFamily = 'Cairo',
    this.notificationsEnabled = true,
    this.prayerReminders = true,
    this.eventReminders = true,
    this.themeColor = 'أخضر',
    this.autoBackup = false,
    this.backupFrequency = 'أسبوعياً',
    this.offlineMode = false,
    this.audioSpeed = 1.0,
    this.showArabicText = true,
    this.showTranslation = true,
    this.prayerCalculationMethod = 'أم القرى',
    this.hijriDateAdjustment = '0',
    this.madhab = 'جعفري',
    this.showShiaEvents = true,
    this.showMourningEvents = true,
    this.showJoyfulEvents = true,
    this.enableAhlulBaytPrayers = true,
    this.showImamQuotes = true,
    this.qiblaCalculationMethod = 'دقيق',
    this.enableZiyaratReminders = true,
    this.showTasbihCounter = true,
  });

  // نسخة جديدة من الإعدادات
  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    double? fontSize,
    String? fontFamily,
    bool? notificationsEnabled,
    bool? prayerReminders,
    bool? eventReminders,
    String? themeColor,
    bool? autoBackup,
    String? backupFrequency,
    bool? offlineMode,
    double? audioSpeed,
    bool? showArabicText,
    bool? showTranslation,
    String? prayerCalculationMethod,
    String? hijriDateAdjustment,
    String? madhab,
    bool? showShiaEvents,
    bool? showMourningEvents,
    bool? showJoyfulEvents,
    bool? enableAhlulBaytPrayers,
    bool? showImamQuotes,
    String? qiblaCalculationMethod,
    bool? enableZiyaratReminders,
    bool? showTasbihCounter,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      eventReminders: eventReminders ?? this.eventReminders,
      themeColor: themeColor ?? this.themeColor,
      autoBackup: autoBackup ?? this.autoBackup,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      offlineMode: offlineMode ?? this.offlineMode,
      audioSpeed: audioSpeed ?? this.audioSpeed,
      showArabicText: showArabicText ?? this.showArabicText,
      showTranslation: showTranslation ?? this.showTranslation,
      prayerCalculationMethod:
          prayerCalculationMethod ?? this.prayerCalculationMethod,
      hijriDateAdjustment: hijriDateAdjustment ?? this.hijriDateAdjustment,
      madhab: madhab ?? this.madhab,
      showShiaEvents: showShiaEvents ?? this.showShiaEvents,
      showMourningEvents: showMourningEvents ?? this.showMourningEvents,
      showJoyfulEvents: showJoyfulEvents ?? this.showJoyfulEvents,
      enableAhlulBaytPrayers:
          enableAhlulBaytPrayers ?? this.enableAhlulBaytPrayers,
      showImamQuotes: showImamQuotes ?? this.showImamQuotes,
      qiblaCalculationMethod:
          qiblaCalculationMethod ?? this.qiblaCalculationMethod,
      enableZiyaratReminders:
          enableZiyaratReminders ?? this.enableZiyaratReminders,
      showTasbihCounter: showTasbihCounter ?? this.showTasbihCounter,
    );
  }
}
