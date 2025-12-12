class IslamicEvent {
  final String title;
  final String description;
  final String date; // مثل "1 محرم 1445"
  final int day;
  final int month;
  final int? hijriYear; // السنة الهجرية
  final EventType type;
  final String? details;
  final List<String>? traditions;
  final String? calendarEventId; // معرف الحدث في تقويم الجهاز

  IslamicEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.day,
    required this.month,
    this.hijriYear,
    required this.type,
    this.details,
    this.traditions,
    this.calendarEventId,
  });

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      title: json['title'],
      description: json['description'],
      date: json['date'],
      day: json['day'],
      month: json['month'],
      hijriYear: json['hijriYear'],
      type: EventType.values.firstWhere(
        (e) => e.toString() == 'EventType.${json['type']}',
        orElse: () => EventType.event,
      ),
      details: json['details'],
      traditions: json['traditions'] != null
          ? List<String>.from(json['traditions'])
          : null,
      calendarEventId: json['calendarEventId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'day': day,
      'month': month,
      'hijriYear': hijriYear,
      'type': type.toString().split('.').last,
      'details': details,
      'traditions': traditions,
      'calendarEventId': calendarEventId,
    };
  }
}

enum EventType {
  birth, // ولادة
  martyrdom, // شهادة
  event, // حدث مهم
  mourning, // عزاء
  celebration, // احتفال
}

class HijriMonth {
  final int number;
  final String name;
  final List<IslamicEvent> events;

  HijriMonth({required this.number, required this.name, required this.events});
}
