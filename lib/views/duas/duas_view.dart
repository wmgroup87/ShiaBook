import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/duas_controller.dart';
import 'package:shia_book/models/dua_model.dart';
import 'package:shia_book/views/duas/dua_category_view.dart';
import 'package:shia_book/views/duas/favorites_duas_view.dart';
import 'package:velocity_x/velocity_x.dart';

class DuasView extends StatefulWidget {
  const DuasView({super.key});

  @override
  State<DuasView> createState() => _DuasViewState();
}

class _DuasViewState extends State<DuasView> {
  final DuasController controller = Get.find<DuasController>();

  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.duaCategories.isEmpty) {
        controller.loadDuasFromJson();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'الأدعية الشيعية'.text.xl2.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => Get.to(() => const FavoritesDuasView()),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextField(
              onChanged: controller.searchDuas,
              decoration: const InputDecoration(
                hintText: 'البحث في الأدعية...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // Quick stats
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'الفئات',
                      '${controller.totalCategories}',
                      Icons.category,
                    ),
                    _buildStatItem(
                      'المفضلة',
                      '${controller.totalFavorites}',
                      Icons.favorite,
                    ),
                    _buildStatItem(
                      'المجموع',
                      '${controller.totalDuas}',
                      Icons.menu_book,
                    ),
                  ],
                )),
          ),

          const SizedBox(height: 16),

          // Categories list
          Expanded(
            child: Obx(
              () => GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
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

  Widget _buildStatItem(String title, String count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(DuaCategory category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Get.to(() => DuaCategoryView(category: category));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(category.title),
                  size: 32,
                  color: AppColors.primary,
                ),
              ).pOnly(bottom: 12),
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '${category.duas.length} دعاء',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ).pOnly(top: 4),
            ],
          ).p12(),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String title) {
    switch (title) {
      case 'أدعية المعصومين':
        return Icons.person;
      case 'أدعية يومية':
        return Icons.calendar_today;
      case 'أدعية قرآنية':
        return Icons.menu_book;
      case 'أدعية المناسبات':
        return Icons.event;
      case 'أدعية شهر رمضان':
        return Icons.nights_stay;
      case 'أدعية شهر شعبان':
        return Icons.nightlight_round;
      case 'أدعية شهر رجب':
        return Icons.brightness_3;
      default:
        return Icons.category;
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بحث'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ابحث عن دعاء...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            controller.searchDuas(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
