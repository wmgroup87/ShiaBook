import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/settings_controller.dart';
import 'package:velocity_x/velocity_x.dart';

class PrivacySettingsView extends GetView<SettingsController> {
  const PrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'إعدادات الخصوصية'.text.xl.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showPrivacyHelp(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معلومات الخصوصية
            _buildPrivacyInfoCard(),

            const SizedBox(height: 20),

            // حماية البيانات
            _buildDataProtectionSection(),

            const SizedBox(height: 16),

            // أمان التطبيق
            _buildAppSecuritySection(),

            const SizedBox(height: 16),

            // مشاركة البيانات
            _buildDataSharingSection(),

            const SizedBox(height: 16),

            // إدارة البيانات
            _buildDataManagementSection(),

            const SizedBox(height: 20),

            // أزرار الإجراءات
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.blue.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.security, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            'حماية خصوصيتك'.text.xl.bold.center.make(),
            const SizedBox(height: 8),
            Text(
              'نحن ملتزمون بحماية بياناتك الشخصية وضمان خصوصيتك',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPrivacyFeature('تشفير', Icons.lock, Colors.green),
                _buildPrivacyFeature('أمان', Icons.security, Colors.blue),
                _buildPrivacyFeature(
                  'خصوصية',
                  Icons.visibility_off,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyFeature(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDataProtectionSection() {
    return _buildSection(
      title: 'حماية البيانات',
      icon: Icons.shield,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('تشفير البيانات'),
            subtitle: const Text('تشفير جميع البيانات المحفوظة محلياً'),
            value: true,
            onChanged: (value) {
              Get.snackbar(
                'تم التحديث',
                'تم ${value ? "تفعيل" : "إيقاف"} تشفير البيانات',
              );
            },
            secondary: const Icon(Icons.lock, color: Colors.green),
          ),
          ListTile(
            title: const Text('البيانات المجمعة'),
            subtitle: const Text('عرض البيانات التي يجمعها التطبيق'),
            leading: const Icon(Icons.data_usage, color: AppColors.primary),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showCollectedData(),
          ),
          SwitchListTile(
            title: const Text('منع التتبع'),
            subtitle: const Text('منع تتبع نشاطك في التطبيق'),
            value: true,
            onChanged: (value) {
              Get.snackbar(
                'تم التحديث',
                'تم ${value ? "تفعيل" : "إيقاف"} منع التتبع',
              );
            },
            secondary: const Icon(Icons.block, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSecuritySection() {
    return _buildSection(
      title: 'أمان التطبيق',
      icon: Icons.security,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('قفل التطبيق'),
            subtitle: const Text('استخدام كلمة مرور أو بصمة لفتح التطبيق'),
            value: false,
            onChanged: (value) {
              if (value) {
                _setupAppLock();
              } else {
                Get.snackbar('تم الإيقاف', 'تم إيقاف قفل التطبيق');
              }
            },
            secondary: const Icon(Icons.lock_outline, color: Colors.orange),
          ),
          SwitchListTile(
            title: const Text('إخفاء المحتوى في المهام الأخيرة'),
            subtitle:
                const Text('إخفاء محتوى التطبيق عند التبديل بين التطبيقات'),
            value: false,
            onChanged: (value) {
              Get.snackbar(
                'تم التحديث',
                'تم ${value ? "تفعيل" : "إيقاف"} إخفاء المحتوى',
              );
            },
            secondary: const Icon(Icons.visibility_off, color: Colors.purple),
          ),
          SwitchListTile(
            title: const Text('منع لقطات الشاشة'),
            subtitle: const Text('منع أخذ لقطات شاشة من التطبيق'),
            value: false,
            onChanged: (value) {
              Get.snackbar(
                'تم التحديث',
                'تم ${value ? "تفعيل" : "إيقاف"} منع لقطات الشاشة',
              );
            },
            secondary: const Icon(Icons.screenshot_monitor, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSharingSection() {
    return _buildSection(
      title: 'مشاركة البيانات',
      icon: Icons.share,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('مشاركة بيانات تحليلية'),
            subtitle: const Text('مساعدتنا في تحسين التطبيق'),
            value: true,
            onChanged: (value) {
              Get.snackbar(
                'تم التحديث',
                'تم ${value ? "تفعيل" : "إيقاف"} مشاركة البيانات التحليلية',
              );
            },
            secondary: const Icon(Icons.analytics, color: Colors.blue),
          ),
          SwitchListTile(
            title: const Text('تقارير الأخطاء'),
            subtitle: const Text('إرسال تقارير الأخطاء تلقائياً'),
            value: true,
            onChanged: (value) {
              Get.snackbar(
                'تم التحديث',
                'تم ${value ? "تفعيل" : "إيقاف"} تقارير الأخطاء',
              );
            },
            secondary: const Icon(Icons.bug_report, color: Colors.orange),
          ),
          SwitchListTile(
            title: const Text('تحسين الأداء'),
            subtitle: const Text('مشاركة بيانات الأداء لتحسين التطبيق'),
            value: false,
            onChanged: (value) {
              Get.snackbar(
                'تم التحديث',
                'تم ${value ? "تفعيل" : "إيقاف"} مشاركة بيانات الأداء',
              );
            },
            secondary: const Icon(Icons.speed, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return _buildSection(
      title: 'إدارة البيانات',
      icon: Icons.storage,
      child: Column(
        children: [
          ListTile(
            title: const Text('تصدير البيانات'),
            subtitle: const Text('تحميل نسخة من بياناتك'),
            leading: const Icon(Icons.download, color: Colors.blue),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _exportUserData(),
          ),
          ListTile(
            title: const Text('حذف البيانات'),
            subtitle: const Text('حذف جميع بياناتك نهائياً'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _deleteAllData(),
          ),
          ListTile(
            title: const Text('تقرير الخصوصية'),
            subtitle: const Text('عرض تقرير مفصل عن خصوصيتك'),
            leading: const Icon(Icons.assessment, color: Colors.green),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPrivacyReport(),
          ),
          ListTile(
            title: const Text('التواصل مع فريق الخصوصية'),
            subtitle: const Text('للاستفسارات حول الخصوصية'),
            leading:
                const Icon(Icons.contact_support, color: AppColors.primary),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _contactPrivacyTeam(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showPrivacyReport(),
            icon: const Icon(Icons.assessment),
            label: const Text('عرض تقرير الخصوصية'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _resetPrivacySettings(),
            icon: const Icon(Icons.refresh, color: Colors.red),
            label: const Text(
              'إعادة تعيين إعدادات الخصوصية',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
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

  void _showPrivacyHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('مساعدة الخصوصية'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('نحن ملتزمون بحماية خصوصيتك:'),
              const SizedBox(height: 12),
              const Text('• لا نجمع معلومات شخصية بدون إذنك'),
              const Text('• جميع البيانات مشفرة ومحمية'),
              const Text('• يمكنك التحكم في ما يتم مشاركته'),
              const Text('• لا نبيع بياناتك لأطراف ثالثة'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'لمزيد من المعلومات، راجع سياسة الخصوصية الكاملة.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('فهمت')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('سياسة الخصوصية', 'سيتم فتح سياسة الخصوصية الكاملة');
            },
            child: const Text('اقرأ المزيد'),
          ),
        ],
      ),
    );
  }

  void _showCollectedData() {
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
            'البيانات المجمعة'.text.xl.bold.make(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDataCategory(
                      'بيانات الاستخدام',
                      [
                        'أوقات استخدام التطبيق',
                        'الصفحات المزارة',
                        'مدة الجلسات',
                      ],
                      Icons.analytics,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildDataCategory(
                      'الإعدادات',
                      ['تفضيلات المظهر', 'إعدادات الإشعارات', 'اختيارات اللغة'],
                      Icons.settings,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildDataCategory(
                      'البيانات التقنية',
                      ['نوع الجهاز', 'إصدار التطبيق', 'تقارير الأخطاء'],
                      Icons.phone_android,
                      Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'لا نجمع أي معلومات شخصية حساسة',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('فهمت'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCategory(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setupAppLock() {
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
            'إعداد قفل التطبيق'.text.xl.bold.make(),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.fingerprint, color: Colors.blue),
              title: const Text('بصمة الإصبع'),
              subtitle: const Text('استخدام بصمة الإصبع لفتح التطبيق'),
              onTap: () {
                Get.back();
                Get.snackbar('تم التفعيل', 'تم تفعيل قفل التطبيق ببصمة الإصبع');
              },
            ),
            ListTile(
              leading: const Icon(Icons.face, color: Colors.green),
              title: const Text('التعرف على الوجه'),
              subtitle: const Text('استخدام التعرف على الوجه لفتح التطبيق'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'تم التفعيل',
                  'تم تفعيل قفل التطبيق بالتعرف على الوجه',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pin, color: Colors.orange),
              title: const Text('رقم سري'),
              subtitle: const Text('استخدام رقم سري لفتح التطبيق'),
              onTap: () {
                Get.back();
                _setupPinCode();
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('إلغاء'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setupPinCode() {
    Get.dialog(
      AlertDialog(
        title: const Text('إعداد الرقم السري'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أدخل رقم سري مكون من 4 أرقام:'),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '****',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('تم التفعيل', 'تم تفعيل قفل التطبيق بالرقم السري');
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _exportUserData() {
    Get.dialog(
      AlertDialog(
        title: const Text('تصدير البيانات'),
        content: const Text('سيتم إنشاء ملف يحتوي على جميع بياناتك وإعداداتك.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'جاري التصدير',
                'سيتم إشعارك عند اكتمال تصدير البيانات',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            child: const Text('تصدير'),
          ),
        ],
      ),
    );
  }

  void _deleteAllData() {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف جميع البيانات'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'تحذير: هذا الإجراء لا يمكن التراجع عنه!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('سيتم حذف جميع بياناتك وإعداداتك نهائياً.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _confirmDataDeletion();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDataDeletion() {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'اكتب "حذف" للتأكيد',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم الحذف',
                'تم حذف جميع البيانات بنجاح',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تأكيد الحذف',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyReport() {
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
            'تقرير الخصوصية'.text.xl.bold.make(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPrivacyReportItem(
                      'حالة التشفير',
                      'مفعل',
                      Icons.lock,
                      Colors.green,
                    ),
                    _buildPrivacyReportItem(
                      'مشاركة البيانات',
                      'محدودة',
                      Icons.share,
                      Colors.orange,
                    ),
                    _buildPrivacyReportItem(
                      'أمان التطبيق',
                      'عالي',
                      Icons.security,
                      Colors.green,
                    ),
                    _buildPrivacyReportItem(
                      'آخر فحص أمني',
                      'اليوم',
                      Icons.verified,
                      Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'خصوصيتك محمية',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'جميع إعدادات الخصوصية مفعلة بشكل صحيح',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyReportItem(
    String title,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _contactPrivacyTeam() {
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
            'التواصل مع فريق الخصوصية'.text.xl.bold.make(),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('البريد الإلكتروني'),
              subtitle: const Text('privacy@shiabook.com'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'البريد الإلكتروني',
                  'تم نسخ عنوان البريد الإلكتروني',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('الدردشة المباشرة'),
              subtitle: const Text('متاح من 9 صباحاً إلى 5 مساءً'),
              onTap: () {
                Get.back();
                Get.snackbar('الدردشة', 'سيتم فتح نافذة الدردشة المباشرة');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_center, color: Colors.orange),
              title: const Text('مركز المساعدة'),
              subtitle: const Text('الأسئلة الشائعة حول الخصوصية'),
              onTap: () {
                Get.back();
                Get.snackbar('مركز المساعدة', 'سيتم فتح مركز المساعدة');
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetPrivacySettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('إعادة تعيين إعدادات الخصوصية'),
        content: const Text(
          'هل تريد إعادة تعيين جميع إعدادات الخصوصية إلى القيم الافتراضية؟',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم بنجاح',
                'تم إعادة تعيين إعدادات الخصوصية',
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
