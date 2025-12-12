import 'package:get/get.dart';
import 'package:shia_book/models/islamic_event.dart';
import 'package:shia_book/services/calendar_service.dart';

class IslamicEventsController extends GetxController {
  final CalendarService _calendarService = CalendarService();
  final RxList<HijriMonth> hijriMonths = <HijriMonth>[].obs;
  final RxInt selectedMonth = 1.obs;
  final RxInt selectedDay = 0.obs;
  final Rx<IslamicEvent?> selectedEvent = Rx<IslamicEvent?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadIslamicEvents();
  }

  void _loadIslamicEvents() {
    hijriMonths.assignAll([
      // محرم
      HijriMonth(
        number: 1,
        name: 'محرم',
        events: [
          IslamicEvent(
            title: 'بداية شهر الاحزان',
            description: 'بداية احزان ال محمد  ',
            date: '1 محرم',
            day: 1,
            month: 1,
            type: EventType.event,
            details:
                'بداية شهر الاحزان والمصاب والفجيعة فيه تنشر الملائكة رايات السواد والحداد',
            traditions: ['اقامة المجالس والعزاء', 'اعلان الحداد', 'لبس السواد'],
          ),
          IslamicEvent(
            title: 'وصول الإمام الحسين عليه السلام الى كربلاء',
            description: 'وصول الركب الحسيني   ',
            date: '2 محرم',
            day: 2,
            month: 1,
            type: EventType.event,
            details: 'وصول الإمام الحسين عليه السلام الى كربلاء ونصب الخيام',
            traditions: ['الدعاء والتوبة', 'لبس السواد ', 'الحزن'],
          ),
          IslamicEvent(
            title: 'شهادة الإمام الحسين (ع)',
            description: 'يوم عاشوراء - شهادة سيد الشهداء',
            date: '10 محرم',
            day: 10,
            month: 1,
            type: EventType.martyrdom,
            details: 'استشهاد الإمام الحسين (ع) وأصحابه في كربلاء المقدسة',
            traditions: [
              'إقامة مجالس العزاء',
              'قراءة زيارة عاشوراء',
              'البكاء والنواح'
            ],
          ),
          IslamicEvent(
            title: 'شهادة الإمام الحسين (ع)',
            description: 'يوم عاشوراء - شهادة سيد الشهداء',
            date: '11 محرم',
            day: 11,
            month: 1,
            type: EventType.martyrdom,
            details: 'استشهاد الإمام الحسين (ع) وأصحابه في كربلاء المقدسة',
            traditions: [
              'إقامة مجالس العزاء',
              'قراءة زيارة عاشوراء',
              'البكاء والنواح'
            ],
          ),
        ],
      ),

      // صفر
      HijriMonth(
        number: 2,
        name: 'صفر',
        events: [
          IslamicEvent(
            title: 'الأربعين الحسيني',
            description: 'ذكرى أربعين الإمام الحسين (ع)',
            date: '20 صفر',
            day: 20,
            month: 2,
            type: EventType.mourning,
            details: 'إحياء ذكرى أربعين استشهاد الإمام الحسين (ع)',
            traditions: [
              'زيارة كربلاء',
              'المشي إلى كربلاء',
              'إقامة المجالس',
              'الإطعام'
            ],
          ),
        ],
      ),

      // ربيع الأول
      HijriMonth(
        number: 3,
        name: 'ربيع الأول',
        events: [
          IslamicEvent(
            title: 'ولادة النبي محمد (ص)',
            description: 'مولد خاتم الأنبياء والمرسلين',
            date: '17 ربيع الأول',
            day: 17,
            month: 3,
            type: EventType.birth,
            details: 'ولادة الرسول الأعظم محمد (ص) في مكة المكرمة',
            traditions: [
              'الاحتفال والفرح',
              'قراءة السيرة النبوية',
              'الصلاة على النبي',
              'الإطعام'
            ],
          ),
          IslamicEvent(
            title: 'ولادة الإمام الصادق (ع)',
            description: 'مولد الإمام السادس',
            date: '17 ربيع الأول',
            day: 17,
            month: 3,
            type: EventType.birth,
            details: 'ولادة الإمام جعفر الصادق (ع) في المدينة المنورة',
            traditions: [
              'الاحتفال والفرح',
              'قراءة مناقب الإمام',
              'الدعاء والتوسل'
            ],
          ),
        ],
      ),

      // ربيع الثاني
      HijriMonth(
        number: 4,
        name: 'ربيع الثاني',
        events: [],
      ),

      // جمادى الأولى
      HijriMonth(
        number: 5,
        name: 'جمادى الأولى',
        events: [
          IslamicEvent(
            title: 'ولادة السيدة فاطمة الزهراء (ع)',
            description: 'مولد سيدة نساء العالمين',
            date: '20 جمادى الثانية',
            day: 20,
            month: 6,
            type: EventType.birth,
            details: 'ولادة السيدة فاطمة الزهراء (ع) بنت رسول الله',
            traditions: [
              'الاحتفال الكبير',
              'قراءة مناقب الزهراء',
              'الدعاء والتوسل',
              'إكرام النساء'
            ],
          ),
        ],
      ),

      // جمادى الثانية
      HijriMonth(
        number: 6,
        name: 'جمادى الثانية',
        events: [
          IslamicEvent(
            title: 'ولادة السيدة فاطمة الزهراء (ع)',
            description: 'مولد سيدة نساء العالمين',
            date: '20 جمادى الثانية',
            day: 20,
            month: 6,
            type: EventType.birth,
            details: 'ولادة السيدة فاطمة الزهراء (ع) بنت رسول الله',
            traditions: [
              'الاحتفال الكبير',
              'قراءة مناقب الزهراء',
              'الدعاء والتوسل',
              'إكرام النساء'
            ],
          ),
        ],
      ),

      // رجب
      HijriMonth(
        number: 7,
        name: 'رجب',
        events: [
          IslamicEvent(
            title: 'ولادة الإمام الباقر (ع)',
            description: 'مولد الإمام الخامس',
            date: '1 رجب',
            day: 1,
            month: 7,
            type: EventType.birth,
            details: 'ولادة الإمام محمد الباقر (ع) في المدينة المنورة',
            traditions: [
              'الاحتفال والفرح',
              'قراءة مناقب الإمام',
              'الدعاء والتوسل'
            ],
          ),
          IslamicEvent(
            title: 'ولادة الإمام الجواد (ع)',
            description: 'مولد الإمام التاسع',
            date: '10 رجب',
            day: 10,
            month: 7,
            type: EventType.birth,
            details: 'ولادة الإمام محمد الجواد (ع) في المدينة المنورة',
            traditions: [
              'الاحتفال والفرح',
              'قراءة مناقب الإمام',
              'الدعاء والتوسل'
            ],
          ),
          IslamicEvent(
            title: 'المبعث النبوي الشريف',
            description: 'بعثة النبي محمد (ص)',
            date: '27 رجب',
            day: 27,
            month: 7,
            type: EventType.celebration,
            details: 'يوم بعثة الرسول الأعظم (ص) برسالة الإسلام',
            traditions: [
              'الاحتفال الكبير',
              'قراءة القرآن',
              'الصلاة على النبي',
              'الدعاء والشكر'
            ],
          ),
        ],
      ),

      // شعبان
      HijriMonth(
        number: 8,
        name: 'شعبان',
        events: [
          IslamicEvent(
            title: 'ولادة الإمام الحسين (ع)',
            description: 'مولد سيد الشهداء',
            date: '3 شعبان',
            day: 3,
            month: 8,
            type: EventType.birth,
            details: 'ولادة الإمام الحسين (ع) في المدينة المنورة',
            traditions: [
              'الاحتفال والفرح',
              'قراءة مناقب الإمام',
              'الدعاء والتوسل'
            ],
          ),
          IslamicEvent(
            title: 'ولادة العباس بن علي (ع)',
            description: 'مولد قمر بني هاشم',
            date: '4 شعبان',
            day: 4,
            month: 8,
            type: EventType.birth,
            details: 'ولادة العباس بن علي (ع) أخو الإمام الحسين',
            traditions: [
              'الاحتفال والفرح',
              'قراءة مناقب العباس',
              'الدعاء والتوسل'
            ],
          ),
          IslamicEvent(
            title: 'ولادة الإمام المهدي (عج)',
            description: 'مولد إمام العصر والزمان',
            date: '15 شعبان',
            day: 15,
            month: 8,
            type: EventType.birth,
            details: 'ولادة الإمام المهدي المنتظر (عج) في سامراء',
            traditions: [
              'الاحتفال الكبير',
              'الدعاء للفرج',
              'قراءة دعاء الندبة',
              'الصدقة'
            ],
          ),
        ],
      ),

      // رمضان
      HijriMonth(
        number: 9,
        name: 'رمضان',
        events: [
          IslamicEvent(
            title: 'ليلة القدر',
            description: 'ليلة نزول القرآن الكريم',
            date: '23 رمضان',
            day: 23,
            month: 9,
            type: EventType.celebration,
            details: 'ليلة القدر المباركة التي نزل فيها القرآن الكريم',
            traditions: [
              'إحياء الليلة بالعبادة',
              'قراءة القرآن',
              'الدعاء والاستغفار',
              'الصدقة'
            ],
          ),
          IslamicEvent(
            title: 'شهادة الإمام علي (ع)',
            description: 'استشهاد أمير المؤمنين',
            date: '21 رمضان',
            day: 21,
            month: 9,
            type: EventType.martyrdom,
            details: 'استشهاد الإمام علي (ع) في مسجد الكوفة',
            traditions: [
              'إقامة مجالس العزاء',
              'قراءة مناقب الإمام',
              'البكاء والنواح'
            ],
          ),
        ],
      ),

      // شوال
      HijriMonth(
        number: 10,
        name: 'شوال',
        events: [
          IslamicEvent(
            title: 'عيد الفطر المبارك',
            description: 'عيد انتهاء شهر رمضان',
            date: '1 شوال',
            day: 1,
            month: 10,
            type: EventType.celebration,
            details: 'عيد الفطر السعيد بعد انتهاء شهر رمضان المبارك',
            traditions: [
              'صلاة العيد',
              'التكبير والتهليل',
              'زيارة الأقارب',
              'الفرح والسرور'
            ],
          ),
        ],
      ),

      // ذو القعدة
      HijriMonth(
        number: 11,
        name: 'ذو القعدة',
        events: [
          IslamicEvent(
            title: 'ولادة الإمام الرضا (ع)',
            description: 'مولد الإمام الثامن',
            date: '11 ذو القعدة',
            day: 11,
            month: 11,
            type: EventType.birth,
            details: 'ولادة الإمام علي بن موسى الرضا (ع) في المدينة المنورة',
            traditions: [
              'الاحتفال والفرح',
              'زيارة مشهد المقدسة',
              'قراءة مناقب الإمام'
            ],
          ),
        ],
      ),

      // ذو الحجة
      HijriMonth(
        number: 12,
        name: 'ذو الحجة',
        events: [
          IslamicEvent(
            title: 'عيد الأضحى المبارك',
            description: 'عيد الحج الأكبر',
            date: '10 ذو الحجة',
            day: 10,
            month: 12,
            type: EventType.celebration,
            details: 'عيد الأضحى المبارك وذكرى تضحية إبراهيم الخليل (ع)',
            traditions: [
              'صلاة العيد',
              'الأضحية',
              'التكبير والتهليل',
              'زيارة الأقارب'
            ],
          ),
          IslamicEvent(
            title: 'عيد الغدير',
            description: 'يوم إعلان ولاية الإمام علي (ع)',
            date: '18 ذو الحجة',
            day: 18,
            month: 12,
            type: EventType.celebration,
            details: 'يوم غدير خم حيث أعلن الرسول (ص) ولاية الإمام علي (ع)',
            traditions: [
              'الاحتفال الكبير',
              'قراءة خطبة الغدير',
              'التهاني والمباركات',
              'الصدقة والإطعام'
            ],
          ),
          IslamicEvent(
            title: 'المباهلة',
            description: 'يوم مباهلة النبي (ص) مع نصارى نجران',
            date: '24 ذو الحجة',
            day: 24,
            month: 12,
            type: EventType.event,
            details: 'يوم المباهلة التي دعا فيها النبي (ص) أهل بيته للمباهلة',
            traditions: [
              'قراءة آية المباهلة',
              'الدعاء والتوسل بأهل البيت',
              'الصلاة على النبي وآله'
            ],
          ),
        ],
      ),
    ]);
  }

  // إضافة حدث إلى تقويم الجهاز
  Future<bool> addEventToDeviceCalendar(IslamicEvent event) async {
    try {
      // التحقق من الأذونات
      final hasPermission = await _calendarService.requestCalendarPermission();
      if (!hasPermission) return false;

      // إضافة الحدث إلى التقويم
      final eventId = await _calendarService.addEventToCalendar(event);
      if (eventId == null) return false;

      // تحديث معرف الحدث في القائمة
      final updatedEvent = IslamicEvent(
        title: event.title,
        description: event.description,
        date: event.date,
        day: event.day,
        month: event.month,
        hijriYear: event.hijriYear,
        type: event.type,
        details: event.details,
        traditions: event.traditions,
        calendarEventId: eventId,
      );

      // تحديث الحدث في القائمة
      _updateEventInList(updatedEvent);
      return true;
    } catch (e) {
      print('خطأ في إضافة الحدث إلى التقويم: $e');
      return false;
    }
  }

  // حذف حدث من تقويم الجهاز
  Future<bool> removeEventFromDeviceCalendar(IslamicEvent event) async {
    try {
      if (event.calendarEventId == null) return false;

      final success = await _calendarService.deleteCalendarEvent(event);
      if (!success) return false;

      // تحديث الحدث في القائمة
      final updatedEvent = IslamicEvent(
        title: event.title,
        description: event.description,
        date: event.date,
        day: event.day,
        month: event.month,
        hijriYear: event.hijriYear,
        type: event.type,
        details: event.details,
        traditions: event.traditions,
        calendarEventId: null,
      );

      _updateEventInList(updatedEvent);
      return true;
    } catch (e) {
      print('خطأ في حذف الحدث من التقويم: $e');
      return false;
    }
  }

  // تحديث حدث في القائمة
  void _updateEventInList(IslamicEvent updatedEvent) {
    final monthIndex =
        hijriMonths.indexWhere((m) => m.number == updatedEvent.month);
    if (monthIndex == -1) return;

    final eventIndex = hijriMonths[monthIndex].events.indexWhere(
        (e) => e.day == updatedEvent.day && e.month == updatedEvent.month);

    if (eventIndex != -1) {
      final updatedEvents =
          List<IslamicEvent>.from(hijriMonths[monthIndex].events);
      updatedEvents[eventIndex] = updatedEvent;

      final updatedMonth = HijriMonth(
        number: hijriMonths[monthIndex].number,
        name: hijriMonths[monthIndex].name,
        events: updatedEvents,
      );

      final updatedMonths = List<HijriMonth>.from(hijriMonths);
      updatedMonths[monthIndex] = updatedMonth;

      hijriMonths.value = updatedMonths;
    }
  }

  void selectMonth(int month) {
    selectedMonth.value = month;
  }

  void selectDay(int day) {
    selectedDay.value = day;
    selectedEvent.value = getEventForDay(selectedMonth.value, day);
  }

  String getMonthName(int monthNumber) {
    final month = hijriMonths.firstWhereOrNull((m) => m.number == monthNumber);
    return month?.name ?? '';
  }

  List<IslamicEvent> getEventsForMonth(int monthNumber) {
    final month = hijriMonths.firstWhereOrNull((m) => m.number == monthNumber);
    return month?.events ?? [];
  }

  IslamicEvent? getEventForDay(int monthNumber, int day) {
    final events = getEventsForMonth(monthNumber);
    return events.firstWhereOrNull((event) => event.day == day);
  }

  List<IslamicEvent> getAllEvents() {
    List<IslamicEvent> allEvents = [];
    for (var month in hijriMonths) {
      allEvents.addAll(month.events);
    }
    return allEvents;
  }

  List<IslamicEvent> getEventsByType(EventType type) {
    return getAllEvents().where((event) => event.type == type).toList();
  }

  List<IslamicEvent> searchEvents(String query) {
    if (query.isEmpty) return getAllEvents();

    return getAllEvents().where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase()) ||
          event.description.toLowerCase().contains(query.toLowerCase()) ||
          (event.details?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
}
