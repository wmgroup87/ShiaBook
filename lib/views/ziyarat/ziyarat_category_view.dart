import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/ziyarat_controller.dart';
import 'package:shia_book/models/ziyarat_model.dart';
import 'package:shia_book/views/ziyarat/ziyarat_detail_view.dart';
import 'package:velocity_x/velocity_x.dart';

class ZiyaratCategoryView extends StatelessWidget {
  final ZiyaratCategory category;

  const ZiyaratCategoryView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ZiyaratController>();

    return Scaffold(
      appBar: AppBar(
        title: category.title.text.lg.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchInCategory(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Header
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
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category.icon),
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      category.title.text.xl.bold.color(Colors.black87).make(),
                      const SizedBox(height: 4),
                      category.description.text.sm
                          .color(Colors.grey.shade600)
                          .make(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          '${category.ziyarat.length} زيارة'
                              .text
                              .xs
                              .color(Colors.grey.shade500)
                              .make(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ziyarat List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: category.ziyarat.length,
              itemBuilder: (context, index) {
                final ziyarat = category.ziyarat[index];
                return _buildZiyaratCard(ziyarat, controller);
              },
            ),
          ),
        ],
      ).box.color(Vx.gray50).make(),
    );
  }

  Widget _buildZiyaratCard(Ziyarat ziyarat, ZiyaratController controller) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          controller.incrementReadCount();
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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        ziyarat.title.text.lg.bold.color(Colors.black87).make(),
                  ),
                  // زر المفضلة
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        controller.isFavorite(ziyarat)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: controller.isFavorite(ziyarat)
                            ? Colors.red
                            : Colors.grey.shade400,
                      ),
                      onPressed: () => controller.toggleFavorite(ziyarat),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ziyarat.arabicText.length > 150
                    ? '${ziyarat.arabicText.substring(0, 150)}...'
                    : ziyarat.arabicText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.black87,
                  fontFamily: 'Amiri',
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (ziyarat.source != null) ...[
                    Icon(Icons.source, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'المصدر: ${ziyarat.source}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                  if (ziyarat.benefits != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                  ],
                  if (ziyarat.occasion != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.event, size: 14, color: Colors.purple),
                  ],
                ],
              ),
              if (ziyarat.benefits != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ziyarat.benefits!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  void _showSearchInCategory(BuildContext context) {
    final controller = Get.find<ZiyaratController>();

    Get.dialog(
      AlertDialog(
        title: 'البحث في ${category.title}'.text.make(),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                // يمكن إضافة البحث داخل الفئة هنا
              },
              decoration: InputDecoration(
                hintText: 'ابحث في هذه الفئة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            'البحث في ${category.ziyarat.length} زيارة'
                .text
                .sm
                .color(Colors.grey.shade600)
                .make(),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: 'إغلاق'.text.make()),
        ],
      ),
    );
  }
}
