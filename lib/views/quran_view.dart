import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_library/quran_library.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/quran_controller.dart';
import 'package:shia_book/views/quran_download_view.dart';
import 'package:shia_book/widgets/audio_player_widget.dart';
import 'package:velocity_x/velocity_x.dart';

class QuranView extends GetView<QuranController> {
  const QuranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value || controller.quranData.isEmpty) {
        return _buildLoadingScreen();
      }

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Stack(
          children: [
            // شاشة القرآن الأساسية
            _buildPageView(),

            // الشريط العلوي
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: controller.isUIVisible.value ? 0 : -130,
              left: 0,
              right: 0,
              child: _buildFloatingAppBar(),
            ),

            // الشريط السفلي مع مشغل الصوت
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: controller.isUIVisible.value ? 0 : -200,
              left: 0,
              right: 0,
              child: _buildFloatingBottomBarWithAudio(),
            ),

            // الأزرار العائمة
            if (controller.isUIVisible.value)
              Positioned(
                bottom: 180, // زيادة المسافة لتجنب التداخل مع مشغل الصوت
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: controller.isUIVisible.value ? 1.0 : 0.0,
                  child: _buildFloatingButtons(),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  'جاري تحميل القرآن الكريم...'
                      .text
                      .lg
                      .color(AppColors.primary)
                      .make(),
                  const SizedBox(height: 8),
                  'يرجى الانتظار...'.text.sm.color(Colors.grey.shade600).make(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingAppBar() {
    return Container(
      padding: EdgeInsets.only(top: 50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // زر الرجوع
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
                onPressed: () async {
                  await controller.saveCurrentPage();
                  Get.back();
                },
              ),
            ),

            const SizedBox(width: 12),

            // معلومات السورة
            Expanded(
              child: Obx(() => Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.menu_book,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.getCurrentSurahName(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'صفحة ${controller.currentPage.value} • جزء ${controller.getCurrentJuzNumber()}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),

            const SizedBox(width: 12),

            // زر الفهرس
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                onPressed: () => _showIndexDrawer(),
                tooltip: 'فهرس السور والأجزاء',
              ),
            ),

            const SizedBox(width: 8),

            // زر التحميل
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.white, size: 20),
                onPressed: () => Get.to(() => const QuranDownloadView()),
                tooltip: 'تحميل السور',
              ),
            ),

            const SizedBox(width: 8),

            // زر الإعدادات
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.more_vert, color: Colors.white, size: 20),
                onPressed: () => _showQuranSettings(),
                tooltip: 'إعدادات القراءة',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBarWithAudio() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مشغل الصوت
            const AudioPlayerWidget(),

            // أزرار التنقل
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(top: 15, bottom: 5),
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // معلومات الصفحة الحالية
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.9),
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${controller.currentPage.value}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    final controller = Get.find<QuranController>();
    return GestureDetector(
      onTap: controller.toggleUI,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: QuranLibraryScreen(
          useDefaultAppBar: false,
          onPageChanged: (pageIndex) {
            controller.onPageChanged(pageIndex);
          },
          // Handle ayah tap to play audio
          onAyahLongPress: (details, ayah) {
            // Show audio controls when ayah is long pressed
            final surahNumber = ayah.surahNumber ?? 1;
            String surahName = ayah.arabicName ?? 'الفاتحة';

            if (surahName.isEmpty || surahName == 'الفاتحة') {
              try {
                final surah = controller.quranData.firstWhere(
                  (surah) => surah['number'] == surahNumber,
                  orElse: () => {'name': 'الفاتحة'},
                );
                surahName = surah['name'] ?? 'الفاتحة';
              } catch (e) {
                print('Error getting surah name: $e');
              }
            }

            final ayahData = {
              'surah': surahNumber,
              'ayah': ayah.ayahNumber,
              'surahName': surahName,
              'text': ayah.text,
            };
            controller.audioController.playAyah(ayahData);
          },
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "index",
          backgroundColor: AppColors.primary,
          onPressed: () => _showIndexDrawer(),
          tooltip: 'فهرس السور',
          child: const Icon(Icons.list, color: Colors.white),
        ),
      ],
    );
  }

  void _showIndexDrawer() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModernIndexSheet(),
    );
  }

  Widget _buildModernIndexSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        'فهرس القرآن الكريم'.text.xl.bold.white.make(),
                        const SizedBox(height: 4),
                        '604 صفحة • 114 سورة • 30 جزء'.text.sm.white.make(),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),

            // Enhanced Tabs
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.primary,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.list_alt, size: 20),
                                SizedBox(width: 8),
                                Text('السور'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark, size: 20),
                                SizedBox(width: 8),
                                Text('الأجزاء'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildEnhancedSurahList(scrollController),
                          _buildEnhancedJuzList(scrollController),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSurahList(ScrollController scrollController) {
    final surahList = controller.getUniqueSurahs();

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: surahList.length,
      itemBuilder: (context, index) {
        final surah = surahList[index];
        final isCurrentSurah =
            controller.getCurrentSurahNumber() == surah['surahNumber'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: isCurrentSurah ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: isCurrentSurah
                    ? LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: isCurrentSurah
                    ? Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      )
                    : null,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCurrentSurah
                          ? [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ]
                          : [Colors.grey.shade600, Colors.grey.shade500],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isCurrentSurah ? AppColors.primary : Colors.grey)
                                .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${surah['surahNumber']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  surah['surahName'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isCurrentSurah ? AppColors.primary : Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah['englishName'] ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'الصفحة ${surah['firstPageIndex']}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${surah['ayahCount']} آية',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: surah['revelationType'] == 'Meccan'
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            surah['revelationType'] == 'Meccan'
                                ? 'مكية'
                                : 'مدنية',
                            style: TextStyle(
                              fontSize: 10,
                              color: surah['revelationType'] == 'Meccan'
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isCurrentSurah
                            ? AppColors.primary
                            : Colors.grey.shade400)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCurrentSurah
                        ? Icons.play_circle_filled
                        : Icons.arrow_forward_ios,
                    color: isCurrentSurah
                        ? AppColors.primary
                        : Colors.grey.shade600,
                    size: isCurrentSurah ? 24 : 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.goToSurah(surah['surahNumber']);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedJuzList(ScrollController scrollController) {
    final juzList = controller.getUniqueJuz();

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: juzList.length,
      itemBuilder: (context, index) {
        final juz = juzList[index];
        final isCurrentJuz =
            controller.getCurrentJuzNumber() == juz['juzNumber'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: isCurrentJuz ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: isCurrentJuz
                    ? LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.1),
                          Colors.amber.withOpacity(0.05),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: isCurrentJuz
                    ? Border.all(color: Colors.amber.withOpacity(0.3), width: 2)
                    : null,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCurrentJuz
                          ? [Colors.amber.shade600, Colors.amber.shade500]
                          : [Colors.teal.shade600, Colors.teal.shade500],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: (isCurrentJuz ? Colors.amber : Colors.teal)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${juz['juzNumber']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'الجزء ${juz['juzNumber']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color:
                        isCurrentJuz ? Colors.amber.shade700 : Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'يبدأ بسورة ${juz['surahName']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الصفحة ${juz['firstPageIndex']}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isCurrentJuz ? Colors.amber : Colors.teal)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCurrentJuz
                        ? Icons.play_circle_filled
                        : Icons.arrow_forward_ios,
                    color: isCurrentJuz
                        ? Colors.amber.shade700
                        : Colors.teal.shade600,
                    size: isCurrentJuz ? 24 : 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.goToJuz(juz['juzNumber']);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQuranSettings() {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.settings, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                'إعدادات القراءة'.text.xl.bold.make(),
              ],
            ),
            const SizedBox(height: 24),

            // إعدادات سريعة
            _buildQuickSettingTile(
              icon: Icons.bookmark_add,
              title: 'إضافة علامة مرجعية',
              subtitle: 'حفظ الصفحة الحالية',
              onTap: () {
                Navigator.pop(context);
                controller.addBookmark();
              },
            ),

            _buildQuickSettingTile(
              icon: Icons.share,
              title: 'مشاركة الآية',
              subtitle: 'مشاركة الصفحة الحالية',
              onTap: () {
                Navigator.pop(context);
                controller.shareCurrentPage();
              },
            ),

            _buildQuickSettingTile(
              icon: Icons.copy,
              title: 'نسخ النص',
              subtitle: 'نسخ نص الصفحة',
              onTap: () {
                Navigator.pop(context);
                controller.copyPageText();
              },
            ),

            _buildQuickSettingTile(
              icon: Icons.visibility,
              title: 'إخفاء/إظهار الواجهة',
              subtitle: 'التحكم في عرض الأزرار',
              onTap: () {
                Navigator.pop(context);
                controller.toggleUI();
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey.shade50,
      ),
    );
  }
}
