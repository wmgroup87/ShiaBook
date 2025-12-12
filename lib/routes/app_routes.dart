// This is where you define your routes as constants
// so they can be referenced in multiple places

part of 'app_pages.dart';

abstract class Routes {
  static const quran = '/quran';
  static const surah = '/surah';
  static const quranSearch = '/quran/search';
}

abstract class _Paths {
  static const quran = Routes.quran;
  static const surah = Routes.surah;
  static const quranSearch = Routes.quranSearch;
}
