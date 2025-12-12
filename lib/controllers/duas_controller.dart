import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shia_book/models/dua_model.dart';

class DuasController extends GetxController {
  final RxList<DuaCategory> duaCategories = <DuaCategory>[].obs;
  final RxList<DuaCategory> filteredCategories = <DuaCategory>[].obs;
  final RxString searchQuery = ''.obs;
  final RxList<Dua> favoriteDuas = <Dua>[].obs;
  final RxDouble fontSize = 18.0.obs;
  final RxBool showTranslation = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDuasFromJson();
  }

  // تحميل الأدعية من ملف JSON
  Future<void> loadDuasFromJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/duas/duas.json');
      final Map<String, dynamic> data = json.decode(response);

      final List<DuaCategory> loadedCategories = [];

      // تحميل الفئات العادية
      if (data['categories'] != null) {
        for (var category in data['categories']) {
          loadedCategories.add(_parseCategory(category));
        }
      }

      // تحميل فئات الأشهر
      if (data['monthly_categories'] != null) {
        for (var category in data['monthly_categories']) {
          loadedCategories.add(_parseCategory(category));
        }
      }

      duaCategories.assignAll(loadedCategories);
      filteredCategories.assignAll(loadedCategories);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الأدعية',
        snackPosition: SnackPosition.BOTTOM,
      );
      log('Error loading duas: $e');
    }
  }

  // دالة مساعدة لتحليل الفئة
  DuaCategory _parseCategory(Map<String, dynamic> category) {
    final List<Dua> categoryDuas = [];

    for (var dua in category['duas']) {
      categoryDuas.add(Dua(
        id: dua['id'],
        title: dua['title'],
        arabicText: dua['arabicText'],
        translation: dua['translation'],
        source: dua['source'],
        benefits: dua['benefits'],
        tags: dua['tags'] != null ? List<String>.from(dua['tags']) : null,
      ));
    }

    return DuaCategory(
      id: category['id'],
      title: category['title'],
      icon: category['icon'],
      duas: categoryDuas,
    );
  }

  void searchDuas(String query) {
    if (query.isEmpty) {
      filteredCategories.value = duaCategories;
      return;
    }

    final results = <DuaCategory>[];

    for (final category in duaCategories) {
      final filteredDuas = category.duas.where((dua) {
        return dua.title.toLowerCase().contains(query.toLowerCase()) ||
            dua.arabicText.toLowerCase().contains(query.toLowerCase()) ||
            (dua.translation?.toLowerCase().contains(query.toLowerCase()) ??
                false);
      }).toList();

      if (filteredDuas.isNotEmpty) {
        results.add(
          DuaCategory(
            id: '${category.id}_filtered',
            title: category.title,
            icon: category.icon,
            duas: filteredDuas,
          ),
        );
      }
    }

    filteredCategories.value = results;
  }

  void toggleFavorite(Dua dua) {
    if (favoriteDuas.contains(dua)) {
      favoriteDuas.remove(dua);
    } else {
      favoriteDuas.add(dua);
    }
  }

  bool isFavorite(Dua dua) {
    return favoriteDuas.contains(dua);
  }

  void increaseFontSize() {
    if (fontSize.value < 24) fontSize.value += 2;
  }

  void decreaseFontSize() {
    if (fontSize.value > 14) fontSize.value -= 2;
  }

  // دالة مساعدة للحصول على الألوان الثابتة
  Color get primaryColor => const Color(0xFF2E7D32);
  Color get secondaryColor => const Color(0xFF81C784);
  Color get backgroundColor => const Color(0xFFF5F5F5);
  Color get textColor => const Color(0xFF212121);
  Color get accentColor => const Color(0xFF4CAF50);
  // All duas are now loaded from the JSON file

  // Get total number of categories
  int get totalCategories => duaCategories.length;

  // Get total number of favorite duas
  int get totalFavorites => favoriteDuas.length;

  // Get total number of all duas across all categories
  int get totalDuas {
    int count = 0;
    for (var category in duaCategories) {
      count += category.duas.length;
    }
    return count;
  }

  // Get total number of duas in a specific category
  int getDuasCountInCategory(String categoryId) {
    try {
      final category = duaCategories.firstWhere((cat) => cat.id == categoryId);
      return category.duas.length;
    } catch (e) {
      return 0;
    }
  }
}
