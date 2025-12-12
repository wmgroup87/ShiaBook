class Dua {
  final String id;
  final String title;
  final String arabicText;
  final String? translation;
  final String? source;
  final String? benefits;
  final List<String>? tags;
  final DateTime? dateAdded;
  final int readCount;

  Dua({
    required this.id,
    required this.title,
    required this.arabicText,
    this.translation,
    this.source,
    this.benefits,
    this.tags,
    this.dateAdded,
    this.readCount = 0,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as String,
      title: json['title'] as String,
      arabicText: json['arabicText'] as String,
      translation: json['translation'] as String?,
      source: json['source'] as String?,
      benefits: json['benefits'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      dateAdded: json['dateAdded'] != null ? DateTime.parse(json['dateAdded']) : null,
      readCount: json['readCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'arabicText': arabicText,
      'translation': translation,
      'source': source,
      'benefits': benefits,
      'tags': tags,
      'dateAdded': dateAdded?.toIso8601String(),
      'readCount': readCount,
    };
  }

  Dua copyWith({
    String? id,
    String? title,
    String? arabicText,
    String? translation,
    String? source,
    String? benefits,
    List<String>? tags,
    DateTime? dateAdded,
    int? readCount,
  }) {
    return Dua(
      id: id ?? this.id,
      title: title ?? this.title,
      arabicText: arabicText ?? this.arabicText,
      translation: translation ?? this.translation,
      source: source ?? this.source,
      benefits: benefits ?? this.benefits,
      tags: tags ?? this.tags,
      dateAdded: dateAdded ?? this.dateAdded,
      readCount: readCount ?? this.readCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dua && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DuaCategory {
  final String id;
  final String title;
  final String icon;
  final List<Dua> duas;

  DuaCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.duas,
  });

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      duas: (json['duas'] as List)
          .map((duaJson) => Dua.fromJson(duaJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'duas': duas.map((dua) => dua.toJson()).toList(),
    };
  }
}

class DuasData {
  final List<DuaCategory> categories;

  DuasData({required this.categories});

  factory DuasData.fromJson(Map<String, dynamic> json) {
    return DuasData(
      categories: (json['categories'] as List)
          .map((categoryJson) => DuaCategory.fromJson(categoryJson))
          .toList(),
    );
  }
}
