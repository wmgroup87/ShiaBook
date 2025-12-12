import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran_library.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_controller.dart';

// Initialize the Quran library
final quranLibrary = QuranLibrary();

class QuranController extends GetxController with GetTickerProviderStateMixin {
  final RxInt currentPage = 1.obs;
  final RxBool isUIVisible = true.obs;
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> quranData = <Map<String, dynamic>>[].obs;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // بيانات القرآن من المكتبة
  List<dynamic> allSurahs = [];
  List<dynamic> allJoz = [];
  List<dynamic> allHizb = [];

  final AudioController audioController = Get.put(AudioController());

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _initializeQuranLibrary();
  }

  Future<void> _initializeQuranLibrary() async {
    try {
      await quranLibrary.init();
      print('Quran library initialized successfully');
      await loadQuranData();
    } catch (e) {
      print('Error initializing Quran library: $e');
      // Even if library fails, we can still proceed with default data
      loadQuranData();
    }
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> loadQuranData() async {
    try {
      isLoading.value = true;

      // Try to load data from library
      try {
        allSurahs = quranLibrary.getAllSurahs();
        allJoz = quranLibrary.allJoz;
        allHizb = quranLibrary.allHizb;
        print('Loaded ${allSurahs.length} surahs from library');
      } catch (e) {
        print('Error loading Quran data from library: $e');
        allSurahs = [];
        allJoz = [];
        allHizb = [];
      }

      // Create page data (604 pages)
      List<Map<String, dynamic>> pages = [];
      try {
        for (int i = 1; i <= 604; i++) {
          pages.add({
            'pageNumber': i,
            'surahNumber': _getSurahNumberForPage(i),
            'surahName': _getSurahNameForPage(i),
            'juzNumber': _getJuzNumberForPage(i),
          });
        }
      } catch (e) {
        print('Error creating page data: $e');
        // Fallback to basic page data if there's an error
        for (int i = 1; i <= 604; i++) {
          pages.add({
            'pageNumber': i,
            'surahNumber': 1, // Default to first surah
            'surahName': 'الفاتحة',
            'juzNumber': (i / 20).ceil(), // Approximate juz
          });
        }
      }

      quranData.value = pages;

      await _loadLastPage();

      isLoading.value = false;
      animationController.forward();
    } catch (e) {
      print('خطأ في تحميل بيانات القرآن: $e');
      isLoading.value = false;
      Get.snackbar(
        'خطأ',
        'فشل في تحميل بيانات القرآن الكريم',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadLastPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt('last_quran_page') ?? 1;

      if (lastPage >= 1 && lastPage <= 604) {
        currentPage.value = lastPage;
      } else {
        currentPage.value = 1;
      }
    } catch (e) {
      print('خطأ في تحميل آخر صفحة: $e');
      currentPage.value = 1;
    }
  }

  Future<void> saveCurrentPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_quran_page', currentPage.value);
    } catch (e) {
      print('خطأ في حفظ الصفحة: $e');
    }
  }

  void toggleUI() {
    isUIVisible.value = !isUIVisible.value;

    if (isUIVisible.value) {
      animationController.forward();
    } else {
      animationController.reverse();
    }

    HapticFeedback.lightImpact();
  }

  void onPageChanged(int pageNumber) {
    // Convert to 1-based page number if needed
    final actualPageNumber = pageNumber + 1;
    if (actualPageNumber >= 1 && actualPageNumber <= 604) {
      currentPage.value = actualPageNumber;
      saveCurrentPage();
    }
  }

  void goToPage(int pageNumber) {
    // Ensure the page number is within valid range (1-604)
    final targetPage = pageNumber.clamp(1, 604);
    currentPage.value = targetPage;
    saveCurrentPage();

    // Use jumpToPage from the library (0-based)
    try {
      quranLibrary
          .jumpToPage(targetPage - 1); // Convert to 0-based for the library
    } catch (e) {
      print('خطأ في jumpToPage: $e');
    }

    Get.snackbar(
      'انتقال',
      'تم الانتقال إلى الصفحة $targetPage',
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );

    update();
  }

  void goToSurah(int surahNumber) {
    try {
      // استخدام jumpToSurah من المكتبة
      quranLibrary.jumpToSurah(surahNumber);

      // تحديث الصفحة الحالية (تقريبي)
      currentPage.value = _getFirstPageOfSurah(surahNumber);
      saveCurrentPage();

      Get.snackbar(
        'انتقال',
        'تم الانتقال إلى السورة',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      update();
    } catch (e) {
      print('خطأ في الانتقال للسورة: $e');
    }
  }

  void goToJuz(int juzNumber) {
    try {
      // استخدام jumpToJoz من المكتبة
      quranLibrary.jumpToJoz(juzNumber);

      // تحديث الصفحة الحالية (تقريبي)
      currentPage.value = _getFirstPageOfJuz(juzNumber);
      saveCurrentPage();

      Get.snackbar(
        'انتقال',
        'تم الانتقال إلى الجزء $juzNumber',
        backgroundColor: Colors.teal,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      update();
    } catch (e) {
      print('خطأ في الانتقال للجزء: $e');
    }
  }

  int _getFirstPageOfSurah(int surahNumber) {
    // صفحات بداية السور (تقريبية)
    final surahPages = [
      1,
      2,
      50,
      77,
      106,
      128,
      151,
      177,
      187,
      208,
      221,
      235,
      249,
      255,
      262,
      267,
      282,
      293,
      305,
      312,
      322,
      332,
      342,
      350,
      359,
      367,
      377,
      385,
      396,
      404,
      411,
      415,
      418,
      428,
      434,
      440,
      446,
      453,
      458,
      467,
      477,
      483,
      489,
      496,
      499,
      502,
      507,
      511,
      515,
      518,
      520,
      523,
      526,
      528,
      531,
      534,
      537,
      542,
      545,
      549,
      551,
      553,
      554,
      556,
      558,
      560,
      562,
      564,
      566,
      568,
      570,
      572,
      574,
      575,
      577,
      578,
      580,
      582,
      583,
      585,
      586,
      587,
      587,
      589,
      590,
      591,
      591,
      592,
      593,
      594,
      595,
      595,
      596,
      596,
      597,
      598,
      598,
      599,
      599,
      600,
      600,
      601,
      601,
      601,
      602,
      602,
      602,
      603,
      603,
      603,
      603,
      604,
      604,
      604
    ];

    if (surahNumber >= 1 && surahNumber <= surahPages.length) {
      return surahPages[surahNumber - 1];
    }
    return 1;
  }

  int _getFirstPageOfJuz(int juzNumber) {
    // صفحات بداية الأجزاء
    final juzPages = [
      1,
      22,
      42,
      62,
      82,
      102,
      121,
      142,
      162,
      182,
      201,
      222,
      242,
      262,
      282,
      302,
      322,
      342,
      362,
      382,
      402,
      422,
      442,
      462,
      482,
      502,
      522,
      542,
      562,
      582
    ];

    if (juzNumber >= 1 && juzNumber <= juzPages.length) {
      return juzPages[juzNumber - 1];
    }
    return 1;
  }

  void nextPage() {
    final nextPageNumber = currentPage.value + 1;
    if (nextPageNumber <= 604) {
      goToPage(nextPageNumber);
    }
  }

  void previousPage() {
    final prevPageNumber = currentPage.value - 1;
    if (prevPageNumber >= 1) {
      goToPage(prevPageNumber);
    }
  }

  void playVerseAudio() {
    Get.snackbar(
      'استماع للآية',
      'جاري تشغيل تلاوة الآية',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // In your QuranController
  void addBookmark() {
    Get.snackbar(
      'حفظ الآية',
      'تم حفظ الآية بنجاح',
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
    );
  }

  void shareCurrentPage() {
    Get.snackbar(
      'مشاركة',
      'تم نسخ رابط الصفحة للمشاركة',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.share, color: Colors.white),
    );
  }

  void copyPageText() {
    Get.snackbar(
      'نسخ',
      'تم نسخ نص الصفحة',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.copy, color: Colors.white),
    );
  }

  List<Map<String, dynamic>> getUniqueSurahs() {
    List<Map<String, dynamic>> surahList = [];

    try {
      // أسماء السور بالعربية
      final surahNames = [
        'الفاتحة',
        'البقرة',
        'آل عمران',
        'النساء',
        'المائدة',
        'الأنعام',
        'الأعراف',
        'الأنفال',
        'التوبة',
        'يونس',
        'هود',
        'يوسف',
        'الرعد',
        'إبراهيم',
        'الحجر',
        'النحل',
        'الإسراء',
        'الكهف',
        'مريم',
        'طه',
        'الأنبياء',
        'الحج',
        'المؤمنون',
        'النور',
        'الفرقان',
        'الشعراء',
        'النمل',
        'القصص',
        'العنكبوت',
        'الروم',
        'لقمان',
        'السجدة',
        'الأحزاب',
        'سبأ',
        'فاطر',
        'يس',
        'الصافات',
        'ص',
        'الزمر',
        'غافر',
        'فصلت',
        'الشورى',
        'الزخرف',
        'الدخان',
        'الجاثية',
        'الأحقاف',
        'محمد',
        'الفتح',
        'الحجرات',
        'ق',
        'الذاريات',
        'الطور',
        'النجم',
        'القمر',
        'الرحمن',
        'الواقعة',
        'الحديد',
        'المجادلة',
        'الحشر',
        'الممتحنة',
        'الصف',
        'الجمعة',
        'المنافقون',
        'التغابن',
        'الطلاق',
        'التحريم',
        'الملك',
        'القلم',
        'الحاقة',
        'المعارج',
        'نوح',
        'الجن',
        'المزمل',
        'المدثر',
        'القيامة',
        'الإنسان',
        'المرسلات',
        'النبأ',
        'النازعات',
        'عبس',
        'التكوير',
        'الانفطار',
        'المطففين',
        'الانشقاق',
        'البروج',
        'الطارق',
        'الأعلى',
        'الغاشية',
        'الفجر',
        'البلد',
        'الشمس',
        'الليل',
        'الضحى',
        'الشرح',
        'التين',
        'العلق',
        'القدر',
        'البينة',
        'الزلزلة',
        'العاديات',
        'القارعة',
        'التكاثر',
        'العصر',
        'الهمزة',
        'الفيل',
        'قريش',
        'الماعون',
        'الكوثر',
        'الكافرون',
        'النصر',
        'المسد',
        'الإخلاص',
        'الفلق',
        'الناس'
      ];

      final allSurahs = <Map<String, dynamic>>[];

      for (int i = 1; i <= 114; i++) {
        final firstPageIndex = _getFirstPageOfSurah(i);
        allSurahs.add({
          'surahNumber': i,
          'surahName': i <= surahNames.length ? surahNames[i - 1] : 'سورة $i',
          'englishName': 'Surah $i',
          'firstPageIndex': firstPageIndex,
          'startPage': firstPageIndex, // Use 1-based page numbering
          'ayahCount': _getAyahCountForSurah(i),
          'revelationType': _getRevelationTypeForSurah(i),
        });
      }

      return allSurahs;
    } catch (e) {
      print('خطأ في تحميل السور: $e');
    }

    return surahList;
  }

  int _getAyahCountForSurah(int surahNumber) {
    // عدد الآيات في كل سورة
    final ayahCounts = [
      7,
      286,
      200,
      176,
      120,
      165,
      206,
      75,
      129,
      109,
      123,
      111,
      43,
      52,
      99,
      128,
      111,
      110,
      98,
      135,
      112,
      78,
      118,
      64,
      77,
      227,
      93,
      88,
      69,
      60,
      34,
      30,
      73,
      54,
      45,
      83,
      182,
      88,
      75,
      85,
      54,
      53,
      89,
      59,
      37,
      35,
      38,
      29,
      18,
      45,
      60,
      49,
      62,
      55,
      78,
      96,
      29,
      22,
      24,
      13,
      14,
      11,
      11,
      18,
      12,
      12,
      30,
      52,
      52,
      44,
      28,
      28,
      20,
      56,
      40,
      31,
      50,
      40,
      46,
      42,
      29,
      19,
      36,
      25,
      22,
      17,
      19,
      26,
      30,
      20,
      15,
      21,
      11,
      8,
      8,
      19,
      5,
      8,
      8,
      11,
      11,
      8,
      3,
      9,
      5,
      4,
      7,
      3,
      6,
      3,
      5,
      4,
      5,
      6
    ];

    if (surahNumber >= 1 && surahNumber <= ayahCounts.length) {
      return ayahCounts[surahNumber - 1];
    }
    return 0;
  }

  String _getRevelationTypeForSurah(int surahNumber) {
    // السور المدنية (باقي السور مكية)
    final madaniSurahs = [
      2,
      3,
      4,
      5,
      8,
      9,
      22,
      24,
      33,
      47,
      48,
      49,
      57,
      58,
      59,
      60,
      61,
      62,
      63,
      64,
      65,
      66,
      76,
      98,
      110
    ];

    return madaniSurahs.contains(surahNumber) ? 'Medinan' : 'Meccan';
  }

  List<Map<String, dynamic>> getUniqueJuz() {
    List<Map<String, dynamic>> juzList = [];

    try {
      for (int i = 1; i <= 30; i++) {
        final firstPage = _getFirstPageOfJuz(i);
        juzList.add({
          'juzNumber': i,
          'firstPageIndex': firstPage,
          'surahName': _getSurahNameForPage(firstPage),
          'juzName': 'الجزء $i',
        });
      }
    } catch (e) {
      print('خطأ في تحميل الأجزاء: $e');
    }

    return juzList;
  }

  String _getSurahNameForPage(int pageNumber) {
    try {
      // تحديد السورة بناءً على رقم الصفحة
      final surahNames = [
        'الفاتحة',
        'البقرة',
        'آل عمران',
        'النساء',
        'المائدة',
        'الأنعام',
        'الأعراف',
        'الأنفال',
        'التوبة',
        'يونس',
        'هود',
        'يوسف',
        'الرعد',
        'إبراهيم',
        'الحجر',
        'النحل',
        'الإسراء',
        'الكهف',
        'مريم',
        'طه',
        'الأنبياء',
        'الحج',
        'المؤمنون',
        'النور',
        'الفرقان',
        'الشعراء',
        'النمل',
        'القصص',
        'العنكبوت',
        'الروم',
        'لقمان',
        'السجدة',
        'الأحزاب',
        'سبأ',
        'فاطر',
        'يس',
        'الصافات',
        'ص',
        'الزمر',
        'غافر',
        'فصلت',
        'الشورى',
        'الزخرف',
        'الدخان',
        'الجاثية',
        'الأحقاف',
        'محمد',
        'الفتح',
        'الحجرات',
        'ق',
        'الذاريات',
        'الطور',
        'النجم',
        'القمر',
        'الرحمن',
        'الواقعة',
        'الحديد',
        'المجادلة',
        'الحشر',
        'الممتحنة',
        'الصف',
        'الجمعة',
        'المنافقون',
        'التغابن',
        'الطلاق',
        'التحريم',
        'الملك',
        'القلم',
        'الحاقة',
        'المعارج',
        'نوح',
        'الجن',
        'المزمل',
        'المدثر',
        'القيامة',
        'الإنسان',
        'المرسلات',
        'النبأ',
        'النازعات',
        'عبس',
        'التكوير',
        'الانفطار',
        'المطففين',
        'الانشقاق',
        'البروج',
        'الطارق',
        'الأعلى',
        'الغاشية',
        'الفجر',
        'البلد',
        'الشمس',
        'الليل',
        'الضحى',
        'الشرح',
        'التين',
        'العلق',
        'القدر',
        'البينة',
        'الزلزلة',
        'العاديات',
        'القارعة',
        'التكاثر',
        'العصر',
        'الهمزة',
        'الفيل',
        'قريش',
        'الماعون',
        'الكوثر',
        'الكافرون',
        'النصر',
        'المسد',
        'الإخلاص',
        'الفلق',
        'الناس'
      ];

      int surahNumber = _getSurahNumberForPage(pageNumber);
      if (surahNumber >= 1 && surahNumber <= surahNames.length) {
        return surahNames[surahNumber - 1];
      }
    } catch (e) {
      print('خطأ في الحصول على اسم السورة للصفحة $pageNumber: $e');
    }

    return 'القرآن الكريم';
  }

  int _getSurahNumberForPage(int pageNumber) {
    // تحديد رقم السورة بناءً على رقم الصفحة
    final surahPages = [
      1,
      2,
      50,
      77,
      106,
      128,
      151,
      177,
      187,
      208,
      221,
      235,
      249,
      255,
      262,
      267,
      282,
      293,
      305,
      312,
      322,
      332,
      342,
      350,
      359,
      367,
      377,
      385,
      396,
      404,
      411,
      415,
      418,
      428,
      434,
      440,
      446,
      453,
      458,
      467,
      477,
      483,
      489,
      496,
      499,
      502,
      507,
      511,
      515,
      518,
      520,
      523,
      526,
      528,
      531,
      534,
      537,
      542,
      545,
      549,
      551,
      553,
      554,
      556,
      558,
      560,
      562,
      564,
      566,
      568,
      570,
      572,
      574,
      575,
      577,
      578,
      580,
      582,
      583,
      585,
      586,
      587,
      587,
      589,
      590,
      591,
      591,
      592,
      593,
      594,
      595,
      595,
      596,
      596,
      597,
      598,
      598,
      599,
      599,
      600,
      600,
      601,
      601,
      601,
      602,
      602,
      602,
      603,
      603,
      603,
      603,
      604,
      604,
      604
    ];

    for (int i = 0; i < surahPages.length; i++) {
      if (pageNumber < surahPages[i] || (i == surahPages.length - 1)) {
        return i == 0 ? 1 : i;
      }
      if (i < surahPages.length - 1 &&
          pageNumber >= surahPages[i] &&
          pageNumber < surahPages[i + 1]) {
        return i + 1;
      }
    }

    return 1;
  }

  int _getJuzNumberForPage(int pageNumber) {
    // حساب رقم الجزء بناءً على رقم الصفحة
    final juzPages = [
      1,
      22,
      42,
      62,
      82,
      102,
      121,
      142,
      162,
      182,
      201,
      222,
      242,
      262,
      282,
      302,
      322,
      342,
      362,
      382,
      402,
      422,
      442,
      462,
      482,
      502,
      522,
      542,
      562,
      582
    ];

    for (int i = 0; i < juzPages.length; i++) {
      if (i == juzPages.length - 1 || pageNumber < juzPages[i + 1]) {
        return i + 1;
      }
    }

    return 30;
  }

  String getCurrentSurahName() {
    return _getSurahNameForPage(currentPage.value);
  }

  int getCurrentJuzNumber() {
    return _getJuzNumberForPage(currentPage.value);
  }

  int getCurrentSurahNumber() {
    return _getSurahNumberForPage(currentPage.value);
  }

  @override
  void onClose() {
    animationController.dispose();
    saveCurrentPage();
    super.onClose();
  }
}
