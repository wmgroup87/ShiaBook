import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/settings_controller.dart';
import 'package:shia_book/views/settings/appearance_settings_view.dart';
import 'package:shia_book/views/settings/notification_settings_view.dart';
import 'package:shia_book/views/settings/prayer_settings_view.dart';
import 'package:shia_book/views/settings/backup_settings_view.dart';
import 'package:shia_book/views/settings/about_view.dart';
import 'package:shia_book/views/settings/privacy_settings_view.dart';
import 'package:velocity_x/velocity_x.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'الإعدادات'.text.xl2.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  _showResetDialog();
                  break;
                case 'export':
                  controller.exportSettings();
                  break;
                case 'import':
                  controller.importSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload, size: 20),
                    SizedBox(width: 8),
                    Text('تصدير الإعدادات'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('استيراد الإعدادات'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('إعادة تعيين', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                'جاري تحميل الإعدادات...'.text.lg.make(),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // قسم المظهر والعرض
              _buildSettingsCategory(
                title: 'المظهر والعرض',
                icon: Icons.palette,
                color: Colors.purple,
                onTap: () => Get.to(() => const AppearanceSettingsView()),
                items: [
                  'الوضع الليلي: ${controller.settings.value.isDarkMode ? "مفعل" : "معطل"}',
                  'حجم الخط: ${controller.settings.value.fontSize.toInt()}',
                  'اللون: ${controller.settings.value.themeColor}',
                ],
              ),

              const SizedBox(height: 16),

              // قسم الإشعارات
              _buildSettingsCategory(
                title: 'الإشعارات',
                icon: Icons.notifications,
                color: Colors.orange,
                onTap: () => Get.to(() => const NotificationSettingsView()),
                items: [
                  'الإشعارات: ${controller.settings.value.notificationsEnabled ? "مفعلة" : "معطلة"}',
                  'تذكير الصلاة: ${controller.settings.value.prayerReminders ? "مفعل" : "معطل"}',
                  'تذكير المناسبات: ${controller.settings.value.eventReminders ? "مفعل" : "معطل"}',
                ],
              ),

              const SizedBox(height: 16),

              // قسم إعدادات الصلاة
              _buildSettingsCategory(
                title: 'إعدادات الصلاة',
                icon: Icons.access_time,
                color: Colors.green,
                onTap: () => Get.to(() => const PrayerSettingsView()),
                items: [
                  'طريقة الحساب: ${controller.settings.value.prayerCalculationMethod}',
                  'تعديل التاريخ الهجري: ${controller.settings.value.hijriDateAdjustment}',
                  'الموقع: الرياض، السعودية',
                ],
              ),

              const SizedBox(height: 16),

              // قسم القراءة والصوت
              _buildSettingsCategory(
                title: 'القراءة والصوت',
                icon: Icons.volume_up,
                color: Colors.teal,
                onTap: () => _showAudioSettings(),
                items: [
                  'سرعة التشغيل: ${controller.settings.value.audioSpeed}x',
                  'النص العربي: ${controller.settings.value.showArabicText ? "مفعل" : "معطل"}',
                  'الترجمة: ${controller.settings.value.showTranslation ? "مفعلة" : "معطلة"}',
                ],
              ),

              const SizedBox(height: 16),

              // قسم النسخ الاحتياطي
              _buildSettingsCategory(
                title: 'النسخ الاحتياطي',
                icon: Icons.backup,
                color: Colors.blue,
                onTap: () => Get.to(() => const BackupSettingsView()),
                items: [
                  'النسخ التلقائي: ${controller.settings.value.autoBackup ? "مفعل" : "معطل"}',
                  'التكرار: ${controller.settings.value.backupFrequency}',
                  'آخر نسخة: اليوم',
                ],
              ),

              const SizedBox(height: 16),

              // قسم اللغة والمنطقة
              _buildSettingsCategory(
                title: 'اللغة والمنطقة',
                icon: Icons.language,
                color: Colors.indigo,
                onTap: () => _showLanguageSettings(),
                items: [
                  'اللغة: ${controller.settings.value.language}',
                  'نوع الخط: ${controller.settings.value.fontFamily}',
                  'اتجاه النص: من اليمين لليسار',
                ],
              ),

              const SizedBox(height: 16),

              // قسم حول التطبيق
              _buildSettingsCategory(
                title: 'حول التطبيق',
                icon: Icons.info,
                color: Colors.grey,
                onTap: () => Get.to(() => const AboutView()),
                items: ['الإصدار 1.0.0', 'معلومات المطور', 'الترخيص والشروط'],
              ),

              const SizedBox(height: 20),

              // الإجراءات السريعة
              _buildQuickActions(),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  'مستخدم التطبيق'.text.xl.bold.color(Colors.black87).make(),
                  const SizedBox(height: 4),
                  'مرحباً بك في تطبيق الكتب الشيعية'
                      .text
                      .color(Colors.grey.shade600)
                      .make(),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: 'مستخدم نشط'
                        .text
                        .sm
                        .color(Colors.green.shade700)
                        .make(),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showProfileOptions(),
              icon: const Icon(Icons.edit, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCategory({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required List<String> items,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: title.text.xl.bold.color(Colors.black87).make(),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...items.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 56),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: item.text.sm.color(Colors.grey.shade700).make(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                'إجراءات سريعة'.text.lg.bold.color(Colors.black87).make(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.refresh,
                    label: 'إعادة تحميل',
                    color: Colors.blue,
                    onTap: () => controller.loadSettings(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.clear_all,
                    label: 'مسح الكاش',
                    color: Colors.orange,
                    onTap: () => _clearCache(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.star_rate,
                    label: 'تقييم التطبيق',
                    color: Colors.amber,
                    onTap: () => _rateApp(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.share,
                    label: 'مشاركة التطبيق',
                    color: Colors.green,
                    onTap: () => _shareApp(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            label.text.xs.color(color).center.bold.make(),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            'خيارات الملف الشخصي'.text.xl.bold.make(),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('تعديل الملف الشخصي'),
              onTap: () {
                Get.back();
                _editProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.blue),
              title: const Text('تغيير الصورة الشخصية'),
              onTap: () {
                Get.back();
                _changeProfilePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج'),
              onTap: () {
                Get.back();
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            'إعدادات الصوت والقراءة'.text.xl.bold.make(),
            const SizedBox(height: 20),
            Obx(
              () => Column(
                children: [
                  ListTile(
                    title: const Text('سرعة التشغيل'),
                    subtitle: Slider(
                      value: controller.settings.value.audioSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 6,
                      label: '${controller.settings.value.audioSpeed}x',
                      onChanged: controller.updateAudioSpeed,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('عرض النص العربي'),
                    value: controller.settings.value.showArabicText,
                    onChanged: controller.updateShowArabicText,
                  ),
                  SwitchListTile(
                    title: const Text('عرض الترجمة'),
                    value: controller.settings.value.showTranslation,
                    onChanged: controller.updateShowTranslation,
                  ),
                  SwitchListTile(
                    title: const Text('الوضع غير المتصل'),
                    value: controller.settings.value.offlineMode,
                    onChanged: controller.updateOfflineMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    Get.to(() => const PrivacySettingsView());
  }

  void _showLanguageSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            'إعدادات اللغة والخط'.text.xl.bold.make(),
            const SizedBox(height: 20),
            Obx(
              () => Column(
                children: [
                  // اختيار اللغة
                  'اللغة'.text.lg.bold.make(),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('العربية'),
                    value: 'العربية',
                    groupValue: controller.settings.value.language,
                    onChanged: (value) => controller.updateLanguage(value!),
                    activeColor: AppColors.primary,
                  ),
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'English',
                    groupValue: controller.settings.value.language,
                    onChanged: (value) => controller.updateLanguage(value!),
                    activeColor: AppColors.primary,
                  ),
                  RadioListTile<String>(
                    title: const Text('فارسی'),
                    value: 'فارسی',
                    groupValue: controller.settings.value.language,
                    onChanged: (value) => controller.updateLanguage(value!),
                    activeColor: AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  // اختيار نوع الخط
                  'نوع الخط'.text.lg.bold.make(),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: controller.settings.value.fontFamily,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items:
                        ['Cairo', 'Amiri', 'Scheherazade', 'Noto Sans Arabic']
                            .map(
                              (font) => DropdownMenuItem(
                                value: font,
                                child: Text(
                                  font,
                                  style: TextStyle(fontFamily: font),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => controller.updateFontFamily(value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    Get.snackbar('تعديل الملف الشخصي', 'سيتم إضافة هذه الميزة قريباً');
  }

  void _changeProfilePicture() {
    Get.snackbar('تغيير الصورة', 'سيتم إضافة هذه الميزة قريباً');
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('تم تسجيل الخروج', 'تم تسجيل خروجك بنجاح');
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text(
          'هل تريد إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              controller.resetSettings();
              Get.back();
              Get.snackbar(
                'تم بنجاح',
                'تم إعادة تعيين جميع الإعدادات',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إعادة تعيين',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    Get.dialog(
      AlertDialog(
        title: const Text('مسح الكاش'),
        content:
            const Text('سيتم مسح جميع البيانات المؤقتة. هل تريد المتابعة؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم بنجاح',
                'تم مسح الكاش بنجاح',
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

  void _reportBug() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            'إبلاغ عن خطأ'.text.xl.bold.make(),
            const SizedBox(height: 20),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب وصف المشكلة هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'شكراً لك',
                        'تم إرسال التقرير بنجاح',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    child: const Text('إرسال'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _rateApp() {
    Get.dialog(
      AlertDialog(
        title: const Text('تقييم التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('كيف تقيم تجربتك مع التطبيق؟'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      'شكراً لك',
                      'تم تسجيل تقييمك: ${index + 1} نجوم',
                      backgroundColor: Colors.amber,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.star, color: Colors.amber, size: 32),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ],
      ),
    );
  }

  void _shareApp() {
    Get.snackbar(
      'مشاركة التطبيق',
      'تم نسخ رابط التطبيق للمشاركة',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
