class QuranAudio {
  final int surahNumber;
  final int ayahNumber;
  final String reciterName;
  final String localPath;
  final DateTime downloadDate;
  final int fileSize;
  final bool isShiaReciter; // إضافة حقل جديد
  final String audioFormat; // surah أو ayah
  bool isDownloaded;

  QuranAudio({
    required this.surahNumber,
    required this.ayahNumber,
    required this.reciterName,
    required this.localPath,
    required this.downloadDate,
    required this.fileSize,
    this.isDownloaded = false,
    this.isShiaReciter = false,
    this.audioFormat = 'ayah',
  });

  Map<String, dynamic> toMap() {
    return {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'reciter_name': reciterName,
      'local_path': localPath,
      'download_date': downloadDate.toIso8601String(),
      'file_size': fileSize,
      'is_downloaded': isDownloaded ? 1 : 0,
      'is_shia_reciter': isShiaReciter ? 1 : 0,
      'audio_format': audioFormat,
    };
  }

  factory QuranAudio.fromMap(Map<String, dynamic> map) {
    return QuranAudio(
      surahNumber: map['surah_number'],
      ayahNumber: map['ayah_number'],
      reciterName: map['reciter_name'],
      localPath: map['local_path'],
      downloadDate: DateTime.parse(map['download_date']),
      fileSize: map['file_size'],
      isDownloaded: map['is_downloaded'] == 1,
      isShiaReciter: map['is_shia_reciter'] == 1,
      audioFormat: map['audio_format'] ?? 'ayah',
    );
  }

  // تحديد ما إذا كان القارئ شيعياً
  bool get isShia {
    final shiaReciters = [
      'كريم منصوري',
      'ميثم التمار',
      'باسم الكربلائي',
      'أحمد الوائلي',
    ];
    return shiaReciters.contains(reciterName);
  }

  // الحصول على نوع القراءة
  String get readingType => isShia ? 'شيعي' : 'سني';
}
