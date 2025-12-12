import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/settings_controller.dart';
import 'package:shia_book/views/qibla_compass_view.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PrayerSettingsView extends GetView<SettingsController> {
  const PrayerSettingsView({super.key});

  // دالة للحصول على التاريخ الهجري (نفس الدالة من prayer_header_widget.dart)
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

  // دالة للحصول على الموقع الحالي
  Future<Map<String, dynamic>> _getCurrentLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool autoLocationEnabled = prefs.getBool('auto_location_enabled') ?? true;

      if (!autoLocationEnabled) {
        // استخدام الموقع المحفوظ يدوياً
        double? savedLat = prefs.getDouble('manual_latitude');
        double? savedLng = prefs.getDouble('manual_longitude');
        String? savedAddress = prefs.getString('manual_address');

        return {
          'latitude': savedLat,
          'longitude': savedLng,
          'address': savedAddress ?? 'موقع محفوظ',
          'isManual': true,
        };
            }

      // التحقق من الأذونات
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'latitude': 24.6877,
          'longitude': 46.7219,
          'address': 'الرياض، المملكة العربية السعودية (افتراضي)',
          'error': 'خدمة الموقع غير مفعلة',
        };
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'latitude': 24.6877,
            'longitude': 46.7219,
            'address': 'الرياض، المملكة العربية السعودية (افتراضي)',
            'error': 'تم رفض إذن الموقع',
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'latitude': 24.6877,
          'longitude': 46.7219,
          'address': 'الرياض، المملكة العربية السعودية (افتراضي)',
          'error': 'تم رفض إذن الموقع نهائياً',
        };
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // تحويل الإحداثيات إلى عنوان
      String address = 'غير محدد';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = '${place.locality ?? ''}, ${place.country ?? ''}';
          if (address == ', ') {
            address =
                '${place.administrativeArea ?? ''}, ${place.country ?? ''}';
          }
        }
      } catch (e) {
        print('خطأ في تحويل الإحداثيات إلى عنوان: $e');
        address = 'موقع حالي';
      }

      // حفظ الموقع الحالي
      await prefs.setDouble('current_latitude', position.latitude);
      await prefs.setDouble('current_longitude', position.longitude);
      await prefs.setString('current_address', address);

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'isManual': false,
      };
    } catch (e) {
      print('خطأ في الحصول على الموقع: $e');
      return {
        'latitude': 24.6877,
        'longitude': 46.7219,
        'address': 'الرياض، المملكة العربية السعودية (افتراضي)',
        'error': e.toString(),
      };
    }
  }

  // دالة لتحديث حالة تحديد الموقع التلقائي
  Future<void> _updateAutoLocation(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_location_enabled', enabled);

    if (enabled) {
      // تحديث الموقع فوراً
      await _getCurrentLocation();
    }

    Get.snackbar(
      'تم التحديث',
      'تم ${enabled ? "تفعيل" : "إيقاف"} تحديد الموقع التلقائي',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'إعدادات الصلاة'.text.xl.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Calculation Method
              _buildSection(
                title: 'طريقة الحساب',
                icon: Icons.calculate,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          'اختر طريقة حساب أوقات الصلاة'
                              .text
                              .sm
                              .color(Colors.grey.shade600)
                              .make(),
                          const SizedBox(height: 12),
                          ...[
                            'طهران',
                          ].map(
                            (method) => RadioListTile<String>(
                              title: Text(method),
                              subtitle: Text(_getMethodDescription(method)),
                              value: method,
                              groupValue: controller
                                  .settings.value.prayerCalculationMethod,
                              onChanged: (value) => controller
                                  .updatePrayerCalculationMethod(value!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Hijri Date Adjustment
              _buildSection(
                title: 'تعديل التاريخ الهجري',
                icon: Icons.calendar_month,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          'تعديل التاريخ الهجري حسب رؤية الهلال في منطقتك'
                              .text
                              .sm
                              .color(Colors.grey.shade600)
                              .make(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: controller
                                      .settings.value.hijriDateAdjustment,
                                  decoration: InputDecoration(
                                    labelText: 'عدد الأيام',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  items: ['-2', '-1', '0', '+1', '+2']
                                      .map(
                                        (adj) => DropdownMenuItem(
                                          value: adj,
                                          child: Text(
                                            '$adj ${adj == '0' ? '(بدون تعديل)' : 'يوم'}',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) => controller
                                      .updateHijriDateAdjustment(value!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FutureBuilder<String>(
                                    future: _getHijriDate(),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.hasData
                                            ? 'التاريخ الهجري الحالي: ${snapshot.data}'
                                            : 'جاري تحميل التاريخ الهجري...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Prayer Times Display
              _buildSection(
                title: 'عرض أوقات الصلاة',
                icon: Icons.access_time,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('عرض الثواني'),
                      subtitle: const Text('إظهار الثواني في أوقات الصلاة'),
                      value: true,
                      onChanged: (value) {
                        Get.snackbar(
                          'تم التحديث',
                          'تم ${value ? "تفعيل" : "إيقاف"} عرض الثواني',
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('التنسيق 24 ساعة'),
                      subtitle:
                          const Text('استخدام تنسيق 24 ساعة بدلاً من 12 ساعة'),
                      value: false,
                      onChanged: (value) {
                        Get.snackbar('تم التحديث', 'تم تغيير تنسيق الوقت');
                      },
                    ),
                    SwitchListTile(
                      title: const Text('عرض الوقت المتبقي'),
                      subtitle:
                          const Text('إظهار الوقت المتبقي للصلاة التالية'),
                      value: true,
                      onChanged: (value) {
                        Get.snackbar(
                          'تم التحديث',
                          'تم ${value ? "تفعيل" : "إيقاف"} عرض الوقت المتبقي',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Location Settings - محدث بالموقع الفعلي
              _buildSection(
                title: 'إعدادات الموقع',
                icon: Icons.location_on,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _getCurrentLocation(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final locationData = snapshot.data ??
                        {
                          'latitude': 32.00907,
                          'longitude': 44.330486,
                          'address': 'النجف الأشرف ، العراق (افتراضي)',
                        };

                    return Column(
                      children: [
                        ListTile(
                          title: const Text('الموقع الحالي'),
                          subtitle: Text(locationData['address'] ?? 'غير محدد'),
                          leading: Icon(
                            locationData['isManual'] == true
                                ? Icons.location_city
                                : Icons.my_location,
                            color: locationData['error'] != null
                                ? Colors.orange
                                : AppColors.primary,
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _changeLocation(),
                        ),
                        if (locationData['error'] != null)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(12),
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
                                    locationData['error'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ListTile(
                          title: const Text('خط الطول'),
                          subtitle: Text(
                              '${locationData['longitude']?.toStringAsFixed(4)}° ${locationData['longitude'] > 0 ? 'شرق' : 'غرب'}'),
                          leading:
                              const Icon(Icons.straighten, color: Colors.blue),
                        ),
                        ListTile(
                          title: const Text('خط العرض'),
                          subtitle: Text(
                              '${locationData['latitude']?.toStringAsFixed(4)}° ${locationData['latitude'] > 0 ? 'شمال' : 'جنوب'}'),
                          leading:
                              const Icon(Icons.straighten, color: Colors.green),
                        ),
                        FutureBuilder<bool>(
                          future: _getAutoLocationStatus(),
                          builder: (context, autoSnapshot) {
                            final isAutoEnabled = autoSnapshot.data ?? true;
                            return SwitchListTile(
                              title: const Text('تحديد الموقع تلقائياً'),
                              subtitle: const Text('استخدام GPS لتحديد الموقع'),
                              value: isAutoEnabled,
                              onChanged: (value) => _updateAutoLocation(value),
                              secondary: const Icon(Icons.gps_fixed,
                                  color: Colors.orange),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Prayer Adjustments
              _buildSection(
                title: 'تعديل أوقات الصلاة',
                icon: Icons.tune,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'يمكنك تعديل أوقات الصلاة بإضافة أو طرح دقائق حسب الحاجة',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    _buildPrayerAdjustment('الفجر', 0),
                    _buildPrayerAdjustment('الشروق', 0),
                    _buildPrayerAdjustment('الظهر', 0),
                    _buildPrayerAdjustment('المغرب', 0),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Qibla Direction
              _buildSection(
                title: 'اتجاه القبلة',
                icon: Icons.explore,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _getCurrentLocation(),
                  builder: (context, snapshot) {
                    final locationData = snapshot.data ??
                        {
                          'latitude': 24.6877,
                          'longitude': 46.7219,
                        };

                    final qiblaDirection = _calculateQiblaDirection(
                        locationData['latitude'], locationData['longitude']);

                    return Column(
                      children: [
                        ListTile(
                          title: const Text('اتجاه القبلة من موقعك'),
                          subtitle: Text(
                              '${qiblaDirection.toStringAsFixed(1)}° شمال شرق'),
                          leading:
                              const Icon(Icons.explore, color: Colors.green),
                          trailing: ElevatedButton(
                            onPressed: () => _showQiblaCompass(),
                            child: const Text('البوصلة'),
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('تنبيه اتجاه القبلة'),
                          subtitle: const Text(
                            'تنبيه عند عدم توجه الجهاز للقبلة أثناء الصلاة',
                          ),
                          value: false,
                          onChanged: (value) {
                            Get.snackbar(
                                'قريباً', 'سيتم إضافة هذه الميزة قريباً');
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Advanced Settings
              _buildSection(
                title: 'إعدادات متقدمة',
                icon: Icons.settings_applications,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('زاوية الفجر'),
                      subtitle: const Text('18.5°'),
                      leading:
                          const Icon(Icons.wb_twilight, color: Colors.indigo),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _adjustAngle('الفجر', 18.5),
                    ),
                    SwitchListTile(
                      title: const Text('تطبيق التوقيت الصيفي'),
                      subtitle: const Text('تعديل الأوقات حسب التوقيت الصيفي'),
                      value: false,
                      onChanged: (value) {
                        Get.snackbar(
                          'تم التحديث',
                          'تم ${value ? "تفعيل" : "إيقاف"} التوقيت الصيفي',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _resetPrayerSettings(),
                      icon: const Icon(Icons.refresh, color: Colors.red),
                      label: const Text(
                        'إعادة تعيين',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updatePrayerTimes(),
                      icon: const Icon(Icons.update),
                      label: const Text('تحديث الأوقات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة للحصول على حالة تحديد الموقع التلقائي
  Future<bool> _getAutoLocationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_location_enabled') ?? true;
  }

  // دالة لحساب اتجاه القبلة
  double _calculateQiblaDirection(double latitude, double longitude) {
    // إحداثيات الكعبة المشرفة
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    // تحويل إلى راديان
    double lat1 = latitude * (3.14159265359 / 180);
    double lng1 = longitude * (3.14159265359 / 180);
    double lat2 = kaabaLat * (3.14159265359 / 180);
    double lng2 = kaabaLng * (3.14159265359 / 180);

    double dLng = lng2 - lng1;

    double y = sin(dLng) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);

    double bearing = atan2(y, x);
    bearing = bearing * (180 / 3.14159265359);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                title.text.lg.bold.color(AppColors.primary).make(),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildPrayerAdjustment(String prayer, int adjustment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(prayer,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Get.snackbar(
                      'تم التعديل',
                      'تم تقليل وقت $prayer بدقيقة واحدة',
                    );
                  },
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '$adjustment د',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.snackbar(
                      'تم التعديل',
                      'تم زيادة وقت $prayer بدقيقة واحدة',
                    );
                  },
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMethodDescription(String method) {
    switch (method) {
      case 'طهران':
        return 'معهد الجيوفيزياء، جامعة طهران';
      default:
        return '';
    }
  }

  void _changeLocation() {
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
            'تغيير الموقع'.text.xl.bold.make(),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن مدينة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.my_location, color: AppColors.primary),
              title: const Text('استخدام الموقع الحالي'),
              onTap: () async {
                Get.back();
                await _updateAutoLocation(true);
                Get.snackbar('تم التحديث', 'تم تحديث الموقع باستخدام GPS');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Colors.blue),
              title: const Text('النجف'),
              subtitle: const Text('العراق'),
              onTap: () async {
                Get.back();
                await _setManualLocation(24.6877, 46.7219, 'النجف ، العراق ');
                Get.snackbar('تم التحديث', 'تم تحديد الموقع: الرياض');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Colors.blue),
              title: const Text('النجف الأشرف'),
              subtitle: const Text('العراق'),
              onTap: () async {
                Get.back();
                await _setManualLocation(
                    21.4225, 39.8262, 'النجف الأشرف ، العراق');
                Get.snackbar('تم التحديث', 'تم تحديد الموقع: النجف الأشرف');
              },
            ),
          ],
        ),
      ),
    );
  }

  // دالة لحفظ الموقع اليدوي
  Future<void> _setManualLocation(
      double latitude, double longitude, String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('manual_latitude', latitude);
    await prefs.setDouble('manual_longitude', longitude);
    await prefs.setString('manual_address', address);
    await prefs.setBool('auto_location_enabled', false);
  }

  void _adjustAngle(String prayer, double currentAngle) {
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
            'تعديل زاوية $prayer'.text.xl.bold.make(),
            const SizedBox(height: 20),
            Text('الزاوية الحالية: $currentAngle°'),
            const SizedBox(height: 16),
            Slider(
              value: currentAngle,
              min: 10.0,
              max: 25.0,
              divisions: 30,
              label: '${currentAngle.toStringAsFixed(1)}°',
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar('تم التحديث', 'تم تحديث زاوية $prayer');
                    },
                    child: const Text('حفظ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQiblaCompass() {
    Get.to(() => const QiblaCompassView());
  }

  void _updatePrayerTimes() {
    Get.dialog(
      AlertDialog(
        title: const Text('تحديث أوقات الصلاة'),
        content: const Text('سيتم تحديث أوقات الصلاة حسب الإعدادات الجديدة'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم التحديث',
                'تم تحديث أوقات الصلاة بنجاح',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _resetPrayerSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('إعادة تعيين إعدادات الصلاة'),
        content: const Text(
          'هل تريد إعادة تعيين جميع إعدادات الصلاة إلى القيم الافتراضية؟',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              controller.updatePrayerCalculationMethod('طهران');
              controller.updateHijriDateAdjustment('0');

              // إعادة تعيين إعدادات الموقع
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('auto_location_enabled', true);
              await prefs.remove('manual_latitude');
              await prefs.remove('manual_longitude');
              await prefs.remove('manual_address');

              Get.back();
              Get.snackbar(
                'تم بنجاح',
                'تم إعادة تعيين إعدادات الصلاة',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
