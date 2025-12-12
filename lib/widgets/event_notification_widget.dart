import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/controllers/islamic_events_controller.dart';
import 'package:shia_book/models/islamic_event.dart';
import 'package:shia_book/views/events/event_detail_view.dart';
import 'package:velocity_x/velocity_x.dart';

class EventNotificationWidget extends StatelessWidget {
  const EventNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // التحقق من وجود الـ controller قبل استخدامه
    if (!Get.isRegistered<IslamicEventsController>()) {
      return const SizedBox.shrink();
    }

    return GetBuilder<IslamicEventsController>(
      builder: (controller) {
        final todayEvents = _getTodayEvents();
        final upcomingEvents = _getUpcomingEvents(controller);

        if (todayEvents.isEmpty && upcomingEvents.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Today's Events
              if (todayEvents.isNotEmpty) ...[
                _buildEventSection(
                  title: 'مناسبات اليوم',
                  events: todayEvents,
                  color: Colors.green,
                  icon: Icons.today,
                ),
                const SizedBox(height: 8),
              ],

              // Upcoming Events
              if (upcomingEvents.isNotEmpty) ...[
                _buildEventSection(
                  title: 'المناسبات القادمة',
                  events: upcomingEvents.take(2).toList(),
                  color: Colors.blue,
                  icon: Icons.upcoming,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventSection({
    required String title,
    required List<IslamicEvent> events,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                title.text.lg.bold.color(color).make(),
              ],
            ),
            const SizedBox(height: 12),
            ...events.map((event) => _buildEventItem(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(IslamicEvent event) {
    return GestureDetector(
      onTap: () => Get.to(() => EventDetailView(event: event)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getEventTypeColor(event.type).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getEventTypeColor(event.type).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getEventTypeIcon(event.type),
              color: _getEventTypeColor(event.type),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  event.title.text.sm.bold.color(Colors.black87).make(),
                  event.date.text.xs.color(Colors.grey.shade600).make(),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  List<IslamicEvent> _getTodayEvents() {
    // مؤقتاً نرجع قائمة فارغة
    return [];
  }

  List<IslamicEvent> _getUpcomingEvents(IslamicEventsController controller) {
    try {
      final allEvents = controller.getAllEvents();
      return allEvents.take(2).toList();
    } catch (e) {
      return [];
    }
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.birth:
        return Colors.green;
      case EventType.martyrdom:
        return Colors.red;
      case EventType.event:
        return Colors.blue;
      case EventType.mourning:
        return Colors.orange;
      case EventType.celebration:
        return Colors.purple;
    }
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.birth:
        return Icons.child_care;
      case EventType.martyrdom:
        return Icons.favorite;
      case EventType.event:
        return Icons.event;
      case EventType.mourning:
        return Icons.sentiment_very_dissatisfied;
      case EventType.celebration:
        return Icons.celebration;
    }
  }
}
