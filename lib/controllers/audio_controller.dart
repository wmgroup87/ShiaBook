import 'dart:io';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shia_book/services/quran_download_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AudioController extends GetxController {
  final _audioPlayer = AudioPlayer();
  final _downloadService = Get.find<QuranDownloadService>();
  final _dio = Dio();

  // Observable variables
  final currentAyah = Rx<Map<String, dynamic>?>(null);
  final isPlaying = false.obs;
  final autoPlayNext = true.obs;
  final currentPosition = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final selectedReciter = 'المنشاوي'.obs;
  final downloadProgress = 0.0.obs;
  final isDownloading = false.obs;
  final currentlyPlayingAyah = Rx<Map<String, dynamic>?>(null);

  // Track the currently playing verse details
  final currentVerseKey = RxString('');
  final currentSurahNumber = 0.obs;
  final currentAyahNumber = 0.obs;
  final CacheManager _cacheManager = CacheManager(
    Config(
      'quran_audio_cache',
      maxNrOfCacheObjects: 100, // Keep last 100 audio files
      stalePeriod: const Duration(days: 30), // Keep files for 30 days
    ),
  );

  // Controller to notify when the current verse changes
  final ValueNotifier<Map<String, dynamic>?> currentAyahNotifier =
      ValueNotifier(null);

  final availableReciters = [
    'الحصري',
    'المنشاوي',
  ];

  @override
  void onInit() {
    super.onInit();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;

      if (state.processingState == ProcessingState.completed) {
        if (autoPlayNext.value) {
          next();
        } else {
          currentlyPlayingAyah.value = null;
          currentSurahNumber.value = 0;
          currentAyahNumber.value = 0;
          currentVerseKey.value = '';
          currentAyahNotifier.value = null;
        }
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((pos) {
      currentPosition.value = pos;
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((dur) {
      duration.value = dur ?? Duration.zero;
    });
  }

  Future<void> playAyah(Map<String, dynamic> ayahData) async {
    try {
      currentAyah.value = ayahData;
      currentlyPlayingAyah.value = ayahData;
      final surahNumber = ayahData['surah'];
      final ayahNumber = ayahData['ayah'];
      final surahName = ayahData['surahName'] ?? 'سورة';

      // Update current verse tracking
      currentSurahNumber.value = surahNumber;
      currentAyahNumber.value = ayahNumber;
      currentVerseKey.value = '$surahNumber:$ayahNumber';

      // Notify listeners about the current ayah change
      currentAyahNotifier.value = ayahData;

      final url = _getAyahUrl(surahNumber, ayahNumber);

      // Try to get from cache first
      try {
        final file = await _cacheManager.getSingleFile(url);
        if (await file.exists()) {
          print('Playing from cache: ${file.path}');
          await _audioPlayer.setFilePath(file.path);
        } else {
          // If not in cache, download and play
          print('Downloading and playing: $url');
          await _audioPlayer.setUrl(url);
          // Cache the file for future use in the background
          _cacheManager.getSingleFile(url).catchError((e) {
            print('Error caching file: $e');
            return Future<File>.value(File(''));
          });
        }
      } catch (e) {
        print('Error with cache, playing directly: $e');
        await _audioPlayer.setUrl(url);
      }

      // Set audio source with metadata
      final audioSource = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          title: '$surahName - آية $ayahNumber',
          artist: selectedReciter.value,
          artUri: Uri.parse('https://example.com/quran_cover.jpg'),
        ),
      );

      await _audioPlayer.setAudioSource(audioSource);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing ayah: $e');
      rethrow;
    }
  }

  String _getAyahUrl(int surahNumber, int ayahNumber) {
    final reciterCode = _getReciterCode(selectedReciter.value);

    // Calculate the absolute ayah number
    int absoluteAyahNumber = 0;
    for (int i = 1; i < surahNumber; i++) {
      absoluteAyahNumber += _getSurahAyahCount(i);
    }
    absoluteAyahNumber += ayahNumber;

    // Using Islamic Network CDN
    return 'https://cdn.islamic.network/quran/audio/128/$reciterCode/$absoluteAyahNumber.mp3';
  }

  String _getReciterCode(String reciterName) {
    // Map reciter names to Islamic Network CDN codes
    final reciterCodes = {
      'محمود خليل الحصري': 'ar.husary',
      'محمد صديق المنشاوي': 'ar.minshawi',
    };
    return reciterCodes[reciterName] ?? 'ar.minshawi';
  }

  Future<void> downloadSurah(int surahNumber) async {
    try {
      isDownloading.value = true;
      downloadProgress.value = 0;

      final totalAyahs = _getSurahAyahCount(surahNumber);
      final ayahUrls = List.generate(
        totalAyahs,
        (index) => _getAyahUrl(surahNumber, index + 1),
      );

      int successCount = 0;
      List<String> downloadedUrls = [];

      // Configure Dio to accept any status code
      final options = Options(
        validateStatus: (status) => true,
        followRedirects: true,
        maxRedirects: 5,
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
      );

      // Test first ayah to validate URL pattern
      final testResponse = await _dio.head(ayahUrls[0], options: options);
      if (testResponse.statusCode != 200) {
        throw Exception(
            'تعذر الوصول إلى ملفات الصوت. الرجاء التحقق من توفر القارئ المحدد واتصال الإنترنت.');
      }

      // Download each ayah and track progress
      for (int i = 0; i < ayahUrls.length; i++) {
        try {
          final response = await _dio.head(ayahUrls[i], options: options);
          if (response.statusCode == 200) {
            downloadedUrls.add(ayahUrls[i]);
            successCount++;
          } else {
            print(
                'خطأ في تحميل الآية ${i + 1}: رمز الحالة ${response.statusCode}');
            if (response.statusCode == 404) {
              throw Exception(
                  'الملف غير موجود. الرجاء التحقق من توفر القارئ المحدد لهذه السورة.');
            }
          }
        } catch (e) {
          print('خطأ في التحقق من الآية ${i + 1}: $e');
          continue;
        }

        // Update progress
        downloadProgress.value = successCount / totalAyahs;
        update();
      }

      if (successCount > 0) {
        // Start actual download of verified URLs
        await _downloadService.downloadSurah(
          surahNumber,
          selectedReciter.value,
          downloadedUrls,
        );

        Get.snackbar(
          'تم التحميل',
          'تم تحميل $successCount آية من السورة',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        throw Exception(
            'لم يتم العثور على ملفات صوتية لهذه السورة. الرجاء المحاولة مع قارئ آخر.');
      }
    } catch (e) {
      print('خطأ في تحميل السورة: $e');
      Get.snackbar(
        'خطأ',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0;
      update();
    }
  }

  int _getSurahAyahCount(int surahNumber) {
    // Add surah ayah counts
    final ayahCounts = [
      7,
      286,
      200,
      176,
      120,
      165,
      206,
      75,
      129,
      109,
      123,
      111,
      43,
      52,
      99,
      128,
      111,
      110,
      98,
      135,
      112,
      78,
      118,
      64,
      77,
      227,
      93,
      88,
      69,
      60,
      34,
      30,
      73,
      54,
      45,
      83,
      182,
      88,
      75,
      85,
      54,
      53,
      89,
      59,
      37,
      35,
      38,
      29,
      18,
      45,
      60,
      49,
      62,
      55,
      78,
      96,
      29,
      22,
      24,
      13,
      14,
      11,
      11,
      18,
      12,
      12,
      30,
      52,
      52,
      44,
      28,
      28,
      20,
      56,
      40,
      31,
      50,
      40,
      46,
      42,
      29,
      19,
      36,
      25,
      22,
      17,
      19,
      26,
      30,
      20,
      15,
      21,
      11,
      8,
      8,
      19,
      5,
      8,
      8,
      11,
      11,
      8,
      3,
      9,
      5,
      4,
      7,
      3,
      6,
      3,
      5,
      4,
      5,
      6
    ];
    return ayahCounts[surahNumber - 1];
  }

  Future<void> deleteSurah(int surahNumber) async {
    try {
      await _downloadService.deleteSurah(surahNumber, selectedReciter.value);
      Get.snackbar(
        'تم الحذف',
        'تم حذف السورة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error deleting surah: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف السورة',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void stop() {
    _audioPlayer.stop();
    currentAyah.value = null;
    currentlyPlayingAyah.value = null;
  }

  bool isAyahPlaying(int surahNumber, int ayahNumber) {
    if (currentlyPlayingAyah.value == null) return false;
    return currentlyPlayingAyah.value!['surah'] == surahNumber &&
        currentlyPlayingAyah.value!['ayah'] == ayahNumber;
  }

  void next() {
    if (currentAyah.value != null) {
      final nextAyah = currentAyah.value!['ayah'] + 1;
      if (nextAyah <= _getSurahAyahCount(currentAyah.value!['surah'])) {
        playAyah({
          ...currentAyah.value!,
          'ayah': nextAyah,
        });
      } else {
        // Move to next surah if available
        final nextSurah = (currentAyah.value!['surah'] as int) + 1;
        if (nextSurah <= 114) {
          // There are 114 surahs in the Quran
          playAyah({
            'surah': nextSurah,
            'ayah': 1,
            'surahName': 'السورة التالية', // This will be updated in playAyah
            'text': '',
          });
        } else {
          // Reached the end of the Quran
          stop();
        }
      }
    }
  }

  void previous() {
    if (currentAyah.value != null && currentAyah.value!['ayah'] > 1) {
      playAyah({
        ...currentAyah.value!,
        'ayah': currentAyah.value!['ayah'] - 1,
      });
    }
  }

  void changeReciter(String reciter) {
    selectedReciter.value = reciter;
    if (currentAyah.value != null) {
      // Replay current ayah with new reciter
      playAyah(currentAyah.value!);
    }
  }

  void toggleAutoPlay() {
    autoPlayNext.value = !autoPlayNext.value;
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    _cacheManager.emptyCache();
    super.onClose();
  }
}
