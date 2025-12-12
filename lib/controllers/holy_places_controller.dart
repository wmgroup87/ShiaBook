import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:shia_book/models/holy_place.dart';
import 'package:shia_book/services/routing_service.dart';
import 'package:shia_book/services/location_permission_service.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';

class HolyPlacesController extends GetxController {
  final RxList<HolyPlace> holyPlaces = <HolyPlace>[].obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final Rx<LatLng> mapCenter = const LatLng(32.3, 44.2).obs;
  final RxDouble mapZoom = 8.0.obs;
  final RxBool showRoute = true.obs;
  final RxBool isLoading = false.obs;
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  final RxBool isLocationLoading = false.obs;
  final RxBool isWalkingMode = false.obs;
  final RxDouble totalDistance = 0.0.obs;
  final RxDouble estimatedWalkingTime = 0.0.obs;
  final RxDouble distanceWalked = 0.0.obs;
  final RxString walkingStatus = 'غير نشط'.obs;
  final RxString locationError = ''.obs;
  final MapController mapController = MapController();

  StreamSubscription<Position>? _positionStream;
  LatLng? _lastPosition;
  final List<LatLng> _walkingPath = [];
  Timer? _locationRetryTimer;

  @override
  void onInit() {
    super.onInit();
    _loadHolyPlaces();
    focusOnCurrentLocation();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _locationRetryTimer?.cancel();
    super.onClose();
  }

  void _loadHolyPlaces() {
    holyPlaces.value = [
      HolyPlace(
        name: 'النجف الأشرف',
        description: 'مرقد الإمام علي (ع)',
        latitude: 31.997174450868602,
        longitude: 44.31455507804393,
        icon: 'assets/icons/najaf.svg',
        details:
            'مدينة النجف الأشرف تضم مرقد أمير المؤمنين الإمام علي بن أبي طالب (عليه السلام)',
      ),
      HolyPlace(
        name: 'كربلاء المقدسة',
        description: 'مرقد الإمام الحسين (ع)',
        latitude: 32.6160,
        longitude: 44.0324,
        icon: 'assets/icons/karbala.svg',
        details:
            'مدينة كربلاء المقدسة تضم مرقد الإمام الحسين وأخيه العباس (عليهما السلام)',
      ),
      HolyPlace(
        name: 'الكوفة',
        description: 'مسجد الكوفة المعظم',
        latitude: 32.0284,
        longitude: 44.4011,
        icon: 'assets/icons/kufa.svg',
        details: 'مسجد الكوفة المعظم ومقام الإمام علي (ع)',
      ),
      HolyPlace(
        name: 'الكاظمية',
        description: 'مرقد الإمامين الكاظمين (ع)',
        latitude: 33.3806,
        longitude: 44.3406,
        icon: 'assets/icons/kadhimiya.svg',
        details: 'مرقد الإمام موسى الكاظم والإمام محمد الجواد (عليهما السلام)',
      ),
      HolyPlace(
        name: 'سامراء',
        description: 'مرقد الإمامين العسكريين (ع)',
        latitude: 34.1975,
        longitude: 43.8742,
        icon: 'assets/icons/samarra.svg',
        details: 'مرقد الإمام علي الهادي والإمام الحسن العسكري (عليهما السلام)',
      ),
    ];
  }

