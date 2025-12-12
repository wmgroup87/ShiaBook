import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';
import '../services/prayer_times_service.dart';
import '../services/adhan_service.dart';
import 'prayer_times_dialog.dart';

class PrayerHeaderWidget extends StatefulWidget {
  const PrayerHeaderWidget({super.key});

  @override
  State<PrayerHeaderWidget> createState() => _PrayerHeaderWidgetState();
}

class _PrayerHeaderWidgetState extends State<PrayerHeaderWidget> {
  PrayerTimesModel? prayerTimes;
  String nextPrayer = '';
  String nextPrayerTime = '';
  bool isLoading = true;
  String hijriDateString = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadPrayerTimes();
    _loadHijriDate();
    _startTimer();
  }

  Future<void> _initializeServices() async {
    await AdhanService.initialize();
  }

  void _startTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _loadPrayerTimes();
        _startTimer();
      }
    });
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final times = await PrayerTimesService.calculatePrayerTimes();
      if (times != null && mounted) {
        setState(() {
          prayerTimes = times;
          _updateNextPrayer();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadHijriDate() async {
    final dateString = await _getHijriDate();
    if (mounted) {
      setState(() {
        hijriDateString = dateString;
      });
    }
  }

  void _updateNextPrayer() {
    if (prayerTimes == null) return;

    final now = DateTime.now();

    // قائمة الصلوات الأساسية في المذهب الجعفري
    final prayers = [
      {'name': 'الفجر', 'time': prayerTimes!.fajr},
      {'name': 'الشروق', 'time': prayerTimes!.sunrise},
      {'name': 'الظهر', 'time': prayerTimes!.dhuhr},
      {'name': 'المغرب', 'time': prayerTimes!.maghrib},
    ];

    // البحث عن الصلاة التالية
    DateTime? nextPrayerDateTime;
    String? nextPrayerName;
    String? nextPrayerTimeStr;

    for (var prayer in prayers) {
      final prayerDateTime = _parseTimeString(prayer['time']!);

      // إذا كان وقت الصلاة لم يحن بعد اليوم
      if (now.isBefore(prayerDateTime)) {
        nextPrayerDateTime = prayerDateTime;
        nextPrayerName = prayer['name']!;
        nextPrayerTimeStr = prayer['time']!;
        break;
      }
    }

    // إذا لم نجد صلاة اليوم، فالصلاة التالية هي فجر الغد
    if (nextPrayerDateTime == null) {
      nextPrayerName = 'الفجر';
      nextPrayerTimeStr = prayerTimes!.fajr;
      nextPrayerDateTime =
          _parseTimeString(prayerTimes!.fajr).add(const Duration(days: 1));
    }

    setState(() {
      nextPrayer = nextPrayerName!;
      nextPrayerTime = nextPrayerTimeStr!;
    });

    print('الصلاة التالية: $nextPrayer في $nextPrayerTime');
  }

  DateTime _parseTimeString(String timeString) {
    final now = DateTime.now();

    // إزالة المسافات الإضافية
    timeString = timeString.trim();

    // تقسيم النص للحصول على الوقت والفترة (ص/م)
    final parts = timeString.split(' ');
    final timePart = parts[0];
    final period = parts.length > 1 ? parts[1] : '';

    // تقسيم الوقت للحصول على الساعة والدقيقة
    final timeParts = timePart.split(':');
    if (timeParts.length != 2) {
      print('خطأ في تحليل الوقت: $timeString');
      return now;
    }

    int hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    // تحويل إلى نظام 24 ساعة
    if (period == 'م' && hour != 12) {
      hour += 12;
    } else if (period == 'ص' && hour == 12) {
      hour = 0;
    }

    // إنشاء DateTime للوقت اليوم
    var dateTime = DateTime(now.year, now.month, now.day, hour, minute);

    return dateTime;
  }

  // دالة مساعدة لحساب الوقت المتبقي
  String _getTimeRemaining() {
    if (prayerTimes == null || nextPrayerTime.isEmpty) return '';

    final now = DateTime.now();
    final nextDateTime = _parseTimeString(nextPrayerTime);

    var difference = nextDateTime.difference(now);

    // إذا كان الوقت قد مضى، احسب للغد
    if (difference.isNegative) {
      final tomorrow = nextDateTime.add(const Duration(days: 1));
      difference = tomorrow.difference(now);
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return 'خلال $hoursس $minutesد';
    } else {
      return 'خلال $minutesد';
    }
  }

  Future<String> _getHijriDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adjustment = prefs.getString('hijri_date_adjustment') ?? '0';

      final hijriDate = HijriCalendar.now();
      hijriDate.hDay += int.parse(adjustment);

      final months = [
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

      return '${hijriDate.hDay} ${months[hijriDate.hMonth - 1]} ${hijriDate.hYear}هـ';
    } catch (e) {
      print('خطأ في تحميل التاريخ الهجري: $e');
      return 'التاريخ الهجري';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الصلاة القادمة
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (prayerTimes != null) {
                      showPrayerTimesDialog(context, prayerTimes!);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'الصلاة القادمة',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (isLoading)
                          const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    nextPrayer,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      nextPrayerTime,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getTimeRemaining(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // خط فاصل
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // التاريخ الهجري
              Expanded(
                child: InkWell(
                  onTap: () {
                    // يمكنك إضافة وظيفة هنا
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'التاريخ الهجري',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hijriDateString.isEmpty
                              ? 'جاري التحميل...'
                              : hijriDateString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
