import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/controllers/duas_controller.dart';
import 'package:shia_book/views/duas/dua_detail_view.dart';
import 'package:velocity_x/velocity_x.dart';

class FavoritesDuasView extends GetView<DuasController> {
  const FavoritesDuasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'الأدعية المفضلة'.text.xl2.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Obx(
        () => controller.favoriteDuas.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.favoriteDuas.length,
                itemBuilder: (context, index) {
                  final dua = controller.favoriteDuas[index];
                  return _buildFavoriteDuaCard(dua);
                },
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
          'لا توجد أدعية مفضلة'.text.xl.color(Colors.grey.shade600).make(),
          const SizedBox(height: 8),
          'اضغط على القلب في أي دعاء لإضافته للمفضلة'
              .text
              .color(Colors.grey.shade500)
              .center
              .make(),
        ],
      ).p20(),
    );
  }

  Widget _buildFavoriteDuaCard(dua) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.to(() => DuaDetailView(dua: dua)),
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
                    child: Text(
                      dua.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => controller.toggleFavorite(dua),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dua.arabicText.length > 100
                    ? '${dua.arabicText.substring(0, 100)}...'
                    : dua.arabicText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.black87,
                  fontFamily: 'Amiri',
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
