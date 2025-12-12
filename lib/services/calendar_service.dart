import 'package:calendar_events/calendar_events.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shia_book/models/islamic_event.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  final CalendarEvents _calendarEvents = CalendarEvents();

  factory CalendarService() {
    return _instance;
  }

  CalendarService._internal();

  // تحويل التاريخ الهجري إلى ميلادي
  DateTime _hijriToGregorian(int year, int month, int day) {
    try {
      final hijriDate = HijriCalendar()
        ..hYear = year
        ..hMonth = month
        ..hDay = day;
      // استخدام الطريقة الصحيحة للتحويل
      return hijriDate.hijriToGregorian(year, month, day);
    } catch (e) {
      print('Error converting Hijri to Gregorian: $e');
      return DateTime.now();
    }
  }

  // إضافة حدث إلى تقويم الجهاز
  Future<String?> addEventToCalendar(IslamicEvent event) async {
    try {
      // طلب الإذن
      final permission = await _calendarEvents.requestPermission();

      // الحصول على التقاويم المتاحة
      final calendars = await _calendarEvents.getCalendarAccounts();
      if (calendars == null || calendars.isEmpty) {
        print('No calendars available');
        return null;
      }

      final defaultCalendar = calendars.first;

      // تحويل التاريخ
      final eventDate = _hijriToGregorian(
        event.hijriYear ?? HijriCalendar().hYear,
        event.month,
        event.day,
      );

      // إنشاء الحدث
      final calendarEvent = CalendarEvent(
        calendarId: defaultCalendar.calenderId,
        title: event.title,
        description: event.description,
        location: 'Islamic Calendar',
        start: eventDate,
        end: eventDate.add(const Duration(hours: 1)),
        allDay: 1,
      );

      final eventId = await _calendarEvents.addEvent(calendarEvent);
      return eventId;
    } catch (e) {
      print('Error adding event: $e');
      return null;
    }
  }

  // تحديث حدث موجود
  Future<bool> updateCalendarEvent(IslamicEvent event) async {
    if (event.calendarEventId == null) return false;

    try {
      final permission = await _calendarEvents.requestPermission();

      final calendars = await _calendarEvents.getCalendarAccounts();
      if (calendars == null || calendars.isEmpty) return false;

      final defaultCalendar = calendars.first;
      final eventDate = _hijriToGregorian(
        event.hijriYear ?? HijriCalendar().hYear,
        event.month,
        event.day,
      );

      final updatedEvent = CalendarEvent(
        eventId: event.calendarEventId,
        calendarId: defaultCalendar.calenderId,
        title: event.title,
        description: event.description,
        location: 'Islamic Calendar',
        start: eventDate,
        end: eventDate.add(const Duration(hours: 1)),
        allDay: 1,
      );

      final result = await _calendarEvents.updateEvent(updatedEvent);
      return result != null;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  // حذف حدث
  Future<bool> deleteCalendarEvent(IslamicEvent event) async {
    if (event.calendarEventId == null) return false;

    try {
      final permission = await _calendarEvents.requestPermission();

      final calendars = await _calendarEvents.getCalendarAccounts();
      if (calendars == null || calendars.isEmpty) return false;

      final defaultCalendar = calendars.first;

      final eventToDelete = CalendarEvent(
        eventId: event.calendarEventId,
        calendarId: defaultCalendar.calenderId,
        title: event.title,
        description: '',
        location: '',
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(hours: 1)),
      );

      final result = await _calendarEvents.deleteEvent(eventToDelete);
      return result != null;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  // التحقق من الإذن
  Future<bool> hasCalendarPermission() async {
    try {
      final permission = await _calendarEvents.requestPermission();
      return permission != null;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  // طلب الإذن
  Future<bool> requestCalendarPermission() async {
    try {
      final permission = await _calendarEvents.requestPermission();
      return permission != null;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }
}
