import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/duas_controller.dart';
import 'package:shia_book/models/dua_model.dart';
import 'package:velocity_x/velocity_x.dart';

class DuaDetailView extends StatelessWidget {
  final Dua dua;

  const DuaDetailView({super.key, required this.dua});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DuasController>();

    return Scaffold(
      appBar: AppBar(
        title: dua.title.text.lg.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          // زر المفضلة
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isFavorite(dua)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: controller.isFavorite(dua) ? Colors.red : Colors.grey,
              ),
              onPressed: () => controller.toggleFavorite(dua),
            ),
          ),
          // زر النسخ
          IconButton(icon: const Icon(Icons.copy), onPressed: () => _copyDua()),
          // زر المشاركة
          IconButton(
              icon: const Icon(Icons.share), onPressed: () => _shareDua()),
          // قائمة الخيارات
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, controller),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'font_size',
                child: Row(
                  children: [
                    Icon(Icons.text_fields, size: 20),
                    SizedBox(width: 8),
                    Text('حجم الخط'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'toggle_translation',
                child: Row(
                  children: [
                    Icon(Icons.translate, size: 20),
                    SizedBox(width: 8),
                    Text('إظهار/إخفاء الترجمة'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عنوان الدعاء مع إحصائيات
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Obx(
                          () => Icon(
                            controller.isFavorite(dua)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: controller.isFavorite(dua)
                                ? Colors.red
                                : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    dua.title.text.xl2.bold.color(Colors.black87).center.make(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(
                          '${dua.arabicText.split(' ').length} كلمة',
                          Icons.text_fields,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          '${(dua.arabicText.length / 100).ceil()} دقيقة',
                          Icons.timer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // أدوات التحكم في النص
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.remove,
                      label: 'تصغير',
                      onPressed: () => controller.decreaseFontSize(),
                    ),
                    Obx(
                      () => Text(
                        'حجم الخط: ${controller.fontSize.value.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildControlButton(
                      icon: Icons.add,
                      label: 'تكبير',
                      onPressed: () => controller.increaseFontSize(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // النص العربي
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.text_fields,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        'النص العربي'
                            .text
                            .lg
                            .bold
                            .color(AppColors.primary)
                            .make(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Obx(
                        () => Text(
                          dua.arabicText,
                          style: TextStyle(
                            fontSize: controller.fontSize.value,
                            height: 2.0,
                            color: Colors.black87,
                            fontFamily: 'Amiri',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // الترجمة
            if (dua.translation != null) ...[
              const SizedBox(height: 16),
              Obx(
                () => controller.showTranslation.value
                    ? Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.translate,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  'الترجمة'
                                      .text
                                      .lg
                                      .bold
                                      .color(AppColors.primary)
                                      .make(),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Text(
                                  dua.translation!,
                                  style: TextStyle(
                                    fontSize: controller.fontSize.value - 2,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],

            // المصدر
            if (dua.source != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.source,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      'المصدر: '.text.lg.bold.color(AppColors.primary).make(),
                      Expanded(
                        child: dua.source!.text.lg.color(Colors.black87).make(),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // الفوائد
            if (dua.benefits != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          'فوائد وملاحظات'
                              .text
                              .lg
                              .bold
                              .color(AppColors.primary)
                              .make(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Text(
                          dua.benefits!,
                          style: TextStyle(
                            fontSize: controller.fontSize.value - 2,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // أزرار الإجراءات السريعة
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.copy,
                      label: 'نسخ',
                      color: Colors.blue,
                      onPressed: _copyDua,
                    ),
                    _buildActionButton(
                      icon: Icons.share,
                      label: 'مشاركة',
                      color: Colors.green,
                      onPressed: _shareDua,
                    ),
                    Obx(
                      () => _buildActionButton(
                        icon: controller.isFavorite(dua)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        label: controller.isFavorite(dua)
                            ? 'مفضل'
                            : 'إضافة للمفضلة',
                        color: Colors.red,
                        onPressed: () => controller.toggleFavorite(dua),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ).box.color(Vx.gray50).make(),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyDua() {
    final text = '''${dua.title}

${dua.arabicText}

${dua.translation != null ? 'الترجمة: ${dua.translation}' : ''}

${dua.source != null ? 'المصدر: ${dua.source}' : ''}''';

    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ الدعاء إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
      duration: const Duration(seconds: 2),
    );
  }

  void _shareDua() {
    final text = '''${dua.title}

${dua.arabicText}

${dua.translation != null ? 'الترجمة: ${dua.translation}' : ''}

${dua.source != null ? 'المصدر: ${dua.source}' : ''}

مشارك من تطبيق الكتب الشيعية''';

    Share.share(text);
  }

  void _handleMenuAction(String action, DuasController controller) {
    switch (action) {
      case 'font_size':
        _showFontSizeDialog();
        break;
      case 'toggle_translation':
        controller.showTranslation.value = !controller.showTranslation.value;
        break;
    }
  }

  void _showFontSizeDialog() {
    final controller = Get.find<DuasController>();
    Get.dialog(
      AlertDialog(
        title: 'حجم الخط'.text.make(),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => controller.decreaseFontSize(),
                  child: const Icon(Icons.remove),
                ),
                Obx(() => Text('${controller.fontSize.value.toInt()}')),
                ElevatedButton(
                  onPressed: () => controller.increaseFontSize(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                'نموذج للنص',
                style: TextStyle(fontSize: controller.fontSize.value),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: 'إغلاق'.text.make()),
        ],
      ),
    );
  }
}
