import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/controllers/holy_places_controller.dart';

class WalkingControlsWidget extends StatelessWidget {
  const WalkingControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HolyPlacesController>();

    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط التقدم
            if (controller.totalDistance.value > 0) ...[
              LinearProgressIndicator(
                value: controller.getWalkingProgress(),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  controller.isWalkingMode.value ? Colors.green : Colors.blue,
                ),
                minHeight: 6,
              ),
              const SizedBox(height: 4),
              Text(
                '${(controller.getWalkingProgress() * 100).toStringAsFixed(1)}% مكتمل',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 8),

            // حالة المشي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _getStatusColor(controller.walkingStatus.value)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _getStatusColor(controller.walkingStatus.value)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(controller.walkingStatus.value),
                    size: 16,
                    color: _getStatusColor(controller.walkingStatus.value),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      controller.walkingStatus.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(controller.walkingStatus.value),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoColumn(
      String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('جاري المشي')) {
      return Colors.green;
    } else if (status.contains('وصلت')) {
      return Colors.purple;
    } else if (status.contains('خطأ')) {
      return Colors.red;
    } else if (status.contains('متوقف')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    if (status.contains('جاري المشي')) {
      return Icons.directions_walk;
    } else if (status.contains('وصلت')) {
      return Icons.celebration;
    } else if (status.contains('خطأ')) {
      return Icons.error;
    } else if (status.contains('متوقف')) {
      return Icons.pause;
    } else {
      return Icons.info;
    }
  }
}
