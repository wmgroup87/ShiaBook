import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/islamic_events_controller.dart';
import 'package:shia_book/models/islamic_event.dart';
import 'package:shia_book/views/events/event_detail_view.dart';
import 'package:shia_book/views/events/events_search_view.dart';
import 'package:velocity_x/velocity_x.dart';

class IslamicEventsView extends GetView<IslamicEventsController> {
  const IslamicEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'المناسبات الإسلامية'.text.xl2.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Get.to(() => const EventsSearchView());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.event_note,
                    size: 40, color: AppColors.primary),
                const SizedBox(height: 12),
                'التقويم الهجري'
                    .text
                    .xl
                    .bold
                    .color(Colors.black87)
                    .center
                    .make(),
                const SizedBox(height: 8),
                'المناسبات الدينية المهمة عند الشيعة الإمامية'
                    .text
                    .sm
                    .color(Colors.grey.shade600)
                    .center
                    .make(),
              ],
            ),
          ),

          // Month Selector
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthNumber = index + 1;
                return Obx(() {
                  final isSelected =
                      controller.selectedMonth.value == monthNumber;
                  return GestureDetector(
                    onTap: () => controller.selectMonth(monthNumber),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: controller
                            .getMonthName(monthNumber)
                            .text
                            .color(isSelected ? Colors.white : Colors.black87)
                            .bold
                            .make(),
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Calendar Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Month Name
                  Obx(
                    () => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: controller
                          .getMonthName(controller.selectedMonth.value)
                          .text
                          .xl2
                          .bold
                          .color(AppColors.primary)
                          .center
                          .make(),
                    ),
                  ),

                  // Calendar Days
                  _buildCalendarGrid(),

                  const SizedBox(height: 20),

                  // Events List for Selected Month
                  _buildEventsForMonth(),
                ],
              ),
            ),
          ),
        ],
      ).box.color(Vx.gray50).make(),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Days of week header
          Row(
            children: ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س']
                .map(
                  (day) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: day.text.sm.bold
                          .color(Colors.grey.shade600)
                          .center
                          .make(),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid (30 days)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final day = index + 1;

              return Obx(() {
                final hasEvent = controller.getEventForDay(
                      controller.selectedMonth.value,
                      day,
                    ) !=
                    null;
                final isSelected = controller.selectedDay.value == day;

                return GestureDetector(
                  onTap: () => controller.selectDay(day),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : hasEvent
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: hasEvent
                          ? Border.all(
                              color: AppColors.primary.withOpacity(0.5),
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: day
                              .toString()
                              .text
                              .color(
                                isSelected
                                    ? Colors.white
                                    : hasEvent
                                        ? AppColors.primary
                                        : Colors.black87,
                              )
                              .bold
                              .make(),
                        ),
                        if (hasEvent && !isSelected)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsForMonth() {
    return Obx(() {
      final events = controller.getEventsForMonth(
        controller.selectedMonth.value,
      );

      if (events.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              'لا توجد مناسبات مهمة في هذا الشهر'
                  .text
                  .color(Colors.grey.shade600)
                  .center
                  .make(),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          'مناسبات الشهر'.text.lg.bold.color(AppColors.primary).make(),
          const SizedBox(height: 12),
          ...events.map((event) => _buildEventCard(event)),
        ],
      );
    });
  }

  Widget _buildEventCard(IslamicEvent event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.to(() => EventDetailView(event: event));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Event Type Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getEventTypeColor(event.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getEventTypeIcon(event.type),
                  color: _getEventTypeColor(event.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Event Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    event.title.text.lg.bold.color(Colors.black87).make(),
                    const SizedBox(height: 4),
                    event.description.text.sm
                        .color(Colors.grey.shade600)
                        .make(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        event.date.text.xs.color(Colors.grey.shade500).make(),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventTypeColor(
                              event.type,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getEventTypeColor(event.type),
                            ),
                          ),
                          child: _getEventTypeText(event.type)
                              .text
                              .xs
                              .color(_getEventTypeColor(event.type))
                              .make(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
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

  String _getEventTypeText(EventType type) {
    switch (type) {
      case EventType.birth:
        return 'ولادة';
      case EventType.martyrdom:
        return 'شهادة';
      case EventType.event:
        return 'حدث';
      case EventType.mourning:
        return 'عزاء';
      case EventType.celebration:
        return 'احتفال';
    }
  }
}
