class HolyPlace {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String icon;
  final String details;
  final List<Map<String, dynamic>> reviews; // قائمة التقييمات
  final double averageRating; // متوسط التقييم

  HolyPlace({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.icon,
    required this.details,
    this.reviews = const [],
    this.averageRating = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'icon': icon,
      'details': details,
      'reviews': reviews,
      'averageRating': averageRating,
    };
  }

  factory HolyPlace.fromJson(Map<String, dynamic> json) {
    return HolyPlace(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      icon: json['icon'] ?? '',
      details: json['details'] ?? '',
      reviews: List<Map<String, dynamic>>.from(json['reviews'] ?? []),
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
    );
  }
}
