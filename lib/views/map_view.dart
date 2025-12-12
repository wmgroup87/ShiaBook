import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/holy_places_controller.dart';
import 'package:shia_book/models/holy_place.dart';
import 'package:shia_book/widgets/add_place_dialog.dart';
import 'package:shia_book/widgets/place_details_dialog.dart';
import 'package:shia_book/widgets/walking_controls_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:lottie/lottie.dart' hide Marker;

class MapView extends GetView<HolyPlacesController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HolyPlacesController>();

    return Scaffold(
      appBar: AppBar(
        title: 'مشي الأربعين - كربلاء المقدسة'.text.lg.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => IconButton(
                icon: controller.isLocationLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.my_location),
                onPressed: controller.focusOnCurrentLocation,
                tooltip: 'موقعي الحالي',
              )),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'recalculate':
                  controller.recalculateRoute();
                  break;
                case 'toggle_route':
                  controller.toggleRoute();
                  break;

                case 'reset_view':
                  controller.resetView();
                  break;

                case 'focus_karbala':
                  final karbala = controller.holyPlaces.firstWhere(
                    (place) => place.name == 'كربلاء المقدسة',
                  );
                  controller.focusOnPlace(karbala);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'recalculate',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('إعادة حساب الطريق'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'toggle_route',
                child: Row(
                  children: [
                    Icon(Icons.route),
                    SizedBox(width: 8),
                    Text('إظهار/إخفاء الطريق'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'focus_karbala',
                child: Row(
                  children: [
                    Icon(Icons.mosque),
                    SizedBox(width: 8),
                    Text('التركيز على كربلاء'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset_view',
                child: Row(
                  children: [
                    Icon(Icons.center_focus_strong),
                    SizedBox(width: 8),
                    Text('إعادة تعيين العرض'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // أدوات التحكم في المشي
          const WalkingControlsWidget(),

          // معلومات الطريق والتقدم
          _buildRouteInfo(),
          // الخريطة
          Expanded(
            child: Obx(() => FlutterMap(
                  mapController: controller.mapController,
                  options: MapOptions(
                    initialCenter:
                        const LatLng(32.3, 44.2), // القيمة الابتدائية
                    initialZoom: 15.0, // القيمة الابتدائية
                    onTap: (tapPosition, point) => _onMapTap(context, point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.shia_book',
                    ),

                    // الطريق المخطط له
                    if (controller.showRoute.value &&
                        controller.routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: controller.routePoints,
                            strokeWidth: 4.0,
                            color: AppColors.primary.withOpacity(0.7),
                            borderStrokeWidth: 1.0,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),

                    // مسار المشي المقطوع
                    if (controller.isWalkingMode.value &&
                        controller.getWalkingPath().isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: controller.getWalkingPath(),
                            strokeWidth: 6.0,
                            color: Colors.green,
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),

                    // علامات الأماكن المقدسة
                    MarkerLayer(
                      markers: [
                        // الأماكن المقدسة
                        ...controller.holyPlaces.map(
                          (place) => Marker(
                            point: LatLng(place.latitude, place.longitude),
                            width: 60,
                            height: 60,
                            child: GestureDetector(
                              onTap: () => _showPlaceDetails(context, place),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _buildPlaceIcon(place),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // الموقع الحالي
                        if (controller.currentLocation.value != null)
                          Marker(
                            point: controller.currentLocation.value!,
                            width: 80,
                            height: 80,
                            child: Container(
                              decoration: BoxDecoration(
                                color: controller.isWalkingMode.value
                                    ? Colors.transparent
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Lottie.asset(
                                controller.isWalkingMode.value
                                    ? 'assets/animations/walking_person.json'
                                    : 'assets/animations/location.json',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                                repeat: true,
                                animate: true,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                )),
          ),
        ],
      ),
      floatingActionButton: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // زر بدء/إيقاف المشي
              FloatingActionButton(
                heroTag: "walking",
                backgroundColor:
                    controller.isWalkingMode.value ? Colors.red : Colors.green,
                onPressed: () {
                  if (controller.isWalkingMode.value) {
                    controller.stopWalkingMode();
                  } else {
                    controller.startWalkingMode();
                  }
                },
                child: Icon(
                  controller.isWalkingMode.value
                      ? Icons.stop
                      : Icons.directions_walk,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // زر الموقع الحالي
              FloatingActionButton(
                heroTag: "location",
                mini: true,
                backgroundColor: Colors.blue,
                onPressed: controller.focusOnCurrentLocation,
                child: controller.isLocationLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.my_location, color: Colors.white),
              ),
            ],
          )),
    );
  }

  Widget _buildPlaceIcon(HolyPlace place) {
    IconData iconData;
    Color iconColor = AppColors.primary;
    switch (place.name) {
      case 'النجف الأ الشريف':
        iconData = Icons.mosque;
        iconColor = Colors.green.shade700;
        break;
      case 'كربلاء المقدسة':
        iconData = Icons.mosque;
        iconColor = Colors.red.shade700;
        break;
      case 'الكوفة':
        iconData = Icons.mosque;
        iconColor = Colors.blue.shade700;
        break;
      case 'الكاظمية':
        iconData = Icons.mosque;
        iconColor = Colors.purple.shade700;
        break;
      case 'سامراء':
        iconData = Icons.mosque;
        iconColor = Colors.orange.shade700;
        break;
      default:
        iconData = Icons.place;
        iconColor = AppColors.primary;
    }

    return Icon(
      iconData,
      size: 30,
      color: iconColor,
    );
  }

  Widget _buildRouteInfo() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: controller.isWalkingMode.value
                ? Colors.green.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.isWalkingMode.value
                  ? Colors.green.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    controller.isWalkingMode.value
                        ? Icons.directions_walk
                        : Icons.route,
                    color: controller.isWalkingMode.value
                        ? Colors.green
                        : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.isWalkingMode.value
                          ? 'مشي الأربعين إلى كربلاء المقدسة'
                          : 'الطريق إلى كربلاء المقدسة',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (controller.totalDistance.value > 0)
                    Text(
                      '${controller.totalDistance.value.toStringAsFixed(1)} كم',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: controller.isWalkingMode.value
                            ? Colors.green
                            : AppColors.primary,
                      ),
                    ),
                ],
              ),

              // شريط التقدم في المشي
              if (controller.isWalkingMode.value) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: controller.getWalkingProgress(),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مقطوع: ${controller.distanceWalked.value.toStringAsFixed(1)} كم',
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      'متبقي: ${(controller.totalDistance.value - controller.distanceWalked.value).toStringAsFixed(1)} كم',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  controller.walkingStatus.value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ));
  }

  void _onMapTap(BuildContext context, LatLng point) {
    if (!controller.isWalkingMode.value) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('إضافة مكان جديد',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('هل تريد إضافة مكان جديد في هذا الموقع؟'),
                const SizedBox(height: 8),
                Text('خط العرض: ${point.latitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12)),
                Text('خط الطول: ${point.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _showAddPlaceDialog(context, point);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      );
    }
  }

  void _showAddPlaceDialog(BuildContext context, [LatLng? point]) {
    showDialog(
      context: context,
      builder: (context) => AddPlaceDialog(location: point),
    );
  }

  void _showPlaceDetails(BuildContext context, HolyPlace place) {
    showDialog(
      context: context,
      builder: (context) => PlaceDetailsDialog(place: place),
    );
  }
}
