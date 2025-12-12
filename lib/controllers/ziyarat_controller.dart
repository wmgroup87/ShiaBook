import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shia_book/models/ziyarat_model.dart';

// A helper function to create and initialize the controller
Future<ZiyaratController> initZiyaratController() async {
  final prefs = await SharedPreferences.getInstance();
  return ZiyaratController._internal(prefs);
}

class ZiyaratController extends GetxController {
  final RxList<ZiyaratCategory> ziyaratCategories = <ZiyaratCategory>[].obs;
  final RxList<ZiyaratCategory> filteredCategories = <ZiyaratCategory>[].obs;
  final RxList<String> favoriteZiyaratIds = <String>[].obs;
  final RxList<Ziyarat> favoriteZiyarat = <Ziyarat>[].obs;
  final RxString searchQuery = ''.obs;
  final RxDouble fontSize = 18.0.obs;
  final RxBool showTranslation = true.obs;
  final RxBool showTransliteration = false.obs;
  final RxInt totalReadCount = 0.obs;

  final SharedPreferences prefs;

  // Private constructor
  ZiyaratController._internal(this.prefs) {
    _init();
  }

  // Factory constructor for dependency injection
  factory ZiyaratController(SharedPreferences prefs) =>
      ZiyaratController._internal(prefs);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() {
    _loadSettings();
    _loadFavorites();
    _loadZiyarat();
    _loadReadCount();
  }

  void _loadSettings() {
    fontSize.value = prefs.getDouble('ziyarat_font_size') ?? 18.0;
    showTranslation.value = prefs.getBool('show_translation') ?? true;
    showTransliteration.value = prefs.getBool('show_transliteration') ?? false;
  }

  void _loadFavorites() {
    final favorites = prefs.getStringList('favorite_ziyarat_ids') ?? [];
    favoriteZiyaratIds.value = List<String>.from(favorites);
    _updateFavoriteZiyarat();
  }

  void _loadReadCount() {
    totalReadCount.value = prefs.getInt('total_read_count') ?? 0;
  }

  void _saveSettings() {
    prefs.setDouble('ziyarat_font_size', fontSize.value);
    prefs.setBool('show_translation', showTranslation.value);
    prefs.setBool('show_transliteration', showTransliteration.value);
  }

  void _saveFavorites() {
    prefs.setStringList('favorite_ziyarat_ids', favoriteZiyaratIds.toList());
  }

  void _updateFavoriteZiyarat() {
    favoriteZiyarat.clear();
    for (var category in ziyaratCategories) {
      for (var ziyarat in category.ziyarat) {
        if (favoriteZiyaratIds.contains(ziyarat.id)) {
          favoriteZiyarat.add(ziyarat);
        }
      }
    }
  }

  Future<void> _loadZiyarat() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/ziyarat/ziyarat.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Convert JSON data to ZiyaratCategory objects
      final List<ZiyaratCategory> categories = (jsonData['categories'] as List)
          .map((categoryJson) => ZiyaratCategory.fromJson(categoryJson))
          .toList();

      ziyaratCategories.value = categories;
      filteredCategories.value = categories;
      _updateFavoriteZiyarat();
    } catch (e) {
      print('Error loading ziyarat data: $e');
      // Handle error (e.g., show error message to user)
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل بيانات الزيارات',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void increaseFontSize() {
    if (fontSize.value < 28) {
      fontSize.value += 2;
      _saveSettings();
      update();
    }
  }

  void decreaseFontSize() {
    if (fontSize.value > 12) {
      fontSize.value -= 2;
      _saveSettings();
      update();
    }
  }

  void toggleTranslation() {
    showTranslation.toggle();
    _saveSettings();
    update();
  }

  void toggleTransliteration() {
    showTransliteration.toggle();
    _saveSettings();
    update();
  }

  bool isFavorite(Ziyarat ziyarat) {
    return favoriteZiyaratIds.contains(ziyarat.id);
  }

  void toggleFavorite(Ziyarat ziyarat) {
    if (isFavorite(ziyarat)) {
      favoriteZiyaratIds.remove(ziyarat.id);
      favoriteZiyarat.remove(ziyarat);
      Get.snackbar(
        'تم الحذف',
        'تم حذف الزيارة من المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      favoriteZiyaratIds.add(ziyarat.id);
      favoriteZiyarat.add(ziyarat);
      Get.snackbar(
        'تم الإضافة',
        'تم إضافة الزيارة إلى المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
    _saveFavorites();
    update();
  }

  void searchZiyarat(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredCategories.value = ziyaratCategories;
    } else {
      filteredCategories.value = ziyaratCategories.where((category) {
        return category.title.toLowerCase().contains(query.toLowerCase()) ||
            category.description.toLowerCase().contains(query.toLowerCase()) ||
            category.ziyarat.any(
              (ziyarat) =>
                  ziyarat.title.toLowerCase().contains(query.toLowerCase()) ||
                  ziyarat.arabicText.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
            );
      }).toList();
    }
  }

  int getTotalZiyaratCount() {
    return ziyaratCategories.fold(
      0,
      (sum, category) => sum + category.ziyarat.length,
    );
  }

  void incrementReadCount() {
    totalReadCount.value++;
    prefs.setInt('total_read_count', totalReadCount.value);
  }

  List<Ziyarat> getFavoriteZiyarat() {
    List<Ziyarat> favorites = [];
    for (var category in ziyaratCategories) {
      for (var ziyarat in category.ziyarat) {
        if (favoriteZiyaratIds.contains(ziyarat.id)) {
          favorites.add(ziyarat);
        }
      }
    }
    return favorites;
  }

  void clearAllFavorites() {
    favoriteZiyaratIds.clear();
    favoriteZiyarat.clear();
    _saveFavorites();
    update();
    Get.snackbar(
      'تم المسح',
      'تم مسح جميع المفضلات',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void resetSettings() {
    fontSize.value = 18.0;
    showTranslation.value = true;
    showTransliteration.value = false;
    _saveSettings();
    update();
    Get.snackbar(
      'تم الإعادة',
      'تم إعادة تعيين الإعدادات',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _saveSettings();
    _saveFavorites();
    super.onClose();
  }
}
