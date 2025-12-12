import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shia_book/models/holy_place.dart';
import 'package:shia_book/controllers/holy_places_controller.dart';
import 'package:shia_book/widgets/add_review_dialog.dart'; // Add this line

class PlaceDetailsDialog extends StatelessWidget {
  final HolyPlace place;
  const PlaceDetailsDialog({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HolyPlacesController>();

    return AlertDialog(
      title: Row(
        children: [
          SvgPicture.asset(
            place.icon,
            height: 30,
            width: 30,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              place.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                place.description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              place.details,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الإحداثيات:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('خط العرض: ${place.latitude.toStringAsFixed(6)}'),
                  Text('خط الطول: ${place.longitude.toStringAsFixed(6)}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // حساب المسافة من الموقع الحالي
            Obx(() {
              if (controller.currentLocation.value != null) {
                final distance = _calculateDistance(
                  controller.currentLocation.value!.latitude,
                  controller.currentLocation.value!.longitude,
                  place.latitude,
                  place.longitude,
                );

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'المسافة من موقعك: ${distance.toStringAsFixed(1)} كم',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 16),
            const Text(
              'التقييمات والتعليقات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),

            if (place.reviews.isEmpty)
              const Text('لا توجد تقييمات بعد')
            else
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        place.averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(' من 5')
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...place.reviews.map((review) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                    5,
                                    (index) => Icon(
                                          Icons.star,
                                          size: 16,
                                          color:
                                              index < (review['rating'] as int)
                                                  ? Colors.amber
                                                  : Colors.grey,
                                        )),
                              ),
                              const SizedBox(height: 4),
                              Text(review['comment']),
                              const SizedBox(height: 4),
                              Text(
                                review['date'],
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Get.dialog(AddReviewDialog(place: place));
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة تقييم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('إغلاق'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Get.back();
            controller.focusOnPlace(place);
          },
          icon: const Icon(Icons.center_focus_strong),
          label: const Text('التركيز على المكان'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // نصف قطر الأرض بالكيلومتر

    final double lat1Rad = lat1 * (3.14159265359 / 180);
    final double lat2Rad = lat2 * (3.14159265359 / 180);
    final double deltaLatRad = (lat2 - lat1) * (3.14159265359 / 180);
    final double deltaLngRad = (lon2 - lon1) * (3.14159265359 / 180);

    final double a = (sin(deltaLatRad / 2) * sin(deltaLatRad / 2)) +
        (cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
