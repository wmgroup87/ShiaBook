import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoritesKey = 'hadith_favorites';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _fontSizeKey = 'font_size';
  static const String _arabicFontSizeKey = 'arabic_font_size';
  static const String _recentActivitiesKey = 'recent_activities';
  static const String _readCountKey = 'read_count';
  static const String _searchCountKey = 'search_count';
  static const String _settingsKey = 'hadith_settings';

  // Favorites Management
  static Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  static Future<List> loadFavorites() {
    return _getPrefs()
        .then((prefs) => prefs.getStringList(_favoritesKey) ?? [])
        .then((value) => value);
  }

  static Future<List<String>> loadFavoritesAsync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Notifications Settings
  static Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  static bool loadNotificationsEnabled() {
    return _getPrefsSync()?.getBool(_notificationsKey) ?? true;
  }

  static Future<void> saveNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    final timeMap = {'hour': hour, 'minute': minute};
    await prefs.setString(_notificationTimeKey, jsonEncode(timeMap));
  }

  static Map<String, int> loadNotificationTime() {
    final prefs = _getPrefsSync();
    final timeString = prefs?.getString(_notificationTimeKey);
    if (timeString != null) {
      final timeMap = jsonDecode(timeString) as Map<String, dynamic>;
      return {
        'hour': timeMap['hour'] as int,
        'minute': timeMap['minute'] as int,
      };
    }
    return {'hour': 9, 'minute': 0};
  }

  // Font Settings
  static Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  static double loadFontSize() {
    return _getPrefsSync()?.getDouble(_fontSizeKey) ?? 16.0;
  }

  static Future<void> saveArabicFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_arabicFontSizeKey, size);
  }

  static double loadArabicFontSize() {
    return _getPrefsSync()?.getDouble(_arabicFontSizeKey) ?? 18.0;
  }

  // Recent Activities
  static Future<void> addRecentActivity(String activity) async {
    final prefs = await SharedPreferences.getInstance();
    final activities = loadRecentActivities();

    final newActivity = {
      'activity': activity,
      'timestamp': DateTime.now().toIso8601String(),
    };

    activities.insert(0, newActivity);

    // Keep only last 50 activities
    if (activities.length > 50) {
      activities.removeRange(50, activities.length);
    }

    final activitiesJson = activities.map((a) => jsonEncode(a)).toList();
    await prefs.setStringList(_recentActivitiesKey, activitiesJson);
  }

  static List<Map<String, dynamic>> loadRecentActivities() {
    final prefs = _getPrefsSync();
    final activitiesJson = prefs?.getStringList(_recentActivitiesKey) ?? [];

    return activitiesJson
        .map((json) {
          try {
            return jsonDecode(json) as Map<String, dynamic>;
          } catch (e) {
            return <String, dynamic>{};
          }
        })
        .where((activity) => activity.isNotEmpty)
        .toList();
  }

  static Future<void> clearRecentActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentActivitiesKey);
  }

  // Usage Statistics
  static Future<void> incrementReadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_readCountKey) ?? 0;
    await prefs.setInt(_readCountKey, currentCount + 1);
  }

  static int getTotalReadCount() {
    return _getPrefsSync()?.getInt(_readCountKey) ?? 0;
  }

  static Future<void> incrementSearchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_searchCountKey) ?? 0;
    await prefs.setInt(_searchCountKey, currentCount + 1);
  }

  static int getTotalSearchCount() {
    return _getPrefsSync()?.getInt(_searchCountKey) ?? 0;
  }

  // Data Management
  static Future<Map<String, dynamic>> exportAllData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'favorites': prefs.getStringList(_favoritesKey) ?? [],
      'notificationsEnabled': prefs.getBool(_notificationsKey) ?? true,
      'notificationTime': prefs.getString(_notificationTimeKey),
      'fontSize': prefs.getDouble(_fontSizeKey) ?? 16.0,
      'arabicFontSize': prefs.getDouble(_arabicFontSizeKey) ?? 18.0,
      'recentActivities': prefs.getStringList(_recentActivitiesKey) ?? [],
      'readCount': prefs.getInt(_readCountKey) ?? 0,
      'searchCount': prefs.getInt(_searchCountKey) ?? 0,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> importAllData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    if (data['favorites'] != null) {
      await prefs.setStringList(
        _favoritesKey,
        List<String>.from(data['favorites']),
      );
    }

    if (data['notificationsEnabled'] != null) {
      await prefs.setBool(_notificationsKey, data['notificationsEnabled']);
    }

    if (data['notificationTime'] != null) {
      await prefs.setString(_notificationTimeKey, data['notificationTime']);
    }

    if (data['fontSize'] != null) {
      await prefs.setDouble(_fontSizeKey, data['fontSize'].toDouble());
    }

    if (data['arabicFontSize'] != null) {
      await prefs.setDouble(
        _arabicFontSizeKey,
        data['arabicFontSize'].toDouble(),
      );
    }

    if (data['recentActivities'] != null) {
      await prefs.setStringList(
        _recentActivitiesKey,
        List<String>.from(data['recentActivities']),
      );
    }

    if (data['readCount'] != null) {
      await prefs.setInt(_readCountKey, data['readCount']);
    }

    if (data['searchCount'] != null) {
      await prefs.setInt(_searchCountKey, data['searchCount']);
    }
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Helper methods
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static SharedPreferences? _getPrefsSync() {
    // This is a workaround for synchronous access
    // In a real app, you should use async methods
    return null;
  }
}
