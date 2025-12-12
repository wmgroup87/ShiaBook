import 'package:dio/dio.dart';

class ShiaQuranService {
  static final Dio _dio = Dio();

  // مصادر القراء الشيعة
  static const Map<String, Map<String, dynamic>> shiaReciters = {
    'كريم منصوري': {
      'code': 'karim_mansouri',
      'sources': [
        'https://server12.mp3quran.net/kareem/',
        'https://audio.alkafeel.net/quran/karim/',
        'https://media.alhassanain.org/audio/karim_mansouri/',
      ],
      'format': 'surah', // يقرأ السورة كاملة
    },
    'ميثم التمار': {
      'code': 'maitham_altammar',
      'sources': [
        'https://audio.alkafeel.net/quran/maitham/',
        'https://server8.mp3quran.net/maitham/',
        'https://media.imamreza.net/audio/maitham/',
      ],
      'format': 'ayah', // يقرأ آية بآية
    },
    'باسم الكربلائي': {
      'code': 'basim_karbalaei',
      'sources': [
        'https://audio.alkafeel.net/quran/basim/',
        'https://media.alhassanain.org/audio/basim/',
        'https://server15.mp3quran.net/basim/',
      ],
      'format': 'surah',
    },
    'أحمد الوائلي': {
      'code': 'ahmed_alwaeli',
      'sources': [
        'https://audio.alkafeel.net/quran/waeli/',
        'https://media.imamreza.net/audio/waeli/',
        'https://archive.org/download/QuranWaeli/',
      ],
      'format': 'surah',
    },
  };

  // البحث عن رابط صالح للقارئ
  static Future<String?> getReciterUrl(
      String reciterName, int surahNumber, int ayahNumber) async {
    final reciterData = shiaReciters[reciterName];
    if (reciterData == null) return null;

    final sources = reciterData['sources'] as List<String>;
    final format = reciterData['format'] as String;

    for (final baseUrl in sources) {
      String? url;

      if (format == 'surah') {
        // للقراء الذين يقرؤون السورة كاملة
        url = await _getSurahUrl(baseUrl, surahNumber);
      } else {
        // للقراء الذين يقرؤون آية بآية
        url = await _getAyahUrl(baseUrl, surahNumber, ayahNumber);
      }

      if (url != null && await _isUrlValid(url)) {
        return url;
      }
    }

    return null;
  }

  static Future<String?> _getSurahUrl(String baseUrl, int surahNumber) async {
    final possibleFormats = [
      '$baseUrl${surahNumber.toString().padLeft(3, '0')}.mp3',
      '${baseUrl}surah_$surahNumber.mp3',
      '${baseUrl}s$surahNumber.mp3',
      '$baseUrl${surahNumber.toString().padLeft(2, '0')}.mp3',
    ];

    for (final url in possibleFormats) {
      if (await _isUrlValid(url)) {
        return url;
      }
    }

    return null;
  }

  static Future<String?> _getAyahUrl(
      String baseUrl, int surahNumber, int ayahNumber) async {
    final possibleFormats = [
      '$baseUrl${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3',
      '${baseUrl}s${surahNumber}_a$ayahNumber.mp3',
      '${baseUrl}surah_${surahNumber}_ayah_$ayahNumber.mp3',
      '$baseUrl${surahNumber}_$ayahNumber.mp3',
    ];

    for (final url in possibleFormats) {
      if (await _isUrlValid(url)) {
        return url;
      }
    }

    return null;
  }

  static Future<bool> _isUrlValid(String url) async {
    try {
      final response = await _dio.head(
        url,
        options: Options(
          validateStatus: (status) => status! < 500,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
          followRedirects: true,
          maxRedirects: 3,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('URL validation failed for $url: $e');
      return false;
    }
  }

  // الحصول على قائمة السور المتاحة للقارئ
  static Future<List<int>> getAvailableSurahs(String reciterName) async {
    final reciterData = shiaReciters[reciterName];
    if (reciterData == null) return [];

    final availableSurahs = <int>[];
    final sources = reciterData['sources'] as List<String>;

    for (int surah = 1; surah <= 114; surah++) {
      for (final baseUrl in sources) {
        final url = await _getSurahUrl(baseUrl, surah);
        if (url != null && await _isUrlValid(url)) {
          availableSurahs.add(surah);
          break;
        }
      }
    }

    return availableSurahs;
  }

  // تحميل معلومات القارئ
  static Map<String, dynamic>? getReciterInfo(String reciterName) {
    return shiaReciters[reciterName];
  }

  // فحص توفر القارئ
  static bool isReciterAvailable(String reciterName) {
    return shiaReciters.containsKey(reciterName);
  }
}
