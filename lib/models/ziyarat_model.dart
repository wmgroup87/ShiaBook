class Ziyarat {
  final String id;
  final String title;
  final String arabicText;
  final String? transliteration;
  final String? translation;
  final String? source;
  final String? benefits;
  final String? occasion;

  Ziyarat({
    required this.id,
    required this.title,
    required this.arabicText,
    this.transliteration,
    this.translation,
    this.source,
    this.benefits,
    this.occasion,
  });

  factory Ziyarat.fromJson(Map<String, dynamic> json) {
    return Ziyarat(
      id: json['id'],
      title: json['title'],
      arabicText: json['arabicText'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      source: json['source'],
      benefits: json['benefits'],
      occasion: json['occasion'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'arabicText': arabicText,
        if (transliteration != null) 'transliteration': transliteration,
        if (translation != null) 'translation': translation,
        if (source != null) 'source': source,
        if (benefits != null) 'benefits': benefits,
        if (occasion != null) 'occasion': occasion,
      };

  Ziyarat copyWith({
    String? id,
    String? title,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? source,
    String? benefits,
    String? occasion,
  }) {
    return Ziyarat(
      id: id ?? this.id,
      title: title ?? this.title,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      source: source ?? this.source,
      benefits: benefits ?? this.benefits,
      occasion: occasion ?? this.occasion,
    );
  }
}

class ZiyaratCategory {
  final String title;
  final String icon;
  final String description;
  final List<Ziyarat> ziyarat;

  ZiyaratCategory({
    required this.title,
    required this.icon,
    required this.description,
    required this.ziyarat,
  });

  factory ZiyaratCategory.fromJson(Map<String, dynamic> json) {
    return ZiyaratCategory(
      title: json['title'],
      icon: json['icon'],
      description: json['description'],
      ziyarat: (json['ziyarat'] as List)
          .map((item) => Ziyarat.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'icon': icon,
        'description': description,
        'ziyarat': ziyarat.map((item) => item.toJson()).toList(),
      };

  ZiyaratCategory copyWith({
    String? title,
    String? icon,
    String? description,
    List<Ziyarat>? ziyarat,
  }) {
    return ZiyaratCategory(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      ziyarat: ziyarat ?? this.ziyarat,
    );
  }
}
