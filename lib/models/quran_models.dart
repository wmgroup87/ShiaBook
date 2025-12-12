class QuranData {
  final Quran quran;

  QuranData({required this.quran});

  factory QuranData.fromJson(Map<String, dynamic> json) {
    return QuranData(
      quran: Quran.fromJson(json['quran']),
    );
  }
}

class Quran {
  final QuranMetadata metadata;
  final List<Surah> surahs;
  final List<QuranPage> pages;

  Quran({
    required this.metadata,
    required this.surahs,
    required this.pages,
  });

  factory Quran.fromJson(Map<String, dynamic> json) {
    return Quran(
      metadata: QuranMetadata.fromJson(json['metadata']),
      surahs: List<Surah>.from(
          json['surahs'].map((x) => Surah.fromJson(x))),
      pages: List<QuranPage>.from(
          json['pages'].map((x) => QuranPage.fromJson(x))),
    );
  }
}

class QuranMetadata {
  final int totalSurahs;
  final int totalPages;
  final int totalJuz;
  final String version;
  final String source;

  QuranMetadata({
    required this.totalSurahs,
    required this.totalPages,
    required this.totalJuz,
    required this.version,
    required this.source,
  });

  factory QuranMetadata.fromJson(Map<String, dynamic> json) {
    return QuranMetadata(
      totalSurahs: json['totalSurahs'],
      totalPages: json['totalPages'],
      totalJuz: json['totalJuz'],
      version: json['version'],
      source: json['source'],
    );
  }
}

class Surah {
  final int number;
  final String name;
  final String arabicName;
  final int numberOfVerses;
  final String revelationType;
  final bool isMakki;
  final List<Verse> verses;

  Surah({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.numberOfVerses,
    required this.revelationType,
    required this.isMakki,
    required this.verses,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      arabicName: json['arabicName'],
      numberOfVerses: json['numberOfVerses'],
      revelationType: json['revelationType'],
      isMakki: json['isMakki'],
      verses: List<Verse>.from(json['verses'].map((x) => Verse.fromJson(x))),
    );
  }
}

class Verse {
  final int number;
  final String text;
  final int juzNumber;
  final int pageNumber;
  final int surahNumber;

  Verse({
    required this.number,
    required this.text,
    required this.juzNumber,
    required this.pageNumber,
    required this.surahNumber,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: json['number'],
      text: json['text'],
      juzNumber: json['juzNumber'],
      pageNumber: json['pageNumber'],
      surahNumber: json['surahNumber'] ?? 0, // Default to 0 if not provided
    );
  }
}

class QuranPage {
  final int pageNumber;
  final int juzNumber;
  final List<PageVerse> verses;

  QuranPage({
    required this.pageNumber,
    required this.juzNumber,
    required this.verses,
  });

  factory QuranPage.fromJson(Map<String, dynamic> json) {
    return QuranPage(
      pageNumber: json['pageNumber'],
      juzNumber: json['juzNumber'],
      verses: List<PageVerse>.from(
          json['verses'].map((x) => PageVerse.fromJson(x))),
    );
  }
}

class PageVerse {
  final int surahNumber;
  final int verseNumber;
  final String text;

  PageVerse({
    required this.surahNumber,
    required this.verseNumber,
    required this.text,
  });

  factory PageVerse.fromJson(Map<String, dynamic> json) {
    return PageVerse(
      surahNumber: json['surahNumber'],
      verseNumber: json['verseNumber'],
      text: json['text'],
    );
  }
}
