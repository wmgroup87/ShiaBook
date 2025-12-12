import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/settings_controller.dart';
import 'package:velocity_x/velocity_x.dart';

class BackupSettingsView extends GetView<SettingsController> {
  const BackupSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'النسخ الاحتياطي'.text.xl.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showBackupHelp(),
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // معلومات النسخ الاحتياطي
              _buildBackupInfoCard(),

              const SizedBox(height: 20),

              // الإعدادات التلقائية
              _buildAutoBackupSection(),

              const SizedBox(height: 16),

              // النسخ اليدوي
              _buildManualBackupSection(),

              const SizedBox(height: 16),

              // الاستعادة
              _buildRestoreSection(),

              const SizedBox(height: 16),

              // إعدادات التخزين
              _buildStorageSection(),

              const SizedBox(height: 20),

              // أزرار الإجراءات
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.green.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.backup, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            'حماية بياناتك'.text.xl.bold.center.make(),
            const SizedBox(height: 8),
            Text(
              'احتفظ بنسخة احتياطية من إعداداتك وبياناتك\nلضمان عدم فقدانها',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'آخر نسخة احتياطية: اليوم 2:30 مساءً',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoBackupSection() {
    return _buildSection(
      title: 'النسخ التلقائي',
      icon: Icons.schedule,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('تفعيل النسخ التلقائي'),
            subtitle: const Text('إنشاء نسخة احتياطية تلقائياً'),
            value: controller.settings.value.autoBackup,
            onChanged: controller.updateAutoBackup,
            secondary: Icon(
              controller.settings.value.autoBackup
                  ? Icons.backup
                  : Icons.backup_outlined,
              color: controller.settings.value.autoBackup
                  ? AppColors.primary
                  : Colors.grey,
            ),
            activeColor: AppColors.primary,
          ),
          if (controller.settings.value.autoBackup) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  'تكرار النسخ الاحتياطي'.text.sm.bold.make(),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: controller.settings.value.backupFrequency,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: ['يومياً', 'أسبوعياً', 'شهرياً', 'عند الإغلاق']
                        .map(
                          (frequency) => DropdownMenuItem(
                            value: frequency,
                            child: Text(frequency),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateBackupFrequency(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('النسخ عبر WiFi فقط'),
              subtitle: const Text('تجنب استخدام بيانات الجوال'),
              value: true,
              onChanged: (value) {
                Get.snackbar(
                  'تم التحديث',
                  'تم ${value ? "تفعيل" : "إيقاف"} النسخ عبر WiFi فقط',
                );
              },
              secondary: const Icon(Icons.wifi, color: Colors.blue),
              activeColor: AppColors.primary,
            ),
            SwitchListTile(
              title: const Text('النسخ أثناء الشحن فقط'),
              subtitle: const Text('توفير البطارية'),
              value: false,
              onChanged: (value) {
                Get.snackbar(
                  'تم التحديث',
                  'تم ${value ? "تفعيل" : "إيقاف"} النسخ أثناء الشحن',
                );
              },
              secondary: const Icon(
                Icons.battery_charging_full,
                color: Colors.orange,
              ),
              activeColor: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualBackupSection() {
    return _buildSection(
      title: 'النسخ اليدوي',
      icon: Icons.save,
      child: Column(
        children: [
          ListTile(
            title: const Text('إنشاء نسخة احتياطية الآن'),
            subtitle: const Text('حفظ جميع البيانات والإعدادات'),
            leading: const Icon(Icons.backup, color: AppColors.primary),
            trailing: ElevatedButton(
              onPressed: () => _createBackup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('نسخ احتياطي'),
            ),
          ),
          ListTile(
            title: const Text('تصدير البيانات'),
            subtitle: const Text('حفظ البيانات في ملف خارجي'),
            leading: const Icon(Icons.download, color: Colors.blue),
            trailing: IconButton(
              onPressed: () => _exportData(),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          ListTile(
            title: const Text('مشاركة النسخة الاحتياطية'),
            subtitle: const Text('إرسال النسخة عبر التطبيقات الأخرى'),
            leading: const Icon(Icons.share, color: Colors.green),
            trailing: IconButton(
              onPressed: () => _shareBackup(),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreSection() {
    return _buildSection(
      title: 'الاستعادة',
      icon: Icons.restore,
      child: Column(
        children: [
          ListTile(
            title: const Text('استعادة من نسخة احتياطية'),
            subtitle: const Text('استرجاع البيانات من ملف محفوظ'),
            leading: const Icon(Icons.restore, color: Colors.orange),
            trailing: ElevatedButton(
              onPressed: () => _restoreFromBackup(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('استعادة'),
            ),
          ),
          ListTile(
            title: const Text('استيراد من ملف'),
            subtitle: const Text('تحميل نسخة احتياطية من ملف خارجي'),
            leading: const Icon(Icons.upload_file, color: Colors.purple),
            trailing: IconButton(
              onPressed: () => _importFromFile(),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الاستعادة ستستبدل جميع البيانات الحالية',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection() {
    return _buildSection(
      title: 'إعدادات التخزين',
      icon: Icons.storage,
      child: Column(
        children: [
          ListTile(
            title: const Text('موقع التخزين'),
            subtitle: const Text('التخزين المحلي'),
            leading: const Icon(Icons.folder, color: AppColors.primary),
            trailing: DropdownButton<String>(
              value: 'محلي',
              items: ['محلي', 'Google Drive', 'iCloud']
                  .map(
                    (location) => DropdownMenuItem(
                      value: location,
                      child: Text(location),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                Get.snackbar('تم التحديث', 'تم تغيير موقع التخزين إلى $value');
              },
            ),
          ),
          const ListTile(
            title: Text('حجم النسخ الاحتياطية'),
            subtitle: Text('2.5 ميجابايت'),
            leading: Icon(Icons.info, color: Colors.blue),
          ),
          ListTile(
            title: const Text('عدد النسخ المحفوظة'),
            subtitle: const Text('الاحتفاظ بـ 5 نسخ كحد أقصى'),
            leading: const Icon(Icons.numbers, color: Colors.green),
            trailing: DropdownButton<int>(
              value: 5,
              items: [3, 5, 10, 20]
                  .map(
                    (count) => DropdownMenuItem(
                      value: count,
                      child: Text('$count نسخ'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                Get.snackbar('تم التحديث', 'تم تحديد عدد النسخ إلى $value');
              },
            ),
          ),
          SwitchListTile(
            title: const Text('ضغط النسخ الاحتياطية'),
            subtitle: const Text('تقليل حجم الملفات'),
            value: true,
            onChanged: (value) {
              Get.snackbar(
                'تم التحديث',
                'تم ${value ? "تفعيل" : "إيقاف"} ضغط النسخ',
              );
            },
            secondary: const Icon(Icons.compress, color: Colors.purple),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('تشفير النسخ الاحتياطية'),
            subtitle: const Text('حماية البيانات بكلمة مرور'),
            value: false,
            onChanged: (value) {
              if (value) {
                _showEncryptionDialog();
              } else {
                Get.snackbar('تم التحديث', 'تم إيقاف تشفير النسخ');
              }
            },
            secondary: const Icon(Icons.lock, color: Colors.red),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _deleteAllBackups(),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'حذف جميع النسخ',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _viewBackupHistory(),
                icon: const Icon(Icons.history),
                label: const Text('سجل النسخ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                title.text.lg.bold.color(AppColors.primary).make(),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  void _createBackup() {
    Get.dialog(
      AlertDialog(
        title: const Text('إنشاء نسخة احتياطية'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل تريد إنشاء نسخة احتياطية الآن؟'),
            SizedBox(height: 16),
            LinearProgressIndicator(),
            SizedBox(height: 8),
            Text(
              'جاري إنشاء النسخة الاحتياطية...',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم بنجاح',
                'تم إنشاء النسخة الاحتياطية',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
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
            'تصدير البيانات'.text.xl.bold.make(),
            const SizedBox(height: 20),
            const Text('اختر البيانات التي تريد تصديرها:'),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('الإعدادات'),
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
            CheckboxListTile(
              title: const Text('العلامات المرجعية'),
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
            CheckboxListTile(
              title: const Text('سجل القراءة'),
              value: false,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
            CheckboxListTile(
              title: const Text('الملاحظات'),
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
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
                        'تم التصدير',
                        'تم تصدير البيانات بنجاح',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    child: const Text('تصدير'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareBackup() {
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
            'مشاركة النسخة الاحتياطية'.text.xl.bold.make(),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildShareOption(Icons.email, 'البريد', Colors.blue),
                _buildShareOption(Icons.message, 'الرسائل', Colors.green),
                _buildShareOption(
                  Icons.cloud_upload,
                  'التخزين السحابي',
                  Colors.purple,
                ),
                _buildShareOption(Icons.bluetooth, 'البلوتوث', Colors.indigo),
                _buildShareOption(Icons.wifi, 'WiFi Direct', Colors.orange),
                _buildShareOption(Icons.more_horiz, 'المزيد', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        Get.back();
        Get.snackbar('مشاركة', 'تم اختيار $label للمشاركة');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _restoreFromBackup() {
    Get.dialog(
      AlertDialog(
        title: const Text('استعادة من نسخة احتياطية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل تريد استعادة البيانات من آخر نسخة احتياطية؟'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم استبدال جميع البيانات الحالية',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم بنجاح',
                'تم استعادة البيانات من النسخة الاحتياطية',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('استعادة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _importFromFile() {
    Get.snackbar(
      'استيراد ملف',
      'سيتم فتح مستعرض الملفات لاختيار النسخة الاحتياطية',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _showEncryptionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تشفير النسخ الاحتياطية'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أدخل كلمة مرور لتشفير النسخ الاحتياطية:'),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم التفعيل',
                'تم تفعيل تشفير النسخ الاحتياطية',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }

  void _deleteAllBackups() {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف جميع النسخ الاحتياطية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل تريد حذف جميع النسخ الاحتياطية المحفوظة؟'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'هذا الإجراء لا يمكن التراجع عنه',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم الحذف',
                'تم حذف جميع النسخ الاحتياطية',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewBackupHistory() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
            'سجل النسخ الاحتياطية'.text.xl.bold.make(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildBackupHistoryItem(
                    'نسخة احتياطية تلقائية',
                    'اليوم 2:30 مساءً',
                    '2.5 ميجابايت',
                    Icons.backup,
                    Colors.green,
                    true,
                  ),
                  _buildBackupHistoryItem(
                    'نسخة احتياطية يدوية',
                    'أمس 8:15 صباحاً',
                    '2.3 ميجابايت',
                    Icons.save,
                    Colors.blue,
                    false,
                  ),
                  _buildBackupHistoryItem(
                    'نسخة احتياطية تلقائية',
                    'منذ 3 أيام',
                    '2.4 ميجابايت',
                    Icons.backup,
                    Colors.green,
                    false,
                  ),
                  _buildBackupHistoryItem(
                    'نسخة احتياطية تلقائية',
                    'منذ أسبوع',
                    '2.2 ميجابايت',
                    Icons.backup,
                    Colors.green,
                    false,
                  ),
                  _buildBackupHistoryItem(
                    'نسخة احتياطية يدوية',
                    'منذ أسبوعين',
                    '2.1 ميجابايت',
                    Icons.save,
                    Colors.blue,
                    false,
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
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupHistoryItem(
    String title,
    String date,
    String size,
    IconData icon,
    Color color,
    bool isLatest,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title)),
            if (isLatest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'الأحدث',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        subtitle: Text('$date • $size'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'restore':
                Get.back();
                _restoreFromBackup();
                break;
              case 'delete':
                Get.snackbar('تم الحذف', 'تم حذف النسخة الاحتياطية');
                break;
              case 'share':
                Get.snackbar('مشاركة', 'تم مشاركة النسخة الاحتياطية');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, size: 20),
                  SizedBox(width: 8),
                  Text('استعادة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 8),
                  Text('مشاركة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('مساعدة النسخ الاحتياطي'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ما هو النسخ الاحتياطي؟',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'النسخ الاحتياطي يحفظ جميع إعداداتك وبياناتك في ملف آمن يمكن استعادته لاحقاً.',
              ),
              SizedBox(height: 16),
              Text(
                'ما يتم حفظه:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• جميع الإعدادات والتفضيلات'),
              Text('• العلامات المرجعية'),
              Text('• سجل القراءة'),
              Text('• الملاحظات الشخصية'),
              Text('• إعدادات المظهر'),
              SizedBox(height: 16),
              Text(
                'نصائح مهمة:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• قم بإنشاء نسخة احتياطية بانتظام'),
              Text('• احتفظ بنسخة في مكان آمن'),
              Text('• تأكد من كلمة مرور التشفير'),
              Text('• اختبر الاستعادة من وقت لآخر'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('فهمت'))
        ],
      ),
    );
  }
}
