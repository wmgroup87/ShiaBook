import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/ziyarat_controller.dart';
import 'package:shia_book/models/ziyarat_model.dart';
import 'package:shia_book/views/ziyarat/favorites_ziyarat_view.dart';
import 'package:shia_book/views/ziyarat/ziyarat_category_view.dart';
import 'package:velocity_x/velocity_x.dart';

class ZiyaratView extends GetView<ZiyaratController> {
  const ZiyaratView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'الزيارات'.text.xl2.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          // زر المفضلة
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                Obx(
                  () => controller.favoriteZiyarat.isNotEmpty
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${controller.favoriteZiyarat.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            onPressed: () => Get.to(() => const FavoritesZiyaratView()),
          ),
          // زر البحث
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with statistics
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mosque,
                        size: 40, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Obx(
                      () => controller.favoriteZiyarat.isNotEmpty
                          ? const Icon(Icons.favorite,
                              color: Colors.red, size: 24)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                'زيارات الأئمة الأطهار'
                    .text
                    .xl
                    .bold
                    .color(Colors.black87)
                    .center
                    .make(),
                const SizedBox(height: 8),
                'مجموعة شاملة من زيارات أهل البيت عليهم السلام في المراقد المقدسة'
                    .text
                    .sm
                    .color(Colors.grey.shade600)
                    .center
                    .make(),
                const SizedBox(height: 12),
                // إحصائيات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      '${controller.ziyaratCategories.length}',
                      'فئة',
                      Icons.category,
                    ),
                    _buildStatCard(
                      '${controller.getTotalZiyaratCount()}',
                      'زيارة',
                      Icons.menu_book,
                    ),
                    Obx(
                      () => _buildStatCard(
                        '${controller.favoriteZiyarat.length}',
                        'مفضلة',
                        Icons.favorite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: controller.searchZiyarat,
              decoration: InputDecoration(
                hintText: 'البحث في الزيارات...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Categories List
          Expanded(
            child: Obx(
              () => controller.filteredCategories.isEmpty
                  ? _buildEmptySearchState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = controller.filteredCategories[index];
                        return _buildCategoryCard(category);
                      },
                    ),
            ),
          ),
        ],
      ).box.color(Vx.gray50).make(),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          number.text.lg.bold.color(AppColors.primary).make(),
          label.text.xs.color(Colors.grey.shade600).make(),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          'لا توجد نتائج للبحث'.text.xl.color(Colors.grey.shade600).make(),
          const SizedBox(height: 8),
          'جرب كلمات مختلفة أو تأكد من الإملاء'
              .text
              .color(Colors.grey.shade500)
              .center
              .make(),
        ],
      ).p20(),
    );
  }

  Widget _buildCategoryCard(ZiyaratCategory category) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.to(() => ZiyaratCategoryView(category: category));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category.icon),
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    category.title.text.lg.bold.color(Colors.black87).make(),
                    const SizedBox(height: 4),
                    category.description.text.sm
                        .color(Colors.grey.shade600)
                        .make(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.book, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        '${category.ziyarat.length} زيارة'
                            .text
                            .xs
                            .color(Colors.grey.shade500)
                            .make(),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        _getCategoryLocation(
                          category.title,
                        ).text.xs.color(Colors.grey.shade500).make(),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'madinah':
        return Icons.mosque;
      case 'najaf':
        return Icons.account_balance;
      case 'karbala':
        return Icons.favorite;
      case 'samarra':
        return Icons.star;
      case 'kadhimiya':
        return Icons.brightness_7;
      case 'sham':
        return Icons.home;
      case 'general':
        return Icons.menu_book;
      default:
        return Icons.place;
    }
  }

  String _getCategoryLocation(String title) {
    if (title.contains('المدينة')) return 'المدينة المنورة';
    if (title.contains('النجف')) return 'النجف الأشرف';
    if (title.contains('كربلاء')) return 'كربلاء المقدسة';
    if (title.contains('سامراء')) return 'سامراء المقدسة';
    if (title.contains('الكاظمية')) return 'الكاظمية المقدسة';
    if (title.contains('الشام')) return 'دمشق الشام';
    return 'عامة';
  }

  void _showSearchDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: 'البحث في الزيارات'.text.make(),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: controller.searchZiyarat,
              decoration: InputDecoration(
                hintText: 'ابحث عن زيارة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            'يمكنك البحث بالعنوان أو النص العربي'
                .text
                .sm
                .color(Colors.grey.shade600)
                .make(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.searchZiyarat('');
              Get.back();
            },
            child: 'مسح البحث'.text.make(),
          ),
          TextButton(onPressed: () => Get.back(), child: 'إغلاق'.text.make()),
        ],
      ),
    );
  }
}
