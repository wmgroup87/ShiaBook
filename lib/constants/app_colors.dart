import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  static const Color secondary = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF63A4FF);
  static const Color secondaryDark = Color(0xFF004BA0);

  static const Color accent = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFCC02);
  static const Color accentDark = Color(0xFFC66900);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);

  // Hadith Grade Colors
  static const Color gradeCorrect = Color(0xFF4CAF50);
  static const Color gradeGood = Color(0xFF2196F3);
  static const Color gradeWeak = Color(0xFFFF9800);
  static const Color gradeMutawatir = Color(0xFF9C27B0);
  static const Color gradeAuthentic = Color(0xFF009688);
  static const Color gradeMursal = Color(0xFFFFC107);

  // Category Colors
  static const Color categoryAqaid = Color(0xFF673AB7);
  static const Color categoryFiqh = Color(0xFF3F51B5);
  static const Color categoryAkhlaq = Color(0xFF009688);
  static const Color categoryTarikh = Color(0xFF795548);
  static const Color categoryDua = Color(0xFFE91E63);
  static const Color categoryZiyarat = Color(0xFF607D8B);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color danger = Color(0xFFF44336);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2E7D32),
    Color(0xFF4CAF50),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF1976D2),
    Color(0xFF2196F3),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFC107),
  ];

  // Get color for hadith grade
  static Color getGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'صحيح':
        return gradeCorrect;
      case 'حسن':
        return gradeGood;
      case 'ضعيف':
        return gradeWeak;
      case 'متواتر':
        return gradeMutawatir;
      case 'موثق':
        return gradeAuthentic;
      case 'مرسل':
        return gradeMursal;
      default:
        return Colors.grey;
    }
  }

  // Get color for book icon
  static Color getBookColor(String iconName) {
    switch (iconName) {
      case 'kafi':
        return const Color(0xFF4CAF50);
      case 'bihar':
        return const Color(0xFF2196F3);
      case 'faqih':
        return const Color(0xFFFF9800);
      case 'istibsar':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }
}
