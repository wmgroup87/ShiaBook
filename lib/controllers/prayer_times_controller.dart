import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_times_model.dart';
import '../services/prayer_times_service.dart';

class PrayerTimesController extends GetxController {
  final Rx<PrayerTimesModel?> prayerTimes = Rx<PrayerTimesModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString nextPrayer = ''.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';


      // التحقق من إذن الموقع أولاً
      final hasPermission = await PrayerTimesService.handleLocationPermission();

      PrayerTimesModel? times;

      if (hasPermission) {
        // الحصول على الموقع الحالي لاختبار الأوقات
        final position = await PrayerTimesService.getCurrentLocation();
        if (position != null) {
          // اختبار طرق مختلفة
          await PrayerTimesService.testPrayerTimes(
            position.latitude,
            position.longitude,
          );
        }

        times = await PrayerTimesService.calculatePrayerTimes();
      }

      // إذا فشل الحصول على الموقع، استخدم الموقع الافتراضي
      if (times == null) {
        times = await PrayerTimesService.getDefaultPrayerTimes();
        errorMessage.value =
            'تم استخدام موقع افتراضي. يرجى السماح بالوصول للموقع للحصول على أوقات دقيقة.';
      }

      prayerTimes.value = times;
      nextPrayer.value = PrayerTimesService.getNextPrayer(times);
    } catch (e) {
      errorMessage.value = 'خطأ في تحميل أوقات الصلاة';

      // استخدام أوقات افتراضية في حالة الخطأ
      final defaultTimes = await PrayerTimesService.getDefaultPrayerTimes();
      prayerTimes.value = defaultTimes;
      nextPrayer.value = PrayerTimesService.getNextPrayer(defaultTimes);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPrayerTimes() async {
    await loadPrayerTimes();
  }

  Future<void> requestLocationAndRefresh() async {
    final hasPermission = await PrayerTimesService.handleLocationPermission();
    if (hasPermission) {
      await refreshPrayerTimes();
    } else {
      Get.snackbar(
        'إذن الموقع مطلوب',
        'يرجى السماح بالوصول للموقع من إعدادات التطبيق للحصول على أوقات صلاة دقيقة',
        duration: const Duration(seconds: 5),
      );

      // فتح إعدادات التطبيق
      await Geolocator.openAppSettings();
    }
  }
}
