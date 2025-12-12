import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/settings_controller.dart';
import 'package:velocity_x/velocity_x.dart';

class AppearanceSettingsView extends GetView<SettingsController> {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'إعدادات المظهر'.text.xl.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Theme Mode Section
              _buildSection(
                title: 'وضع العرض',
                icon: Icons.brightness_6,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('الوضع الليلي'),
                      subtitle: const Text('تفعيل الوضع المظلم للتطبيق'),
                      value: controller.settings.value.isDarkMode,
                      onChanged: controller.updateDarkMode,
                      secondary: Icon(
                        controller.settings.value.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: AppColors.primary,
                      ),
                    ),
                    if (controller.settings.value.isDarkMode)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'الوضع الليلي يساعد على راحة العينين في الإضاءة المنخفضة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Font Size Section
              _buildSection(
                title: 'حجم الخط',
                icon: Icons.format_size,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('صغير'),
                          Expanded(
                            child: Slider(
                              value: controller.settings.value.fontSize,
                              min: 12.0,
                              max: 24.0,
                              divisions: 6,
                              label:
                                  '${controller.settings.value.fontSize.toInt()}',
                              onChanged: controller.updateFontSize,
                            ),
                          ),
                          const Text('كبير'),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'هذا نموذج للنص بالحجم المحدد',
                        style: TextStyle(
                          fontSize: controller.settings.value.fontSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Font Family Section
              _buildSection(
                title: 'نوع الخط',
                icon: Icons.font_download,
                child: Column(
                  children:
                      ['Cairo', 'Amiri', 'Scheherazade', 'Noto Sans Arabic']
                          .map(
                            (font) => RadioListTile<String>(
                              title: Text(
                                'نموذج نص بخط $font',
                                style: TextStyle(fontFamily: font),
                              ),
                              value: font,
                              groupValue: controller.settings.value.fontFamily,
                              onChanged: (value) =>
                                  controller.updateFontFamily(value!),
                            ),
                          )
                          .toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Theme Color Section
              _buildSection(
                title: 'لون التطبيق',
                icon: Icons.palette,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildColorOption('أخضر', Colors.green),
                          _buildColorOption('أزرق', Colors.blue),
                          _buildColorOption('بنفسجي', Colors.purple),
                          _buildColorOption('برتقالي', Colors.orange),
                          _buildColorOption('أحمر', Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Layout Settings
              _buildSection(
                title: 'إعدادات التخطيط',
                icon: Icons.view_quilt,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('عرض مضغوط'),
                      subtitle: const Text('تقليل المسافات بين العناصر'),
                      value: false,
                      onChanged: (value) {
                        Get.snackbar('قريباً', 'سيتم إضافة هذه الميزة قريباً');
                      },
                    ),
                    SwitchListTile(
                      title: const Text('إخفاء شريط التنقل'),
                      subtitle: const Text('إخفاء شريط التنقل السفلي تلقائياً'),
                      value: false,
                      onChanged: (value) {
                        Get.snackbar('قريباً', 'سيتم إضافة هذه الميزة قريباً');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Animation Settings
              _buildSection(
                title: 'الحركات والانتقالات',
                icon: Icons.animation,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('تفعيل الحركات'),
                      subtitle: const Text('عرض حركات انتقال بين الصفحات'),
                      value: true,
                      onChanged: (value) {
                        Get.snackbar('قريباً', 'سيتم إضافة هذه الميزة قريباً');
                      },
                    ),
                    ListTile(
                      title: const Text('سرعة الحركات'),
                      subtitle: Slider(
                        value: 0.5,
                        min: 0.1,
                        max: 1.0,
                        onChanged: (value) {
                          Get.snackbar(
                            'قريباً',
                            'سيتم إضافة هذه الميزة قريباً',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reset Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _resetAppearanceSettings(),
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: const Text(
                    'إعادة تعيين إعدادات المظهر',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                title.text.lg.bold.color(AppColors.primary).make(),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildColorOption(String name, Color color) {
    final isSelected = controller.settings.value.themeColor == name;

    return GestureDetector(
      onTap: () => controller.updateThemeColor(name),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : null,
      ),
    );
  }

  void _resetAppearanceSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('إعادة تعيين إعدادات المظهر'),
        content: const Text(
          'هل تريد إعادة تعيين جميع إعدادات المظهر إلى القيم الافتراضية؟',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              controller.updateDarkMode(false);
              controller.updateFontSize(16.0);
              controller.updateFontFamily('Cairo');
              controller.updateThemeColor('أخضر');
              Get.back();
              Get.snackbar(
                'تم بنجاح',
                'تم إعادة تعيين إعدادات المظهر',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
