import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quran_models.dart';

class QuranService {
  static Future<QuranData> loadQuranData() async {
    try {
      final String response = await rootBundle.loadString('assets/complete_quran_data.json');
      final data = await json.decode(response);
      
      // Ensure the data has the required structure
      if (data['quran'] == null) {
        throw Exception('Invalid Quran data format: missing quran object');
      }
      
      // Ensure surahs exist
      if (data['quran']['surahs'] == null) {
        throw Exception('Invalid Quran data format: missing surahs array');
      }
      
      // Initialize pages as empty if not present
      if (data['quran']['pages'] == null) {
        data['quran']['pages'] = [];
      }
      
      return QuranData.fromJson(data);
    } catch (e) {
      print('Error loading Quran data: $e');
      rethrow;
    }
  }

  // الحصول على سورة معينة برقمها
  static Future<Surah?> getSurah(int surahNumber) async {
    try {
      final quranData = await loadQuranData();
      return quranData.quran.surahs.firstWhere(
        (surah) => surah.number == surahNumber,
        orElse: () => throw Exception('Surah not found'),
      );
    } catch (e) {
      print('Error getting surah: $e');
      return null;
    }
  }

  // البحث عن آية في السور
  static Future<List<Verse>> searchVerses(String query) async {
    try {
      final quranData = await loadQuranData();
      final List<Verse> results = [];
      
      for (var surah in quranData.quran.surahs) {
        results.addAll(
          surah.verses.where(
            (verse) => verse.text.contains(query),
          ),
        );
      }
      
      return results;
    } catch (e) {
      print('Error searching verses: $e');
      return [];
    }
  }
}
