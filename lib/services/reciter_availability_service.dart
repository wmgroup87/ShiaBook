import 'package:dio/dio.dart';

class ReciterAvailabilityService {
  static final Dio _dio = Dio();

  // فحص توفر القارئ للسورة المحددة
  static Future<bool> isReciterAvailable(
      String reciterName, int surahNumber) async {
    final testUrls = await _getTestUrls(reciterName, surahNumber);

    for (final url in testUrls) {
      if (await _isUrlWorking(url)) {
        return true;
      }
    }

    return false;
  }

  static Future<List<String>> _getTestUrls(
      String reciterName, int surahNumber) async {
    switch (reciterName) {
      case 'كريم منصوري':
        return [
          'https://server12.mp3quran.net/kareem/${surahNumber.toString().padLeft(3, '0')}.mp3',
          'https://everyayah.com/data/Kareem_Mansoori_40kbps/${surahNumber.toString().padLeft(3, '0')}001.mp3',
          'https://download.quranicaudio.com/quran/kareem_mansoori/${surahNumber.toString().padLeft(3, '0')}.mp3',
        ];

      case 'ميثم التمار':
        return [
          'https://server8.mp3quran.net/maitham/${surahNumber.toString().padLeft(3, '0')}.mp3',
          'https://everyayah.com/data/Maitham_AlTammar_64kbps/${surahNumber.toString().padLeft(3, '0')}001.mp3',
        ];

      case 'باسم الكربلائي':
        return [
          'https://server15.mp3quran.net/basim/${surahNumber.toString().padLeft(3, '0')}.mp3',
        ];

      default:
        return [];
    }
  }

  static Future<bool> _isUrlWorking(String url) async {
    try {
      final response = await _dio.head(
        url,
        options: Options(
          validateStatus: (status) => status! < 500,
          receiveTimeout: const Duration(seconds: 5),
          // connectTimeout: const Duration(seconds: 5),
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // الحصول على قائمة السور المتاحة للقارئ
  static Future<List<int>> getAvailableSurahs(String reciterName) async {
    final availableSurahs = <int>[];

    // فحص أول 10 سور كعينة
    for (int i = 1; i <= 10; i++) {
      if (await isReciterAvailable(reciterName, i)) {
        availableSurahs.add(i);
      }
    }

    // إذا كانت العينة تعمل، افترض أن باقي السور متاحة
    if (availableSurahs.length >= 5) {
      for (int i = 11; i <= 114; i++) {
        availableSurahs.add(i);
      }
    }

    return availableSurahs;
  }
}
