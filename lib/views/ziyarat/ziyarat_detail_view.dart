import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/ziyarat_controller.dart';
import 'package:shia_book/models/ziyarat_model.dart';
import 'package:velocity_x/velocity_x.dart';

class ZiyaratDetailView extends StatelessWidget {
  final Ziyarat ziyarat;

  const ZiyaratDetailView({super.key, required this.ziyarat});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ZiyaratController>();

    return Scaffold(
      appBar: AppBar(
        title: ziyarat.title.text.lg.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
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
              PopupMenuItem(
                value: 'toggle_translation',
                child: Row(
                  children: [
                    const Icon(Icons.translate, size: 20),
                    const SizedBox(width: 8),
                    GetBuilder<ZiyaratController>(
                      builder: (ctrl) => Text(
                        ctrl.showTranslation.value
                            ? 'إخفاء الترجمة'
                            : 'إظهار الترجمة',
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_transliteration',
                child: Row(
                  children: [
                    const Icon(Icons.record_voice_over, size: 20),
                    const SizedBox(width: 8),
                    GetBuilder<ZiyaratController>(
                      builder: (ctrl) => Text(
                        ctrl.showTransliteration.value
                            ? 'إخفاء النطق'
                            : 'إظهار النطق',
                      ),
                    ),
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
            // معلومات سريعة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoChip(
                  '${ziyarat.arabicText.split(' ').length} كلمة',
                  Icons.text_fields,
                ),
                _buildInfoChip(
                  '${(ziyarat.arabicText.split(' ').length / 100).ceil()} دقيقة',
                  Icons.timer,
                ),
                if (ziyarat.occasion != null)
                  _buildInfoChip('مناسبة خاصة', Icons.event),
              ],
            ),

            const SizedBox(height: 20),

            // أزرار التحكم
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
                    GetBuilder<ZiyaratController>(
                      builder: (ctrl) => Text(
                        '${ctrl.fontSize.value.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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

            const SizedBox(height: 20),

            // عنوان الزيارة
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
                    const Icon(Icons.menu_book,
                        size: 40, color: AppColors.primary),
                    const SizedBox(height: 12),
                    ziyarat.title.text.xl2.bold
                        .color(Colors.black87)
                        .center
                        .make(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // النص العربي
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: GetBuilder<ZiyaratController>(
                        builder: (ctrl) => SelectableText(
                          ziyarat.arabicText,
                          style: TextStyle(
                            fontSize: ctrl.fontSize.value,
                            height: 2.0,
                            color: Colors.black87,
                            fontFamily: 'Amiri',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // النطق
            if (ziyarat.transliteration != null) ...[
              const SizedBox(height: 16),
              GetBuilder<ZiyaratController>(
                builder: (ctrl) => ctrl.showTransliteration.value
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
                                    Icons.record_voice_over,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  'النطق'
                                      .text
                                      .lg
                                      .bold
                                      .color(Colors.orange)
                                      .make(),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: SelectableText(
                                  ziyarat.transliteration!,
                                  style: TextStyle(
                                    fontSize: ctrl.fontSize.value - 2,
                                    height: 1.8,
                                    color: Colors.black87,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],

            // الترجمة
            if (ziyarat.translation != null) ...[
              const SizedBox(height: 16),
              GetBuilder<ZiyaratController>(
                builder: (ctrl) => ctrl.showTranslation.value
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
                                    color: AppColors.secondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  'الترجمة'
                                      .text
                                      .lg
                                      .bold
                                      .color(AppColors.secondary)
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
                                child: SelectableText(
                                  ziyarat.translation!,
                                  style: TextStyle(
                                    fontSize: ctrl.fontSize.value - 2,
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

            // Source
            if (ziyarat.source != null) ...[
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
                      const Icon(Icons.source, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      'المصدر:'.text.lg.bold.color(Colors.blue).make(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ziyarat.source!.text.lg
                            .color(Colors.black87)
                            .make(),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Benefits
            if (ziyarat.benefits != null) ...[
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
                          'الفوائد والملاحظات'
                              .text
                              .lg
                              .bold
                              .color(Colors.amber.shade700)
                              .make(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Text(
                          ziyarat.benefits!,
                          style: const TextStyle(
                            fontSize: 16,
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

            // Occasion
            if (ziyarat.occasion != null) ...[
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
                      const Icon(Icons.event, color: Colors.purple, size: 20),
                      const SizedBox(width: 12),
                      'المناسبة:'.text.lg.bold.color(Colors.purple).make(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ziyarat.occasion!.text.lg
                            .color(Colors.black87)
                            .make(),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ).box.color(Vx.gray50).make(),

      // شريط الأدوات السفلي
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GetBuilder<ZiyaratController>(
              builder: (ctrl) => _buildBottomButton(
                icon: ctrl.isFavorite(ziyarat)
                    ? Icons.favorite
                    : Icons.favorite_border,
                label: 'مفضلة',
                color: ctrl.isFavorite(ziyarat) ? Colors.red : Colors.grey,
                onPressed: () => ctrl.toggleFavorite(ziyarat),
              ),
            ),
            _buildBottomButton(
              icon: Icons.copy,
              label: 'نسخ',
              color: AppColors.primary,
              onPressed: () => _copyToClipboard(context),
            ),
            _buildBottomButton(
              icon: Icons.share,
              label: 'مشاركة',
              color: Colors.blue,
              onPressed: () => _shareZiyarat(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
              fontWeight: FontWeight.w500,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.primary),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            shape: const CircleBorder(),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, ZiyaratController controller) {
    switch (action) {
      case 'font_size':
        _showFontSizeDialog();
        break;
      case 'toggle_translation':
        controller.toggleTranslation();
        break;
      case 'toggle_transliteration':
        controller.toggleTransliteration();
        break;
    }
  }

  void _showFontSizeDialog() {
    final controller = Get.find<ZiyaratController>();
    Get.dialog(
      AlertDialog(
        title: 'حجم الخط'.text.make(),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'اختر حجم الخط المناسب'.text.make(),
            const SizedBox(height: 16),
            GetBuilder<ZiyaratController>(
              builder: (ctrl) => Column(
                children: [
                  Slider(
                    value: ctrl.fontSize.value,
                    min: 12,
                    max: 28,
                    divisions: 8,
                    label: '${ctrl.fontSize.value.toInt()}',
                    onChanged: (value) {
                      ctrl.fontSize.value = value;
                      ctrl.update();
                    },
                  ),
                  Text(
                    'حجم الخط: ${ctrl.fontSize.value.toInt()}',
                    style: TextStyle(fontSize: ctrl.fontSize.value),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: 'موافق'.text.make()),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    String textToCopy = '''${ziyarat.title}

${ziyarat.arabicText}''';

    if (ziyarat.translation != null) {
      textToCopy += '\n\nالترجمة:\n${ziyarat.translation}';
    }

    if (ziyarat.source != null) {
      textToCopy += '\n\nالمصدر: ${ziyarat.source}';
    }

    Clipboard.setData(ClipboardData(text: textToCopy));

    Get.snackbar(
      'تم النسخ',
      'تم نسخ الزيارة إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _shareZiyarat() {
    String textToShare = '''${ziyarat.title}

${ziyarat.arabicText}''';

    if (ziyarat.translation != null) {
      textToShare += '\n\nالترجمة:\n${ziyarat.translation}';
    }

    if (ziyarat.source != null) {
      textToShare += '\n\nالمصدر: ${ziyarat.source}';
    }

    textToShare += '\n\nمن تطبيق الكتب الشيعية';

    Share.share(textToShare);
  }
}
