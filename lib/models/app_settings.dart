class AppSettings {
  final bool isDarkMode;
  final double fontSize;
  final String fontFamily;
  final String themeColor;
  final bool notificationsEnabled;
  final bool prayerReminders;
  final bool eventReminders;
  final String prayerCalculationMethod;
  final String hijriDateAdjustment;
  final String madhab; // المذهب الفقهي
  final bool showShiaEvents; // عرض المناسبات الشيعية
  final bool showMourningEvents; // عرض مناسبات الحزن
  final bool showJoyfulEvents; // عرض مناسبات الفرح
  final bool enableAhlulBaytPrayers; // تفعيل أدعية أهل البيت
  final bool showImamQuotes; // عرض أقوال الأئمة
  final String qiblaCalculationMethod; // طريقة حساب القبلة
  final bool enableZiyaratReminders; // تذكير الزيارات
  final bool showTasbihCounter; // عداد التسبيح

  AppSettings({
    this.isDarkMode = false,
    this.fontSize = 16.0,
    this.fontFamily = 'Cairo',
    this.themeColor = 'green',
    this.notificationsEnabled = true,
    this.prayerReminders = true,
    this.eventReminders = true,
    this.prayerCalculationMethod = 'طهران', // الافتراضي للمذهب الجعفري
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

  AppSettings copyWith({
    bool? isDarkMode,
    double? fontSize,
    String? fontFamily,
    String? themeColor,
    bool? notificationsEnabled,
    bool? prayerReminders,
    bool? eventReminders,
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
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      themeColor: themeColor ?? this.themeColor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      eventReminders: eventReminders ?? this.eventReminders,
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

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'themeColor': themeColor,
      'notificationsEnabled': notificationsEnabled,
      'prayerReminders': prayerReminders,
      'eventReminders': eventReminders,
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
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
      fontFamily: json['fontFamily'] ?? 'Cairo',
      themeColor: json['themeColor'] ?? 'green',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      prayerReminders: json['prayerReminders'] ?? true,
      eventReminders: json['eventReminders'] ?? true,
      prayerCalculationMethod: json['prayerCalculationMethod'] ?? 'طهران',
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
}
