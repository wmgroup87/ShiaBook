import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class QiblaCompassView extends StatefulWidget {
  const QiblaCompassView({super.key});

  @override
  State<QiblaCompassView> createState() => _QiblaCompassViewState();
}

class _QiblaCompassViewState extends State<QiblaCompassView>
    with TickerProviderStateMixin {
  late AnimationController _compassController;
  late AnimationController _pulseController;

  double _qiblaDirection = 0.0; // سيتم حسابه بناءً على الموقع الحقيقي
  final double _currentDirection = 0.0; // الاتجاه الحالي للجهاز
  bool _isCalibrated = false;
  bool _isLoadingLocation = true;

  // معلومات الموقع
  double _currentLatitude = 32.0167; // النجف الأشرف كافتراضي
  double _currentLongitude = 44.3167;
  String _currentAddress = 'النجف الأشرف، العراق';
  double _distanceToKaaba = 0.0;
  String _locationError = '';

  @override
  void initState() {
    super.initState();
    _compassController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _initializeLocation();
  }

  @override
  void dispose() {
    _compassController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // تهيئة الموقع وحساب اتجاه القبلة
  Future<void> _initializeLocation() async {
    await _getCurrentLocation();
    _calculateQiblaDirection();
    _calculateDistanceToKaaba();
    _startCompass();
  }

  // الحصول على الموقع الحالي
  Future<void> _getCurrentLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool autoLocationEnabled = prefs.getBool('auto_location_enabled') ?? true;

      if (!autoLocationEnabled) {
        // استخدام الموقع المحفوظ يدوياً
        double? savedLat = prefs.getDouble('manual_latitude');
        double? savedLng = prefs.getDouble('manual_longitude');
        String? savedAddress = prefs.getString('manual_address');

        setState(() {
          _currentLatitude = savedLat!;
          _currentLongitude = savedLng!;
          _currentAddress = savedAddress ?? 'موقع محفوظ';
          _isLoadingLocation = false;
        });
        return;
      }

      // التحقق من خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'خدمة الموقع غير مفعلة';
          _isLoadingLocation = false;
        });
        return;
      }

      // التحقق من الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'تم رفض إذن الموقع';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'تم رفض إذن الموقع نهائياً';
          _isLoadingLocation = false;
        });
        return;
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // تحديد المدينة بناءً على الإحداثيات
      String address =
          _getCityFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _currentAddress = address;
        _isLoadingLocation = false;
        _locationError = '';
      });

      // حفظ الموقع الحالي
      await prefs.setDouble('current_latitude', position.latitude);
      await prefs.setDouble('current_longitude', position.longitude);
      await prefs.setString('current_address', address);
    } catch (e) {
      print('خطأ في الحصول على الموقع: $e');
      setState(() {
        _locationError = 'فشل في تحديد الموقع: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  // تحديد المدينة بناءً على الإحداثيات
  String _getCityFromCoordinates(double latitude, double longitude) {
    // قائمة بالمدن الرئيسية في العراق والمنطقة
    final cities = [
      {'name': 'النجف الأشرف', 'lat': 32.0167, 'lng': 44.3167},
      {'name': 'كربلاء المقدسة', 'lat': 32.6160, 'lng': 44.0242},
      {'name': 'بغداد', 'lat': 33.3152, 'lng': 44.3661},
      {'name': 'البصرة', 'lat': 30.5085, 'lng': 47.7804},
      {'name': 'الموصل', 'lat': 36.3350, 'lng': 43.1189},
      {'name': 'أربيل', 'lat': 36.1911, 'lng': 44.0093},
      {'name': 'السليمانية', 'lat': 35.5650, 'lng': 45.4329},
      {'name': 'الكوت', 'lat': 32.5126, 'lng': 45.8189},
      {'name': 'الناصرية', 'lat': 31.0439, 'lng': 46.2581},
      {'name': 'الحلة', 'lat': 32.4637, 'lng': 44.4206},
      // مدن أخرى في المنطقة
      {'name': 'الكويت', 'lat': 29.3759, 'lng': 47.9774},
      {'name': 'الأحواز', 'lat': 31.3183, 'lng': 48.6706},
      {'name': 'طهران', 'lat': 35.6892, 'lng': 51.3890},
    ];

    String closestCity = 'موقع حالي';
    double minDistance = double.infinity;

    for (var city in cities) {
      double distance = _calculateDistance(
          latitude, longitude, city['lat'] as double, city['lng'] as double);

      if (distance < minDistance) {
        minDistance = distance;
        closestCity = city['name'] as String;
      }
    }

    // إذا كانت المسافة أقل من 30 كم، نعتبرها نفس المدينة
    if (minDistance < 30) {
      return '$closestCity، العراق';
    } else {
      return 'موقع حالي (${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)})';
    }
  }

  // حساب المسافة بين نقطتين
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // نصف قطر الأرض بالكيلومتر

    double dLat = (lat2 - lat1) * (math.pi / 180);
    double dLng = (lng2 - lng1) * (math.pi / 180);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // حساب اتجاه القبلة بناءً على الموقع الحالي
  void _calculateQiblaDirection() {
    // إحداثيات الكعبة المشرفة
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    // تحويل إلى راديان
    double lat1 = _currentLatitude * (math.pi / 180);
    double lng1 = _currentLongitude * (math.pi / 180);
    double lat2 = kaabaLat * (math.pi / 180);
    double lng2 = kaabaLng * (math.pi / 180);

    double dLng = lng2 - lng1;

    double y = math.sin(dLng) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    double bearing = math.atan2(y, x);
    bearing = bearing * (180 / math.pi);
    bearing = (bearing + 360) % 360;

    setState(() {
      _qiblaDirection = bearing;
    });
  }

  // حساب المسافة إلى الكعبة
  void _calculateDistanceToKaaba() {
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    double distance = _calculateDistance(
        _currentLatitude, _currentLongitude, kaabaLat, kaabaLng);

    setState(() {
      _distanceToKaaba = distance;
    });
  }

  // وصف الاتجاه بالكلمات
  String _getDirectionDescription(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) {
      return 'شمال';
    } else if (bearing >= 22.5 && bearing < 67.5) {
      return 'شمال شرق';
    } else if (bearing >= 67.5 && bearing < 112.5) {
      return 'شرق';
    } else if (bearing >= 112.5 && bearing < 157.5) {
      return 'جنوب شرق';
    } else if (bearing >= 157.5 && bearing < 202.5) {
      return 'جنوب';
    } else if (bearing >= 202.5 && bearing < 247.5) {
      return 'جنوب غرب';
    } else if (bearing >= 247.5 && bearing < 292.5) {
      return 'غرب';
    } else {
      return 'شمال غرب';
    }
  }

  void _startCompass() {
    // محاكاة بيانات البوصلة
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCalibrated = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'بوصلة القبلة'.text.xl.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city),
            onPressed: () => _showSavedCities(),
            tooltip: 'اختر مدينة',
          ),
          IconButton(
            icon: const Icon(Icons.edit_location),
            onPressed: () => _setManualLocation(),
            tooltip: 'تحديد الموقع يدوياً',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showQiblaInfo(),
            tooltip: 'معلومات القبلة',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshLocation(),
            tooltip: 'تحديث الموقع',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.green.shade50],
          ),
        ),
        child: Column(
          children: [
            // معلومات الموقع
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_isLoadingLocation)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('جاري تحديد الموقع...'),
                      ],
                    )
                  else ...[
                    Row(
                      children: [
                        Icon(
                          _locationError.isEmpty
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _locationError.isEmpty
                              ? AppColors.primary
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              'الموقع الحالي'
                                  .text
                                  .sm
                                  .color(Colors.grey.shade600)
                                  .make(),
                              Text(
                                _locationError.isEmpty
                                    ? _currentAddress
                                    : 'خطأ في تحديد الموقع',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _locationError.isEmpty
                                      ? Colors.black
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // زر تغيير الموقع
                        IconButton(
                          onPressed: () => _showLocationOptions(),
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'تغيير الموقع',
                        ),
                      ],
                    ),
                    if (_locationError.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationError,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          'اتجاه القبلة',
                          '${_qiblaDirection.toStringAsFixed(1)}°',
                          _getDirectionDescription(_qiblaDirection),
                        ),
                        _buildInfoItem(
                          'المسافة',
                          '${_distanceToKaaba.toStringAsFixed(0)} كم',
                          'إلى الكعبة المشرفة',
                        ),
                        _buildInfoItem(
                          'الدقة',
                          _isCalibrated ? 'عالية' : 'منخفضة',
                          _isCalibrated ? 'معايرة' : 'غير معايرة',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // البوصلة
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // دائرة الخلفية مع النبضات
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 300 + (_pulseController.value * 20),
                          height: 300 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(
                                0.3 - _pulseController.value * 0.3,
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),

                    // البوصلة الرئيسية
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // خطوط الاتجاهات
                          ...List.generate(36, (index) {
                            final angle = index * 10.0;
                            final isMainDirection = angle % 90 == 0;
                            return Transform.rotate(
                              angle: angle * math.pi / 180,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  width: isMainDirection ? 3 : 1,
                                  height: isMainDirection ? 30 : 15,
                                  color: isMainDirection
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            );
                          }),

                          // اتجاهات البوصلة (شمال، شرق، جنوب، غرب)
                          Transform.rotate(
                            angle: 0,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 45),
                                child:
                                    'ش'.text.xl.bold.color(Colors.red).make(),
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: math.pi / 2,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 45),
                                child: Transform.rotate(
                                  angle: -math.pi / 2,
                                  child: 'ق'.text.xl.bold.make(),
                                ),
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: math.pi,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 45),
                                child: Transform.rotate(
                                  angle: -math.pi,
                                  child: 'ج'.text.xl.bold.make(),
                                ),
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: -math.pi / 2,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 45),
                                child: Transform.rotate(
                                  angle: math.pi / 2,
                                  child: 'غ'.text.xl.bold.make(),
                                ),
                              ),
                            ),
                          ),

                          // سهم القبلة
                          Transform.rotate(
                            angle: (_qiblaDirection - _currentDirection) *
                                math.pi /
                                180,
                            child: Center(
                              child: Container(
                                width: 6,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.green,
                                      Colors.green.shade700,
                                      Colors.green.shade900,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // رأس السهم
                          Transform.rotate(
                            angle: (_qiblaDirection - _currentDirection) *
                                math.pi /
                                180,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 80),
                                child: Transform.rotate(
                                  angle:
                                      -(_qiblaDirection - _currentDirection) *
                                          math.pi /
                                          180,
                                  child: Icon(
                                    Icons.arrow_drop_up,
                                    color: Colors.green.shade700,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // نقطة المركز
                          Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // أيقونة الكعبة
                          Transform.rotate(
                            angle: (_qiblaDirection - _currentDirection) *
                                math.pi /
                                180,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 60),
                                child: Transform.rotate(
                                  angle:
                                      -(_qiblaDirection - _currentDirection) *
                                          math.pi /
                                          180,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.home,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // معلومات إضافية وأزرار التحكم
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (!_isCalibrated)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'يرجى تحريك الجهاز في شكل رقم 8 لمعايرة البوصلة',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_isCalibrated) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        'البوصلة معايرة ودقيقة'
                            .text
                            .color(Colors.green)
                            .bold
                            .make(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    'وجه الجهاز نحو السهم الأخضر للتوجه نحو القبلة الشريفة'
                        .text
                        .center
                        .color(Colors.grey.shade600)
                        .make(),
                    const SizedBox(height: 16),
                  ],

                  // أزرار التحكم المحدثة
                  Column(
                    children: [
                      // الصف الأول من الأزرار
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _calibrateCompass(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة معايرة'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _shareQiblaDirection(),
                              icon: const Icon(Icons.share),
                              label: const Text('مشاركة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // الصف الثاني من الأزرار
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showSavedCities(),
                              icon: const Icon(Icons.location_city),
                              label: const Text('اختر مدينة'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _setManualLocation(),
                              icon: const Icon(Icons.edit_location),
                              label: const Text('إدخال يدوي'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, String subtitle) {
    return Column(
      children: [
        value.text.lg.bold.color(AppColors.primary).make(),
        label.text.xs.color(Colors.grey.shade600).make(),
        if (subtitle.isNotEmpty)
          subtitle.text.xs.color(Colors.grey.shade500).make(),
      ],
    );
  }

  void _showQiblaInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('معلومات القبلة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                '🕋 الكعبة المشرفة هي قبلة المسلمين في جميع أنحاء العالم'),
            const SizedBox(height: 12),
            const Text('📍 تقع في المسجد الحرام بمكة المكرمة'),
            const SizedBox(height: 12),
            const Text('🧭 يجب التوجه إليها عند أداء الصلاة'),
            const SizedBox(height: 12),
            const Text('⚠️ تأكد من معايرة البوصلة للحصول على أفضل دقة'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات موقعك الحالي:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📍 الموقع: $_currentAddress',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  Text(
                    '🧭 اتجاه القبلة: ${_qiblaDirection.toStringAsFixed(1)}° (${_getDirectionDescription(_qiblaDirection)})',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  Text(
                    '📏 المسافة للكعبة: ${_distanceToKaaba.toStringAsFixed(0)} كم',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'في المذهب الجعفري الشيعي، يُستحب التوجه نحو القبلة بدقة عند الصلاة والدعاء',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  void _calibrateCompass() {
    setState(() {
      _isCalibrated = false;
    });

    Get.snackbar(
      'معايرة البوصلة',
      'يرجى تحريك الجهاز في شكل رقم 8 لمدة 10 ثوانٍ',
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isCalibrated = true;
        });
        Get.snackbar(
          'تمت المعايرة',
          'البوصلة الآن معايرة ودقيقة',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    });
  }

  void _shareQiblaDirection() {
    final String shareText = '''
🕋 اتجاه القبلة من موقعي:

📍 الموقع: $_currentAddress
🧭 الاتجاه: ${_qiblaDirection.toStringAsFixed(1)}° (${_getDirectionDescription(_qiblaDirection)})
📏 المسافة للكعبة المشرفة: ${_distanceToKaaba.toStringAsFixed(0)} كم

تم حساب الاتجاه باستخدام تطبيق الكتب الشيعية
    ''';

    Get.snackbar(
      'مشاركة اتجاه القبلة',
      shareText,
      duration: const Duration(seconds: 5),
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    Get.snackbar(
      'تحديث الموقع',
      'جاري تحديث الموقع وحساب اتجاه القبلة...',
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );

    await _getCurrentLocation();

    if (_locationError.isEmpty) {
      _calculateQiblaDirection();
      _calculateDistanceToKaaba();

      Get.snackbar(
        'تم التحديث',
        'تم تحديث الموقع وحساب اتجاه القبلة بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'خطأ في التحديث',
        _locationError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // دالة لحفظ الموقع اليدوي
  Future<void> _setManualLocation() async {
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    // تعيين القيم الحالية
    latController.text = _currentLatitude.toString();
    lngController.text = _currentLongitude.toString();
    addressController.text = _currentAddress;

    Get.dialog(
      AlertDialog(
        title: const Text('تحديد الموقع يدوياً'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'خط العرض (Latitude)',
                  hintText: '32.0167',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(
                  labelText: 'خط الطول (Longitude)',
                  hintText: '44.3167',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  hintText: 'النجف الأشرف، العراق',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'يمكنك الحصول على الإحداثيات من خرائط جوجل أو أي تطبيق خرائط آخر',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                double lat = double.parse(latController.text);
                double lng = double.parse(lngController.text);
                String address = addressController.text.trim();

                if (address.isEmpty) {
                  address = 'موقع محفوظ ($lat, $lng)';
                }

                // حفظ الموقع
                final prefs = await SharedPreferences.getInstance();
                await prefs.setDouble('manual_latitude', lat);
                await prefs.setDouble('manual_longitude', lng);
                await prefs.setString('manual_address', address);
                await prefs.setBool('auto_location_enabled', false);

                // تحديث الموقع الحالي
                setState(() {
                  _currentLatitude = lat;
                  _currentLongitude = lng;
                  _currentAddress = address;
                  _locationError = '';
                });

                // إعادة حساب اتجاه القبلة
                _calculateQiblaDirection();
                _calculateDistanceToKaaba();

                Get.back();
                Get.snackbar(
                  'تم الحفظ',
                  'تم حفظ الموقع وحساب اتجاه القبلة',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'خطأ',
                  'يرجى التأكد من صحة الإحداثيات المدخلة',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // دالة لإظهار قائمة المدن المحفوظة
  void _showSavedCities() {
    final cities = [
      {
        'name': 'النجف الأشرف',
        'lat': 32.0167,
        'lng': 44.3167,
        'country': 'العراق'
      },
      {
        'name': 'كربلاء المقدسة',
        'lat': 32.6160,
        'lng': 44.0242,
        'country': 'العراق'
      },
      {'name': 'بغداد', 'lat': 33.3152, 'lng': 44.3661, 'country': 'العراق'},
      {'name': 'البصرة', 'lat': 30.5085, 'lng': 47.7804, 'country': 'العراق'},
      {'name': 'الموصل', 'lat': 36.3350, 'lng': 43.1189, 'country': 'العراق'},
      {'name': 'أربيل', 'lat': 36.1911, 'lng': 44.0093, 'country': 'العراق'},
      {
        'name': 'السليمانية',
        'lat': 35.5650,
        'lng': 45.4329,
        'country': 'العراق'
      },
      {'name': 'الكوت', 'lat': 32.5126, 'lng': 45.8189, 'country': 'العراق'},
      {'name': 'الناصرية', 'lat': 31.0439, 'lng': 46.2581, 'country': 'العراق'},
      {'name': 'الحلة', 'lat': 32.4637, 'lng': 44.4206, 'country': 'العراق'},
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            'اختر مدينة'.text.xl.bold.make(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  final distance = _calculateDistance(
                    _currentLatitude,
                    _currentLongitude,
                    city['lat'] as double,
                    city['lng'] as double,
                  );

                  return ListTile(
                    leading:
                        const Icon(Icons.location_city, color: Colors.blue),
                    title: Text(city['name'] as String),
                    subtitle: Text(
                        '${city['country']} - ${distance.toStringAsFixed(0)} كم'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      // حفظ المدينة المختارة
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setDouble(
                          'manual_latitude', city['lat'] as double);
                      await prefs.setDouble(
                          'manual_longitude', city['lng'] as double);
                      await prefs.setString('manual_address',
                          '${city['name']}, ${city['country']}');
                      await prefs.setBool('auto_location_enabled', false);

                      // تحديث الموقع الحالي
                      setState(() {
                        _currentLatitude = city['lat'] as double;
                        _currentLongitude = city['lng'] as double;
                        _currentAddress = '${city['name']}, ${city['country']}';
                        _locationError = '';
                      });

                      // إعادة حساب اتجاه القبلة
                      _calculateQiblaDirection();
                      _calculateDistanceToKaaba();

                      Get.back();
                      Get.snackbar(
                        'تم التحديث',
                        'تم تحديد الموقع: ${city['name']}',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _setManualLocation();
                    },
                    icon: const Icon(Icons.edit_location),
                    label: const Text('إدخال يدوي'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _refreshLocation();
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('الموقع الحالي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // دالة جديدة لإظهار خيارات الموقع
  void _showLocationOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            'خيارات الموقع'.text.xl.bold.make(),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.my_location, color: Colors.blue),
              title: const Text('استخدام الموقع الحالي'),
              subtitle: const Text('تحديد الموقع باستخدام GPS'),
              onTap: () {
                Get.back();
                _refreshLocation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Colors.green),
              title: const Text('اختيار من المدن المحفوظة'),
              subtitle: const Text('اختر من قائمة المدن العراقية'),
              onTap: () {
                Get.back();
                _showSavedCities();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_location, color: Colors.orange),
              title: const Text('إدخال الإحداثيات يدوياً'),
              subtitle: const Text('أدخل خط العرض والطول'),
              onTap: () {
                Get.back();
                _setManualLocation();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
