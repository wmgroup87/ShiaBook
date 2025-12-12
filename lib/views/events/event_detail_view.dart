import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/islamic_events_controller.dart';
import 'package:shia_book/models/islamic_event.dart';
import 'package:velocity_x/velocity_x.dart';

class EventDetailView extends StatelessWidget {
  final IslamicEvent event;
  final IslamicEventsController controller =
      Get.find<IslamicEventsController>();
  final RxBool isAddedToCalendar = false.obs;

  EventDetailView({super.key, required this.event}) {
    isAddedToCalendar.value = event.calendarEventId != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: event.title.text.lg.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
              icon: const Icon(Icons.share), onPressed: () => _shareEvent()),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyEventDetails(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Action Button
            Obx(() => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isAddedToCalendar.value) {
                        final success = await controller
                            .removeEventFromDeviceCalendar(event);
                        if (success) {
                          isAddedToCalendar.value = false;
                          Get.snackbar(
                            'تمت الإزالة',
                            'تمت إزالة الحدث من التقويم',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        }
                      } else {
                        final success =
                            await controller.addEventToDeviceCalendar(event);
                        if (success) {
                          isAddedToCalendar.value = true;
                          Get.snackbar(
                            'تمت الإضافة',
                            'تمت إضافة الحدث إلى التقويم',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
                    icon: Icon(
                      isAddedToCalendar.value
                          ? Icons.event_busy
                          : Icons.event_available,
                      color: Colors.white,
                    ),
                    label: Text(
                      isAddedToCalendar.value
                          ? 'إزالة من التقويم'
                          : 'إضافة إلى التقويم',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAddedToCalendar.value
                          ? Colors.red
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )),

            // Event Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getEventTypeColor(event.type).withOpacity(0.1),
                      _getEventTypeColor(event.type).withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getEventTypeColor(event.type).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getEventTypeIcon(event.type),
                        size: 40,
                        color: _getEventTypeColor(event.type),
                      ),
                    ),
                    const SizedBox(height: 16),
                    event.title.text.xl2.bold
                        .color(Colors.black87)
                        .center
                        .make(),
                    const SizedBox(height: 8),
                    event.description.text.lg
                        .color(Colors.grey.shade700)
                        .center
                        .make(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoChip(
                          icon: Icons.calendar_today,
                          label: event.date,
                          color: AppColors.primary,
                        ),
                        _buildInfoChip(
                          icon: _getEventTypeIcon(event.type),
                          label: _getEventTypeText(event.type),
                          color: _getEventTypeColor(event.type),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Event Details
            if (event.details != null) ...[
              _buildSectionCard(
                title: 'تفاصيل المناسبة',
                icon: Icons.info_outline,
                child: event.details!.text.lg.color(Colors.black87).make(),
              ),
              const SizedBox(height: 16),
            ],

            // Traditions
            if (event.traditions != null && event.traditions!.isNotEmpty) ...[
              _buildSectionCard(
                title: 'الأعمال المستحبة',
                icon: Icons.star_outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: event.traditions!.map((tradition) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: tradition.text.color(Colors.black87).make(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Related Verses or Hadiths (if applicable)
            _buildSectionCard(
              title: 'آيات وأحاديث ذات صلة',
              icon: Icons.menu_book,
              child: Column(
                children: [
                  _buildQuoteCard(
                    text: _getRelatedVerse(event.type),
                    source: 'القرآن الكريم',
                    isVerse: true,
                  ),
                  const SizedBox(height: 12),
                  _buildQuoteCard(
                    text: _getRelatedHadith(event.type),
                    source: 'الحديث الشريف',
                    isVerse: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Prayer/Dua Section
            _buildSectionCard(
              title: 'دعاء المناسبة',
              icon: Icons.favorite_outline,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _getEventPrayer(
                      event.type,
                    ).text.xl.color(Colors.black87).center.make(),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _copyText(_getEventPrayer(event.type)),
                      icon: const Icon(Icons.copy, size: 18),
                      label: 'نسخ الدعاء'.text.make(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareEvent(),
                    icon: const Icon(Icons.share),
                    label: 'مشاركة'.text.make(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addToCalendar(),
                    icon: const Icon(Icons.calendar_month),
                    label: 'إضافة للتقويم'.text.make(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).box.color(Vx.gray50).make(),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          label.text.sm.color(color).bold.make(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                title.text.lg.bold.color(AppColors.primary).make(),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard({
    required String text,
    required String source,
    required bool isVerse,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerse
            ? Colors.blue.withOpacity(0.05)
            : Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerse
              ? Colors.blue.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text.text.lg.color(Colors.black87).make(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              source.text.sm.color(Colors.grey.shade600).italic.make(),
              IconButton(
                onPressed: () => _copyText(text),
                icon: const Icon(Icons.copy, size: 18),
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ],
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

  String _getRelatedVerse(EventType type) {
    switch (type) {
      case EventType.birth:
        return 'وَبَشِّرِ الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ أَنَّ لَهُمْ جَنَّاتٍ تَجْرِي مِن تَحْتِهَا الْأَنْهَارُ';
      case EventType.martyrdom:
        return 'وَلَا تَحْسَبَنَّ الَّذِينَ قُتِلُوا فِي سَبِيلِ اللَّهِ أَمْوَاتًا ۚ بَلْ أَحْيَاءٌ عِندَ رَبِّهِمْ يُرْزَقُونَ';
      case EventType.celebration:
        return 'قُلْ بِفَضْلِ اللَّهِ وَبِرَحْمَتِهِ فَبِذَٰلِكَ فَلْيَفْرَحُوا هُوَ خَيْرٌ مِّمَّا يَجْمَعُونَ';
      default:
        return 'وَذَكِّرْ فَإِنَّ الذِّكْرَىٰ تَنفَعُ الْمُؤْمِنِينَ';
    }
  }

  String _getRelatedHadith(EventType type) {
    switch (type) {
      case EventType.birth:
        return 'قال رسول الله (ص): إن الله جميل يحب الجمال، كريم يحب الكرم، نظيف يحب النظافة';
      case EventType.martyrdom:
        return 'قال الإمام الحسين (ع): إني لا أرى الموت إلا سعادة والحياة مع الظالمين إلا برما';
      case EventType.celebration:
        return 'قال الإمام علي (ع): اشكروا من أنعم عليكم وأنعموا على من شكركم';
      default:
        return 'قال رسول الله (ص): أنا مدينة العلم وعلي بابها، فمن اراد المدينة فاليأتها من بابها';
    }
  }

  String _getEventPrayer(EventType type) {
    switch (type) {
      case EventType.birth:
        return 'اللهم صل على محمد وآل محمد وبارك لنا في هذه المناسبة المباركة';
      case EventType.martyrdom:
        return 'السلام عليك يا أبا عبد الله وعلى الأرواح التي حلت بفنائك';
      case EventType.celebration:
        return 'الحمد لله رب العالمين والصلاة والسلام على محمد وآله الطاهرين';
      default:
        return 'اللهم اجعلنا من المتمسكين بولاية أهل البيت عليهم السلام';
    }
  }

  void _shareEvent() {
    final shareText = '''
${event.title}
${event.description}

التاريخ: ${event.date}
النوع: ${_getEventTypeText(event.type)}

${event.details ?? ''}

من تطبيق الكتب الشيعية
''';

    // نسخ النص إلى الحافظة بدلاً من المشاركة مؤقتاً
    _copyText(shareText);
    Get.snackbar(
      'تم النسخ',
      'تم نسخ تفاصيل المناسبة للمشاركة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  void _copyEventDetails() {
    final copyText = '''
${event.title}
${event.description}
التاريخ: ${event.date}
${event.details ?? ''}
''';
    _copyText(copyText);
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ النص إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _addToCalendar() {
    Get.snackbar(
      'قريباً',
      'سيتم إضافة ميزة التقويم قريباً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }
}