  Future<void> _getCurrentLocation() async {
    try {
      isLocationLoading.value = true;
      locationError.value = '';

      // فحص وطلب الأذونات
      bool hasPermission =
          await LocationPermissionService.checkAndRequestPermissions();
      if (!hasPermission) {
        locationError.value = 'لم يتم منح إذن الموقع';
        return;
      }

      // محاولة الحصول على الموقع مع timeout أطول وإعدادات مرنة
      Position? position;

      try {
        // محاولة أولى بدقة عالية
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        print('فشل في الحصول على موقع بدقة عالية: $e');

        try {
          // محاولة ثانية بدقة متوسطة
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (e2) {
          print('فشل في الحصول على موقع بدقة متوسطة: $e2');

          try {
            // محاولة أخيرة بدقة منخفضة
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 5),
            );
          } catch (e3) {
            print('فشل في الحصول على الموقع نهائياً: $e3');

            // استخدام آخر موقع معروف
            position = await Geolocator.getLastKnownPosition();

            if (position != null) {
              Get.snackbar(
                'تنبيه',
                'تم استخدام آخر موقع معروف. قد لا يكون دقيقاً',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
          }
        }
      }

      if (position != null) {
        currentLocation.value = LatLng(position.latitude, position.longitude);
        _lastPosition = currentLocation.value;
        locationError.value = '';

        // تحديث الطريق من الموقع الحالي إلى كربلاء
        await _updateRouteFromCurrentLocation();

        Get.snackbar(
          'تم تحديد الموقع',
          'تم العثور على موقعك بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        locationError.value = 'لم يتم العثور على الموقع';
        _showLocationErrorDialog();
      }
    } catch (e) {
      locationError.value = 'خطأ في تحديد الموقع: ${e.toString()}';
      print('خطأ في _getCurrentLocation: $e');
      _showLocationErrorDialog();
    } finally {
      isLocationLoading.value = false;
    }
  }

  void _showLocationErrorDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('مشكلة في تحديد الموقع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(locationError.value),
            const SizedBox(height: 12),
            const Text('يمكنك:'),
            const Text('• المحاولة مرة أخرى'),
            const Text('• تحديد موقعك يدوياً على الخريطة'),
            const Text('• التأكد من تفعيل GPS'),
            const Text('• الخروج إلى مكان مفتوح'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _getCurrentLocation();
            },
            child: const Text('المحاولة مرة أخرى'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRouteFromCurrentLocation() async {
    if (currentLocation.value == null) return;

    isLoading.value = true;

    try {
      final karbala = holyPlaces.firstWhere(
        (place) => place.name == 'كربلاء المقدسة',
      );

      final karbalLocation = LatLng(karbala.latitude, karbala.longitude);

      // الحصول على الطريق الحقيقي
      final route = await RoutingService.getRoute(
        currentLocation.value!,
        karbalLocation,
      );

      routePoints.value = route;

      // الحصول على معلومات الطريق
      final routeInfo = await RoutingService.getRouteInfo(
        currentLocation.value!,
        karbalLocation,
      );

      totalDistance.value = routeInfo['distance']!;
      estimatedWalkingTime.value = routeInfo['duration']!;

      Get.snackbar(
        'تم تحديث الطريق',
        'المسافة: ${totalDistance.value.toStringAsFixed(1)} كم\nوقت المشي المتوقع: ${estimatedWalkingTime.value.toStringAsFixed(1)} ساعة',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث الطريق: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void startWalkingMode() async {
    try {
      // فحص الأذونات قبل البدء
      bool hasPermission =
          await LocationPermissionService.checkAndRequestPermissions();
      if (!hasPermission) {
        return;
      }

      if (currentLocation.value == null) {
        Get.snackbar('خطأ', 'يرجى تحديد موقعك أولاً');
        return;
      }

      isWalkingMode.value = true;
      walkingStatus.value = 'جاري المشي...';
      distanceWalked.value = 0.0;
      _walkingPath.clear();

      // بدء تتبع الموقع مع إعدادات محسنة
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // تحديث كل 5 متر
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _updateWalkingProgress(position);
        },
        onError: (error) {
          print('خطأ في تتبع الموقع: $error');
          _handleLocationStreamError(error);
        },
        onDone: () {
          print('انتهى تدفق الموقع');
        },
      );

      Get.snackbar(
        'بدء المشي',
        'تم تفعيل وضع المشي إلى كربلاء المقدسة\nاللهم صل على محمد وآل محمد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('خطأ في startWalkingMode: $e');
      Get.snackbar(
        'خطأ',
        'فشل في بدء وضع المشي: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handleLocationStreamError(dynamic error) {
    print('خطأ في تدفق الموقع: $error');

    if (error.toString().contains('TimeoutException')) {
      // في حالة timeout، حاول الحصول على الموقع مرة أخرى
      _retryLocationUpdate();
    } else {
      walkingStatus.value = 'خطأ في تتبع الموقع';
      Get.snackbar(
        'تنبيه',
        'حدث خطأ في تتبع الموقع. سيتم المحاولة مرة أخرى.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      // إعادة المحاولة بعد 5 ثوان
      _locationRetryTimer = Timer(const Duration(seconds: 5), () {
        if (isWalkingMode.value) {
          _retryLocationUpdate();
        }
      });
    }
  }

  void _retryLocationUpdate() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      _updateWalkingProgress(position);
    } catch (e) {
      print('فشل في إعادة المحاولة: $e');

      // استخدام آخر موقع معروف
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        _updateWalkingProgress(lastPosition);
      }
    }
  }

  void stopWalkingMode() {
    isWalkingMode.value = false;
    walkingStatus.value = 'متوقف';
    _positionStream?.cancel();
    _locationRetryTimer?.cancel();

    Get.snackbar(
      'توقف المشي',
      'تم إيقاف وضع المشي\nالمسافة المقطوعة: ${distanceWalked.value.toStringAsFixed(2)} كم',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _updateWalkingProgress(Position position) {
    try {
      final newLocation = LatLng(position.latitude, position.longitude);

      // تحديث الموقع الحالي
      currentLocation.value = newLocation;

      // حساب المسافة المقطوعة
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // إضافة المسافة فقط إذا كانت أكبر من 3 متر (لتجنب الأخطاء الصغيرة)
        if (distance > 3) {
          distanceWalked.value += distance / 1000; // تحويل إلى كيلومتر
          _walkingPath.add(newLocation);
          _lastPosition = newLocation;

          // تحديث حالة المشي
          final progress = getWalkingProgress();
          if (progress >= 1.0) {
            walkingStatus.value = 'وصلت إلى كربلاء المقدسة! 🎉';
            _showArrivalCelebration();
          } else {
            walkingStatus.value =
                'جاري المشي... ${(progress * 100).toStringAsFixed(1)}% مكتمل';
          }

          // فحص إذا وصل إلى كربلاء (ضمن دائرة نصف قطرها 500 متر)
          final karbala = holyPlaces.firstWhere(
            (place) => place.name == 'كربلاء المقدسة',
          );

          final distanceToKarbala = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            karbala.latitude,
            karbala.longitude,
          );

          if (distanceToKarbala <= 500) {
            _showArrivalNotification();
          }
        }
      } else {
        _lastPosition = newLocation;
        _walkingPath.add(newLocation);
      }
    } catch (e) {
      print('خطأ في _updateWalkingProgress: $e');
    }
  }

  void _showArrivalCelebration() {
    stopWalkingMode();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amberAccent, size: 30),
            const SizedBox(width: 8),
            const Text('مبروك الوصول!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 لقد وصلت إلى كربلاء المقدسة! 🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'المسافة المقطوعة: ${distanceWalked.value.toStringAsFixed(2)} كم',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'نسبة الإنجاز: ${(getWalkingProgress() * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'السلام عليك يا أبا عبد الله الحسين',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'تقبل الله مشيكم وبارك في خطاكم',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('الحمد لله'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showArrivalNotification() {
    Get.snackbar(
      'قريب من كربلاء!',
      'أنت الآن على بُعد أقل من 500 متر من مرقد الإمام الحسين (ع)',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.mosque, color: Colors.white),
    );
  }

  void focusOnCurrentLocation() async {
    if (currentLocation.value != null) {
      mapController.move(currentLocation.value!, 19.0);
    } else {
      await _getCurrentLocation();
      if (currentLocation.value != null) {
        mapController.move(currentLocation.value!, 19.0);
      }
    }
  }

  void focusOnPlace(HolyPlace place) {
    mapController.move(
      LatLng(place.latitude, place.longitude), 
      12.0
    );
  }

  void resetView() {
    mapController.move(const LatLng(32.3, 44.2), 15.0);
  }

  void addCustomPlace(String name, String description, double lat, double lng) {
    final customPlace = HolyPlace(
      name: name,
      description: description,
      latitude: lat,
      longitude: lng,
      icon: 'assets/icons/custom_place.svg',
      details: description,
    );
    holyPlaces.add(customPlace);
  }

  void removePlace(HolyPlace place) {
    holyPlaces.remove(place);
  }

  Future<void> recalculateRoute() async {
    if (currentLocation.value != null) {
      await _updateRouteFromCurrentLocation();
    } else {
      Get.snackbar('تنبيه', 'يرجى تحديد موقعك أولاً');
    }
  }

  double getWalkingProgress() {
    if (totalDistance.value == 0) return 0.0;
    return (distanceWalked.value / totalDistance.value).clamp(0.0, 1.0);
  }

  double getRemainingTime() {
    final remainingDistance = totalDistance.value - distanceWalked.value;
    return remainingDistance / 4; // متوسط سرعة المشي 4 كم/ساعة
  }

  List<LatLng> getWalkingPath() {
    return List.from(_walkingPath);
  }

  void addReview(HolyPlace place, int rating, String comment) {
    final newReview = {
      'rating': rating,
      'comment': comment,
      'date': DateTime.now().toString().substring(0, 10),
    };

    // تحديث قائمة التقييمات
    final updatedReviews = List<Map<String, dynamic>>.from(place.reviews)
      ..add(newReview);

    // حساب متوسط التقييم الجديد
    final totalRatings = updatedReviews.fold(
        0.0, (sum, review) => sum + (review['rating'] as int));
    final newAverage = totalRatings / updatedReviews.length;

    // تحديث مكان القائمة
    final index = holyPlaces.indexWhere((p) => p.name == place.name);
    if (index != -1) {
      holyPlaces[index] = HolyPlace(
        name: place.name,
        description: place.description,
        latitude: place.latitude,
        longitude: place.longitude,
        icon: place.icon,
        details: place.details,
        reviews: updatedReviews,
        averageRating: newAverage,
      );
    }
  }

  void toggleRoute() {
    showRoute.value = !showRoute.value;
  }
}
