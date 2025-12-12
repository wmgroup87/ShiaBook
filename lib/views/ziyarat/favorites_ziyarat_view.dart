import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/ziyarat_controller.dart';
import 'package:shia_book/views/ziyarat/ziyarat_detail_view.dart';
import 'package:velocity_x/velocity_x.dart';

class FavoritesZiyaratView extends GetView<ZiyaratController> {
  const FavoritesZiyaratView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'الزيارات المفضلة'.text.xl2.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          Obx(
            () => controller.favoriteZiyarat.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: () => _showClearAllDialog(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(
        () => controller.favoriteZiyarat.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  // إحصائيات المفضلة
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.1),
                          Colors.red.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              'الزيارات المفضلة'.text.lg.bold.make(),
                              '${controller.favoriteZiyarat.length} زيارة محفوظة'
                                  .text
                                  .sm
                                  .color(Colors.grey.shade600)
                                  .make(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // قائمة المفضلة
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.favoriteZiyarat.length,
                      itemBuilder: (context, index) {
                        final ziyarat = controller.favoriteZiyarat[index];
                        return _buildFavoriteZiyaratCard(ziyarat);
                      },
                    ),
                  ),
                ],
              ),
      ).box.color(Vx.gray50).make(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          'لا توجد زيارات مفضلة'.text.xl.color(Colors.grey.shade600).make(),
          const SizedBox(height: 8),
          'أضف زيارات إلى المفضلة لتظهر هنا'
              .text
              .color(Colors.grey.shade500)
              .center
              .make(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: 'العودة للزيارات'.text.make(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ).p20(),
    );
  }

  Widget _buildFavoriteZiyaratCard(ziyarat) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.to(() => ZiyaratDetailView(ziyarat: ziyarat));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.favorite, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        ziyarat.title.text.lg.bold.color(Colors.black87).make(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => controller.toggleFavorite(ziyarat),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ziyarat.arabicText.length > 100
                    ? '${ziyarat.arabicText.substring(0, 100)}...'
                    : ziyarat.arabicText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.black87,
                  fontFamily: 'Amiri',
                ),
                textAlign: TextAlign.right,
              ),
              if (ziyarat.source != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.source, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'المصدر: ${ziyarat.source}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    Get.dialog(
      AlertDialog(
        title: 'حذف جميع المفضلة'.text.make(),
        content: 'هل تريد حذف جميع الزيارات المفضلة؟'.text.make(),
        actions: [
          TextButton(onPressed: () => Get.back(), child: 'إلغاء'.text.make()),
          TextButton(
            onPressed: () {
              controller.favoriteZiyarat.clear();
              Get.back();
              Get.snackbar(
                'تم الحذف',
                'تم حذف جميع الزيارات المفضلة',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: 'حذف'.text.color(Colors.red).make(),
          ),
        ],
      ),
    );
  }
}
