class ShiaEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final ShiaEventType type;
  final String? imam;
  final String? location;
  final bool isRecurring;
  final String? significance;
  final List<String>? recommendedActions;

  ShiaEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.imam,
    this.location,
    this.isRecurring = true,
    this.significance,
    this.recommendedActions,
  });

  factory ShiaEvent.fromJson(Map<String, dynamic> json) {
    return ShiaEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: ShiaEventType.values.firstWhere(
        (e) => e.toString() == 'ShiaEventType.${json['type']}',
      ),
      imam: json['imam'],
      location: json['location'],
      isRecurring: json['isRecurring'] ?? true,
      significance: json['significance'],
      recommendedActions: json['recommendedActions']?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'imam': imam,
      'location': location,
      'isRecurring': isRecurring,
      'significance': significance,
      'recommendedActions': recommendedActions,
    };
  }

  // نسخ الحدث مع تعديل التاريخ للسنة الحالية
  ShiaEvent copyWithCurrentYear() {
    final currentYear = DateTime.now().year;
    final newDate = DateTime(currentYear, date.month, date.day);

    return ShiaEvent(
      id: id,
      title: title,
      description: description,
      date: newDate,
      type: type,
      imam: imam,
      location: location,
      isRecurring: isRecurring,
      significance: significance,
      recommendedActions: recommendedActions,
    );
  }

  // التحقق من كون الحدث اليوم
  bool get isToday {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month;
  }

  // التحقق من كون الحدث قريباً (خلال أسبوع)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference >= 0 && difference <= 7;
  }
}

enum ShiaEventType {
  birth, // ولادة
  martyrdom, // شهادة
  mourning, // عزاء
  celebration, // احتفال
  ziyarat, // زيارة
  religious, // ديني
  historical, // تاريخي
}

extension ShiaEventTypeExtension on ShiaEventType {
  String get displayName {
    switch (this) {
      case ShiaEventType.birth:
        return 'ولادة';
      case ShiaEventType.martyrdom:
        return 'شهادة';
      case ShiaEventType.mourning:
        return 'عزاء';
      case ShiaEventType.celebration:
        return 'احتفال';
      case ShiaEventType.ziyarat:
        return 'زيارة';
      case ShiaEventType.religious:
        return 'ديني';
      case ShiaEventType.historical:
        return 'تاريخي';
    }
  }

  String get icon {
    switch (this) {
      case ShiaEventType.birth:
        return '🎂';
      case ShiaEventType.martyrdom:
        return '⚔️';
      case ShiaEventType.mourning:
        return '🖤';
      case ShiaEventType.celebration:
        return '🎉';
      case ShiaEventType.ziyarat:
        return '🕌';
      case ShiaEventType.religious:
        return '☪️';
      case ShiaEventType.historical:
        return '📜';
    }
  }
}
