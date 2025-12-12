import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/islamic_events_controller.dart';
import 'package:shia_book/models/islamic_event.dart';
import 'package:shia_book/views/events/event_detail_view.dart';
import 'package:velocity_x/velocity_x.dart';

class EventsSearchView extends GetView<IslamicEventsController> {
  const EventsSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final RxList<IslamicEvent> searchResults = <IslamicEvent>[].obs;
    final RxString searchQuery = ''.obs;

    return Scaffold(
      appBar: AppBar(
        title: 'البحث في المناسبات'.text.lg.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث في المناسبات...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Obx(
                  () => searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                            searchResults.clear();
                          },
                        )
                      : const SizedBox(),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                searchQuery.value = value;
                if (value.isNotEmpty) {
                  searchResults.assignAll(controller.searchEvents(value));
                } else {
                  searchResults.clear();
                }
              },
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: EventType.values.map((type) {
                return Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: _getEventTypeText(type).text.sm.make(),
                    onSelected: (selected) {
                      if (selected) {
                        searchResults.assignAll(
                          controller.getEventsByType(type),
                        );
                        searchQuery.value = _getEventTypeText(type);
                        searchController.text = _getEventTypeText(type);
                      }
                    },
                    backgroundColor: Colors.white,
                    selectedColor: _getEventTypeColor(type).withOpacity(0.2),
                    checkmarkColor: _getEventTypeColor(type),
                    side: BorderSide(color: _getEventTypeColor(type)),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Search Results
          Expanded(
            child: Obx(() {
              if (searchQuery.value.isEmpty) {
                return _buildInitialState();
              }

              if (searchResults.isEmpty) {
                return _buildNoResults();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final event = searchResults[index];
                  return _buildEventCard(event);
                },
              );
            }),
          ),
        ],
      ).box.color(Vx.gray50).make(),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          'ابحث في المناسبات الإسلامية'
              .text
              .xl
              .color(Colors.grey.shade600)
              .make(),
          const SizedBox(height: 8),
          'يمكنك البحث بالاسم أو النوع أو التفاصيل'
              .text
              .color(Colors.grey.shade500)
              .center
              .make(),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          'لم يتم العثور على نتائج'.text.xl.color(Colors.grey.shade600).make(),
          const SizedBox(height: 8),
          'جرب كلمات بحث أخرى'.text.color(Colors.grey.shade500).make(),
        ],
      ),
    );
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
