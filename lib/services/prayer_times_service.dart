import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesService {
  static const String _latKey = 'user_latitude';
  static const String _lngKey = 'user_longitude';
  static const String _cityKey = 'user_city';

  // التحقق من إعدادات الموقع وطلب الأذونات
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  // الحصول على الموقع الحالي
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) {
        print('لا يوجد إذن للوصول للموقع');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      await _saveLocation(position.latitude, position.longitude);
      print(
        'تم الحصول على الموقع: ${position.latitude}, ${position.longitude}',
      );

      // التحقق من صحة الموقع (هل هو في منطقة عربية/إسلامية؟)
      if (_isValidLocation(position.latitude, position.longitude)) {
        return position;
      } else {
        print('الموقع خارج المنطقة المتوقعة، سيتم استخدام الموقع الافتراضي');
        return null;
      }
    } catch (e) {
      print('خطأ في الحصول على الموقع: $e');
      return null;
    }
  }

  // التحقق من صحة الموقع (المنطقة العربية/الإسلامية)
  static bool _isValidLocation(double lat, double lng) {
    // نطاق تقريبي للمنطقة العربية والإسلامية
    // خط العرض: من 10 إلى 45 شمالاً
    // خط الطول: من 25 إلى 75 شرقاً
    return lat >= 10 && lat <= 45 && lng >= 25 && lng <= 75;
  }

  // حفظ الموقع
  static Future<void> _saveLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);
  }

  // الحصول على الموقع المحفوظ
  static Future<Map<String, double>?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);

    if (lat != null && lng != null && _isValidLocation(lat, lng)) {
      return {'lat': lat, 'lng': lng};
    }
    return null;
  }

  // حساب أوقات الصلاة الجعفرية
  static Future<PrayerTimesModel?> calculatePrayerTimes({
    double? latitude,
    double? longitude,
    DateTime? date,
  }) async {
    try {
      double? lat = latitude;
      double? lng = longitude;

      if (lat == null || lng == null) {
        final savedLocation = await getSavedLocation();
        if (savedLocation != null) {
          lat = savedLocation['lat'];
          lng = savedLocation['lng'];
          print('استخدام الموقع المحفوظ: $lat, $lng');
        } else {
          print('جاري الحصول على الموقع الحالي...');
          final position = await getCurrentLocation();
          if (position != null) {
            lat = position.latitude;
            lng = position.longitude;
          }
        }
      }

      // إذا لم نحصل على موقع صحيح، استخدم بغداد كموقع افتراضي
      if (lat == null || lng == null || !_isValidLocation(lat, lng)) {
        print('استخدام الموقع الافتراضي: بغداد');
        lat = 33.3152;
        lng = 44.3661;
      }

      final coordinates = Coordinates(lat, lng);
      final calculationDate = date ?? DateTime.now();

      // إعدادات المذهب الجعفري الصحيحة
      final params = CalculationParameters(
        fajrAngle: 18.0, // زاوية الفجر للمذهب الجعفري (15 درجة بدلاً من 16)
        ishaAngle: 14.0, // زاوية العشاء للمذهب الجعفري
        method:
            CalculationMethod.muslim_world_league, // طريقة الرابطة الإسلامية
        madhab: Madhab.shafi, // المذهب الشافعي أقرب للجعفري في حساب العصر
      );

      // تعديل وقت الفجر ليبدأ من بداية الفجر الصادق (15 درجة)

      // بدون تعديلات إضافية - سنحسب المغرب يدوياً
      final prayerTimes = PrayerTimes.today(coordinates, params);

      // حساب الغروب الفعلي (sunset)
      final sunset = prayerTimes.maghrib;

      // المغرب الجعفري = الغروب + 17 دقيقة
      final jaafariMaghrib = sunset.add(const Duration(minutes: 17));

      print('الإحداثيات المستخدمة: $lat, $lng');
      print('الفجر: ${prayerTimes.fajr}');
      print('الشروق: ${prayerTimes.sunrise}');
      print('الظهر: ${prayerTimes.dhuhr}');
      print('العصر: ${prayerTimes.asr}');
      print('الغروب الفعلي: $sunset');
      print('المغرب الجعفري (الغروب + 17 دقيقة): $jaafariMaghrib');
      print('العشاء: ${prayerTimes.isha}');

      // حساب منتصف الليل الشرعي (نصف الليل بين المغرب والفجر التالي)
      final nextDay = DateComponents.from(
        calculationDate.add(const Duration(days: 1)),
      );
      final nextFajr = PrayerTimes(coordinates, nextDay, params).fajr;

      // حساب منتصف الليل الشرعي (نصف المدة بين المغرب والفجر)
      final midnight = sunset.add(
        nextFajr.difference(sunset) ~/ 2,
      );

      print('الفجر التالي: $nextFajr');
      print('منتصف الليل الشرعي: $midnight');

      final locationName = _getLocationName(lat, lng);

      return PrayerTimesModel(
        fajr: _formatTime(prayerTimes.fajr),
        sunrise: _formatTime(prayerTimes.sunrise),
        dhuhr: _formatTime(prayerTimes.dhuhr),
        sunset: _formatTime(sunset),
        maghrib: _formatTime(jaafariMaghrib), // المغرب الجعفري
        midnight: _formatTime(midnight),
        date: _formatDate(calculationDate),
        location: locationName,
      );
    } catch (e) {
      print('خطأ في حساب أوقات الصلاة: $e');
      return null;
    }
  }

  // تحديد اسم الموقع بناءً على الإحداثيات
  static String _getLocationName(double lat, double lng) {
    // بعض المواقع الشائعة
    if (lat >= 33.0 && lat <= 34.0 && lng >= 44.0 && lng <= 45.0) {
      return 'بغداد';
    } else if (lat >= 31.5 && lat <= 32.5 && lng >= 44.0 && lng <= 45.0) {
      return 'النجف الأشرف';
    } else if (lat >= 32.5 && lat <= 33.5 && lng >= 44.0 && lng <= 45.0) {
      return 'كربلاء المقدسة';
    } else if (lat >= 36.0 && lat <= 37.0 && lng >= 43.0 && lng <= 44.0) {
      return 'الموصل';
    } else if (lat >= 30.0 && lat <= 31.0 && lng >= 47.0 && lng <= 48.0) {
      return 'البصرة';
    } else {
      return 'الموقع الحالي';
    }
  }

  // تنسيق الوقت بصيغة 12 ساعة
  static String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period;

    if (hour == 0) {
      hour = 12;
      period = 'ص';
    } else if (hour < 12) {
      period = 'ص';
    } else if (hour == 12) {
      period = 'م';
    } else {
      hour = hour - 12;
      period = 'م';
    }

    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr $period';
  }

  // تنسيق التاريخ
  static String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // الحصول على الصلاة التالية (المذهب الجعفري)
  static String getNextPrayer(PrayerTimesModel prayerTimes) {
    final now = DateTime.now();

    final prayers = [
      {'name': 'الفجر', 'time': prayerTimes.fajr},
      {
        'name': 'الظهرين',
        'time': prayerTimes.dhuhr,
      }, // الظهر والعصر معاً في الجعفري
      {'name': 'الغروب', 'time': prayerTimes.sunset}, // الغروب
      {
        'name': 'المغربين',
        'time': prayerTimes.maghrib,
      }, // المغرب والعشاء معاً في الجعفري
    ];

    for (var prayer in prayers) {
      final prayerDateTime = _parseTimeString(prayer['time']!);
      if (now.isBefore(prayerDateTime)) {
        return prayer['name']!;
      }
    }
    return 'الفجر'; // إذا انتهى اليوم، الصلاة التالية هي فجر اليوم التالي
  }

  // تحويل النص إلى DateTime للمقارنة
  static DateTime _parseTimeString(String timeString) {
    final now = DateTime.now();
    final parts = timeString.split(' ');
    final timePart = parts[0];
    final period = parts.length > 1 ? parts[1] : '';

    final timeParts = timePart.split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (period == 'م' && hour != 12) {
      hour += 12;
    } else if (period == 'ص' && hour == 12) {
      hour = 0;
    }

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // استخدام موقع افتراضي (بغداد)
  static Future<PrayerTimesModel> getDefaultPrayerTimes() async {
    // إحداثيات بغداد
    const double baghdadLat = 33.3152;
    const double baghdadLng = 44.3661;

    return await calculatePrayerTimes(
          latitude: baghdadLat,
          longitude: baghdadLng,
        ) ??
        PrayerTimesModel(
          fajr: '04:30 ص',
          sunrise: '06:00 ص',
          dhuhr: '12:00 م',
          sunset: '06:30 م',
          maghrib: '06:47 م', // الغروب + 17 دقيقة
          midnight: '11:15 م',
          date: _formatDate(DateTime.now()),
          location: 'بغداد (افتراضي)',
        );
  }

  // دالة لاختبار الأوقات مع طرق مختلفة
  static Future<void> testPrayerTimes(double lat, double lng) async {
    // استخدام بغداد للاختبار إذا كان الموقع خارج المنطقة
    if (!_isValidLocation(lat, lng)) {
      lat = 33.3152;
      lng = 44.3661;
      print('تم تغيير الموقع للاختبار إلى بغداد: $lat, $lng');
    }

    final coordinates = Coordinates(lat, lng);

    print('=== اختبار طرق حساب مختلفة ===');
    print('الإحداثيات: $lat, $lng');

    // الطريقة العادية (السنية)
    final sunniParams = CalculationMethod.muslim_world_league.getParameters();
    final sunniTimes = PrayerTimes.today(coordinates, sunniParams);
    print(
      'مكة - الفجر: ${_formatTime(sunniTimes.fajr)}, الظهر: ${_formatTime(sunniTimes.dhuhr)}',
    );

    // طريقة مصر
    final egyptParams = CalculationMethod.egyptian.getParameters();
    final egyptTimes = PrayerTimes.today(coordinates, egyptParams);
    print(
      'مصر - الفجر: ${_formatTime(egyptTimes.fajr)}, الظهر: ${_formatTime(egyptTimes.dhuhr)}',
    );

    // طريقة كراتشي
    final karachiParams = CalculationMethod.karachi.getParameters();
    final karachiTimes = PrayerTimes.today(coordinates, karachiParams);
    print(
      'كراتشي - الفجر: ${_formatTime(karachiTimes.fajr)}, الظهر: ${_formatTime(karachiTimes.dhuhr)}',
    );

    // طريقة طهران (الجعفرية)
    final tehranParams = CalculationMethod.tehran.getParameters();
    final tehranTimes = PrayerTimes.today(coordinates, tehranParams);
    print(
      'طهران (جعفري) - الفجر: ${_formatTime(tehranTimes.fajr)}, الظهر: ${_formatTime(tehranTimes.dhuhr)}',
    );

    // طريقة مخصصة للمذهب الجعفري
    final jaafariParams = CalculationParameters(
      fajrAngle: 16.0,
      ishaAngle: 14.0,
      method: CalculationMethod.other,
      madhab: Madhab.hanafi,
    );
    final jaafariTimes = PrayerTimes.today(coordinates, jaafariParams);
    print(
      'جعفري مخصص - الفجر: ${_formatTime(jaafariTimes.fajr)}, الظهر: ${_formatTime(jaafariTimes.dhuhr)}',
    );
  }
}
