import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shia_book/controllers/duas_controller.dart';
import 'package:shia_book/controllers/home_controller.dart';
import 'package:shia_book/controllers/islamic_events_controller.dart';
import 'package:shia_book/controllers/settings_controller.dart';
import 'package:shia_book/controllers/ziyarat_controller.dart';
import 'package:shia_book/controllers/quran_controller.dart';
import 'package:shia_book/controllers/holy_places_controller.dart';
import 'package:shia_book/services/adhan_service.dart';
import 'package:shia_book/services/permission_service.dart';
import 'package:shia_book/services/quran_download_service.dart';
import 'package:shia_book/views/duas/duas_view.dart';
import 'package:shia_book/views/events/islamic_events_view.dart';
import 'package:shia_book/views/home_view.dart';
import 'package:shia_book/views/map_view.dart';
import 'package:shia_book/views/quran_view.dart';
import 'package:shia_book/views/settings_view.dart';
import 'package:shia_book/views/ziyarat/ziyarat_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences first
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  // Initialize Quran library
  final quranLibrary = QuranLibrary();
  Get.put<QuranLibrary>(quranLibrary, permanent: true);

  // Initialize QuranDownloadService
  final downloadService = QuranDownloadService();
  await downloadService.initialize();
  Get.put<QuranDownloadService>(downloadService, permanent: true);

  // Initialize controllers
  await _initializeControllers();

  // طلب الأذونات أولاً
  await PermissionService.requestNotificationPermissions();

  // تهيئة خدمة الأذان
  await AdhanService.initialize();

  // جدولة الأذانات عند بدء التطبيق
  await AdhanService.scheduleAllAdhans();

  runApp(MyApp());
}

Future<void> _initializeControllers() async {
  // تهيئة AudioController أولاً

  // ثم QuranController
  Get.put(QuranController(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'الكتب الشيعية',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.cairo().fontFamily,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, height: 1.6),
          bodyMedium: TextStyle(fontSize: 14, height: 1.5),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeView(),
          binding: BindingsBuilder(() {
            Get.put(HomeController());
          }),
        ),
        GetPage(
          name: '/quran',
          page: () => QuranView(),
          binding: BindingsBuilder(() {
            Get.put(QuranController());
          }),
        ),
        GetPage(
          name: '/duas',
          page: () => const DuasView(),
          binding: BindingsBuilder(() {
            Get.put(DuasController());
          }),
        ),
        GetPage(
          name: '/ziyarat',
          page: () => const ZiyaratView(),
          binding: BindingsBuilder(() {
            final prefs = Get.find<SharedPreferences>();
            Get.put(ZiyaratController(prefs));
          }),
        ),
        GetPage(
          name: '/map',
          page: () => MapView(),
          binding: BindingsBuilder(() {
            Get.put(HolyPlacesController());
          }),
        ),
        GetPage(
          name: '/events',
          page: () => const IslamicEventsView(),
          binding: BindingsBuilder(() {
            Get.put(IslamicEventsController());
          }),
        ),
        GetPage(
          name: '/settings',
          page: () => SettingsView(),
          binding: BindingsBuilder(() {
            Get.put(SettingsController());
          }),
        ),
      ],
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      debugShowCheckedModeBanner: false,
    );
  }
}
