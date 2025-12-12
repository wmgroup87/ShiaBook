class AppConstants {
  // App Info
  static const String appName = 'الكتب الشيعية';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'مجموعة شاملة من الكتب الشيعية الإسلامية';

  // Database
  static const String databaseName = 'shia_books.db';
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyFontSize = 'font_size';
  static const String keyArabicFontSize = 'arabic_font_size';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyNotificationTime = 'notification_time';
  static const String keyAutoBookmark = 'auto_bookmark';
  static const String keyShowTranslation = 'show_translation';
  static const String keyShowGrade = 'show_grade';
  static const String keyShowSource = 'show_source';

  // Notification IDs
  static const int dailyHadithNotificationId = 1001;
  static const int reminderNotificationId = 1002;

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxSearchResults = 100;

  // Text Limits
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxPreviewLength = 150;

  // Font Sizes
  static const double minFontSize = 12.0;
  static const double maxFontSize = 28.0;
  static const double defaultFontSize = 16.0;
  static const double defaultArabicFontSize = 18.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // API Endpoints (if needed)
  static const String baseUrl = 'https://api.shiabooks.com';
  static const String hadithEndpoint = '/hadiths';
  static const String duasEndpoint = '/duas';
  static const String ziyaratEndpoint = '/ziyarat';

  // File Paths
  static const String assetsPath = 'assets';
  static const String iconsPath = 'assets/icons';
  static const String imagesPath = 'assets/images';
  static const String fontsPath = 'assets/fonts';

  // Regular Expressions
  static const String arabicTextRegex = r'[\u0600-\u06FF\s]+';
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Error Messages
  static const String networkError = 'خطأ في الاتصال بالشبكة';
  static const String unknownError = 'حدث خطأ غير متوقع';
  static const String noDataFound = 'لا توجد بيانات';
  static const String loadingError = 'خطأ في تحميل البيانات';

  // Success Messages
  static const String dataLoaded = 'تم تحميل البيانات بنجاح';
  static const String dataSaved = 'تم حفظ البيانات بنجاح';
  static const String dataDeleted = 'تم حذف البيانات بنجاح';

  // Hadith Grades
  static const List<String> hadithGrades = [
    'صحيح',
    'حسن',
    'ضعيف',
    'متواتر',
    'موثق',
    'مرسل',
  ];

  // Book Categories
  static const List<String> bookCategories = [
    'الحديث',
    'الفقه',
    'العقائد',
    'التفسير',
    'التاريخ',
    'الأخلاق',
    'الأدعية',
    'الزيارات',
  ];

  // Prayer Times
  static const List<String> prayerNames = [
    'الفجر',
    'الشروق',
    'الظهر',
    'العصر',
    'المغرب',
    'العشاء',
  ];

  // Islamic Months
  static const List<String> islamicMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الثانية',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];
}
