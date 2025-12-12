import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/quran_audio.dart';

class QuranDownloadService {
  static final QuranDownloadService _instance = QuranDownloadService._internal();
  factory QuranDownloadService() => _instance;
  QuranDownloadService._internal();

  final Dio _dio = Dio();
  late Database _database;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize notifications
    await _initializeNotifications();

    // Initialize database
    await _initializeDatabase();

    _isInitialized = true;
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _notifications.initialize(initSettings);
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quran_audio.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE quran_audio (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            surah_number INTEGER,
            ayah_number INTEGER,
            reciter_name TEXT,
            local_path TEXT,
            download_date TEXT,
            file_size INTEGER,
            is_downloaded INTEGER
          )
        ''');
      },
    );
  }

  Future<String> _getDownloadPath() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final downloadPath = join(directory.path, 'quran_audio');
    
    final dir = Directory(downloadPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return downloadPath;
  }

  Future<QuranAudio?> getDownloadedAudio(int surah, int ayah, String reciter) async {
    final results = await _database.query(
      'quran_audio',
      where: 'surah_number = ? AND ayah_number = ? AND reciter_name = ? AND is_downloaded = 1',
      whereArgs: [surah, ayah, reciter],
    );

    if (results.isNotEmpty) {
      final audio = QuranAudio.fromMap(results.first);
      final file = File(audio.localPath);
      if (await file.exists()) {
        return audio;
      } else {
        // File doesn't exist, update database
        await _database.update(
          'quran_audio',
          {'is_downloaded': 0},
          where: 'surah_number = ? AND ayah_number = ? AND reciter_name = ?',
          whereArgs: [surah, ayah, reciter],
        );
      }
    }
    return null;
  }

  Future<void> downloadSurah(int surahNumber, String reciterName, List<String> ayahUrls) async {
    try {
      final downloadPath = await _getDownloadPath();
      
      // Show notification for download start
      await _showNotification(
        'تحميل السورة',
        'جاري تحميل سورة $surahNumber',
        progress: 0,
        maxProgress: ayahUrls.length,
      );

      int downloadedCount = 0;
      for (int i = 0; i < ayahUrls.length; i++) {
        final url = ayahUrls[i];
        final ayahNumber = i + 1;
        
        try {
          // Check if already downloaded
          final existing = await getDownloadedAudio(surahNumber, ayahNumber, reciterName);
          if (existing != null) {
            downloadedCount++;
            continue;
          }

          final fileName = '${surahNumber}_$ayahNumber.mp3';
          final filePath = join(downloadPath, fileName);

          final response = await _dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = (received / total * 100).toInt();
                print('تحميل الآية $ayahNumber: $progress%');
              }
            },
            options: Options(
              validateStatus: (status) {
                return status != null && status < 500;
              },
              followRedirects: true,
              maxRedirects: 5,
              receiveTimeout: const Duration(minutes: 2),
              sendTimeout: const Duration(minutes: 2),
            ),
          );

          if (response.statusCode == 200) {
            final file = File(filePath);
            final fileSize = await file.length();

            final audio = QuranAudio(
              surahNumber: surahNumber,
              ayahNumber: ayahNumber,
              reciterName: reciterName,
              localPath: filePath,
              downloadDate: DateTime.now(),
              fileSize: fileSize,
              isDownloaded: true,
            );

            await _database.insert('quran_audio', audio.toMap());
            downloadedCount++;

            // Update progress notification
            await _showNotification(
              'تحميل السورة',
              'جاري تحميل سورة $surahNumber',
              progress: downloadedCount,
              maxProgress: ayahUrls.length,
            );
          } else {
            print('خطأ في تحميل الآية $ayahNumber: رمز الحالة ${response.statusCode}');
            continue;
          }
        } catch (e) {
          print('خطأ في تحميل الآية $ayahNumber: $e');
          continue;
        }
      }

      // Show completion notification
      if (downloadedCount > 0) {
        await _showNotification(
          'اكتمل التحميل',
          'تم تحميل $downloadedCount آية من سورة $surahNumber بنجاح',
          progress: downloadedCount,
          maxProgress: ayahUrls.length,
        );
      } else {
        throw Exception('لم يتم تحميل أي آية');
      }
    } catch (e) {
      print('خطأ في تحميل السورة: $e');
      await _showNotification(
        'خطأ في التحميل',
        'حدث خطأ أثناء تحميل سورة $surahNumber: ${e.toString().replaceAll('Exception: ', '')}',
      );
      rethrow;
    }
  }

  Future<void> _showNotification(
    String title,
    String body, {
    int? progress,
    int? maxProgress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'quran_download',
      'Quran Download',
      channelDescription: 'Notifications for Quran audio downloads',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: progress != null,
      maxProgress: maxProgress ?? 100,
      progress: progress ?? 0,
      ongoing: progress != null && progress < (maxProgress ?? 100),
      autoCancel: progress == null || progress >= (maxProgress ?? 100),
    );

    final platformDetails = NotificationDetails(android: androidDetails);
    
    // Add progress numbers to the notification body if available
    final updatedBody = progress != null && maxProgress != null
        ? '$body ($progress من $maxProgress)'
        : body;
        
    await _notifications.show(0, title, updatedBody, platformDetails);
  }

  Future<void> deleteSurah(int surahNumber, String reciterName) async {
    try {
      final downloads = await _database.query(
        'quran_audio',
        where: 'surah_number = ? AND reciter_name = ? AND is_downloaded = 1',
        whereArgs: [surahNumber, reciterName],
      );

      for (final row in downloads) {
        final audio = QuranAudio.fromMap(row);
        final file = File(audio.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await _database.delete(
        'quran_audio',
        where: 'surah_number = ? AND reciter_name = ?',
        whereArgs: [surahNumber, reciterName],
      );
    } catch (e) {
      print('Error deleting surah: $e');
      rethrow;
    }
  }

  Future<List<QuranAudio>> getDownloadedSurahs() async {
    final results = await _database.query(
      'quran_audio',
      where: 'is_downloaded = 1',
      orderBy: 'surah_number ASC, ayah_number ASC',
    );

    return results.map((row) => QuranAudio.fromMap(row)).toList();
  }

  Future<bool> isSurahDownloaded(int surahNumber, String reciterName) async {
    final count = Sqflite.firstIntValue(await _database.rawQuery('''
      SELECT COUNT(*) FROM quran_audio 
      WHERE surah_number = ? AND reciter_name = ? AND is_downloaded = 1
    ''', [surahNumber, reciterName]));

    return (count ?? 0) > 0;
  }

  String getLocalUrl(QuranAudio audio) {
    return 'file://${audio.localPath}';
  }
} 