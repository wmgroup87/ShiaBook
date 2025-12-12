import 'dart:convert';
import 'dart:io';

void generateQuranData() {
  // بيانات السور والأجزاء (مبسطة)
  final List<Map<String, dynamic>> quranData = [];

  // قائمة السور مع أرقام صفحاتها التقريبية
  final Map<int, Map<String, dynamic>> surahInfo = {
    1: {"name": "الفاتحة", "startPage": 1, "endPage": 1},
    2: {"name": "البقرة", "startPage": 2, "endPage": 49},
    3: {"name": "آل عمران", "startPage": 50, "endPage": 76},
    4: {"name": "النساء", "startPage": 77, "endPage": 106},
    5: {"name": "المائدة", "startPage": 106, "endPage": 127},
    6: {"name": "الأنعام", "startPage": 128, "endPage": 150},
    7: {"name": "الأعراف", "startPage": 151, "endPage": 176},
    8: {"name": "الأنفال", "startPage": 177, "endPage": 187},
    9: {"name": "التوبة", "startPage": 187, "endPage": 207},
    10: {"name": "يونس", "startPage": 208, "endPage": 221},
    11: {"name": "هود", "startPage": 221, "endPage": 235},
    12: {"name": "يوسف", "startPage": 235, "endPage": 248},
    13: {"name": "الرعد", "startPage": 249, "endPage": 255},
    14: {"name": "إبراهيم", "startPage": 255, "endPage": 261},
    15: {"name": "الحجر", "startPage": 262, "endPage": 267},
    16: {"name": "النحل", "startPage": 267, "endPage": 281},
    17: {"name": "الإسراء", "startPage": 282, "endPage": 293},
    18: {"name": "الكهف", "startPage": 293, "endPage": 304},
    19: {"name": "مريم", "startPage": 305, "endPage": 312},
    20: {"name": "طه", "startPage": 312, "endPage": 322},
    // ... يمكن إضافة باقي السور
  };

  for (int page = 1; page <= 604; page++) {
    int surahNumber = 1;
    String surahName = "الفاتحة";

    // تحديد السورة بناءً على رقم الصفحة
    for (var entry in surahInfo.entries) {
      if (page >= entry.value["startPage"] && page <= entry.value["endPage"]) {
        surahNumber = entry.key;
        surahName = entry.value["name"];
        break;
      }
    }

    // تحديد رقم الجزء (كل 20 صفحة تقريباً)
    int juzNumber = ((page - 1) ~/ 20) + 1;
    if (juzNumber > 30) juzNumber = 30;

    quranData.add({
      "pageNumber": page,
      "imageAsset": "assets/images/$page.png",
      "surahNumber": surahNumber,
      "surahName": surahName,
      "juzNumber": juzNumber,
    });
  }

  // كتابة البيانات إلى ملف JSON
  final jsonString = const JsonEncoder.withIndent('  ').convert(quranData);
  File('assets/quran_data.json').writeAsStringSync(jsonString);

  print('تم إنشاء ملف quran_data.json بنجاح!');
}
