import 'package:shia_book/models/islamic_event.dart';

class HijriMonth {
  final int number;
  final String name;
  final List<IslamicEvent> events;

  HijriMonth({required this.number, required this.name, required this.events});

  factory HijriMonth.fromJson(Map<String, dynamic> json) {
    return HijriMonth(
      number: json['number'],
      name: json['name'],
      events: (json['events'] as List)
          .map((e) => IslamicEvent.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }
}
