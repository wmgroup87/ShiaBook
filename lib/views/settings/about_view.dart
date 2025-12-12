import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'حول التطبيق'.text.xl.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معلومات التطبيق الرئيسية
            _buildAppInfoCard(),

            const SizedBox(height: 20),

            // معلومات الإصدار
            _buildVersionSection(),

            const SizedBox(height: 16),

            // فريق التطوير
            _buildDeveloperSection(),

            const SizedBox(height: 16),

            // الميزات
            _buildFeaturesSection(),

            const SizedBox(height: 16),

            // الشكر والتقدير
            _buildCreditsSection(),

            const SizedBox(height: 16),

            // الروابط المهمة
            _buildLinksSection(),

            const SizedBox(height: 20),

            // أزرار الإجراءات
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.menu_book,
                  size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            'الكتب الشيعية'.text.xl2.bold.center.make(),
            const SizedBox(height: 8),
            Text(
              'تطبيق شامل للكتب والمراجع الشيعية',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionSection() {
    return _buildSection(
      title: 'معلومات الإصدار',
      icon: Icons.info,
      child: Column(
        children: [
          _buildInfoRow('رقم الإصدار', '1.0.0'),
          _buildInfoRow('رقم البناء', '100'),
          _buildInfoRow('تاريخ الإصدار', '15 رجب 1445 هـ'),
          _buildInfoRow('حجم التطبيق', '25.6 ميجابايت'),
          _buildInfoRow('الحد الأدنى لنظام التشغيل', 'Android 6.0 / iOS 12.0'),
          _buildInfoRow('آخر تحديث', 'منذ 3 أيام'),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return _buildSection(
      title: 'فريق التطوير',
      icon: Icons.people,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            title: const Text('فريق تطوير التطبيقات الإسلامية'),
            subtitle: const Text('المطور الرئيسي'),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: const Icon(Icons.design_services, color: Colors.blue),
            ),
            title: const Text('فريق التصميم والواجهات'),
            subtitle: const Text('تصميم واجهة المستخدم'),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.2),
              child: const Icon(Icons.book, color: Colors.green),
            ),
            title: const Text('لجنة المراجعة العلمية'),
            subtitle: const Text('مراجعة المحتوى والنصوص'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return _buildSection(
      title: 'ميزات التطبيق',
      icon: Icons.star,
      child: Column(
        children: [
          _buildFeatureItem(
            Icons.library_books,
            'مكتبة شاملة',
            'مجموعة واسعة من الكتب والمراجع الشيعية',
            Colors.blue,
          ),
          _buildFeatureItem(
            Icons.search,
            'بحث متقدم',
            'إمكانية البحث في جميع النصوص والكتب',
            Colors.green,
          ),
          _buildFeatureItem(
            Icons.bookmark,
            'العلامات المرجعية',
            'حفظ الصفحات والنصوص المهمة',
            Colors.orange,
          ),
          _buildFeatureItem(
            Icons.note_add,
            'الملاحظات الشخصية',
            'إضافة ملاحظات وتعليقات على النصوص',
            Colors.purple,
          ),
          _buildFeatureItem(
            Icons.schedule,
            'أوقات الصلاة',
            'عرض أوقات الصلاة والتذكير بها',
            Colors.teal,
          ),
          _buildFeatureItem(
            Icons.event,
            'التقويم الإسلامي',
            'عرض المناسبات والأحداث الإسلامية',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsSection() {
    return _buildSection(
      title: 'الشكر والتقدير',
      icon: Icons.favorite,
      child: const Column(
        children: [
          ListTile(
            leading: Icon(Icons.mosque, color: AppColors.primary),
            title: Text('المراجع الدينية'),
            subtitle: Text('للإشراف والتوجيه العلمي'),
          ),
          ListTile(
            leading: Icon(Icons.translate, color: Colors.blue),
            title: Text('فريق الترجمة'),
            subtitle: Text('ترجمة النصوص والواجهات'),
          ),
          ListTile(
            leading: Icon(Icons.record_voice_over, color: Colors.green),
            title: Text('القراء والمنشدون'),
            subtitle: Text('التسجيلات الصوتية'),
          ),
          ListTile(
            leading: Icon(Icons.volunteer_activism, color: Colors.orange),
            title: Text('المتطوعون'),
            subtitle: Text('المساهمة في تطوير المحتوى'),
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: Colors.purple),
            title: Text('المستخدمون'),
            subtitle: Text('الملاحظات والاقتراحات القيمة'),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection() {
    return _buildSection(
      title: 'روابط مهمة',
      icon: Icons.link,
      child: Column(
        children: [
          _buildLinkItem(
            Icons.web,
            'الموقع الرسمي',
            'www.shiabooks.com',
            () => _openLink('https://www.shiabooks.com'),
          ),
          _buildLinkItem(
            Icons.email,
            'البريد الإلكتروني',
            'info@shiabooks.com',
            () => _sendEmail('info@shiabooks.com'),
          ),
          _buildLinkItem(
            Icons.phone,
            'الدعم الفني',
            '+966 50 123 4567',
            () => _callSupport('+966501234567'),
          ),
          _buildLinkItem(
            Icons.telegram,
            'قناة التليجرام',
            '@shiabooks',
            () => _openLink('https://t.me/shiabooks'),
          ),
          _buildLinkItem(
            Icons.facebook,
            'صفحة الفيسبوك',
            'ShiaBooksApp',
            () => _openLink('https://facebook.com/ShiaBooksApp'),
          ),
          _buildLinkItem(
            Icons.code,
            'GitHub',
            'المصدر المفتوح',
            () => _openLink('https://github.com/shiabooks'),
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
              child: ElevatedButton.icon(
                onPressed: () => _checkForUpdates(),
                icon: const Icon(Icons.system_update),
                label: const Text('البحث عن تحديثات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareApp(),
                icon: const Icon(Icons.share),
                label: const Text('مشاركة التطبيق'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showLicense(),
                icon: const Icon(Icons.description),
                label: const Text('الترخيص والشروط'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showPrivacyPolicy(),
                icon: const Icon(Icons.privacy_tip),
                label: const Text('سياسة الخصوصية'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'صُنع بـ ❤️ لخدمة المجتمع الشيعي',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '© 2024 جميع الحقوق محفوظة',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
      onTap: onTap,
      dense: true,
    );
  }

  void _openLink(String url) {
    Get.snackbar(
      'فتح الرابط',
      'سيتم فتح $url في المتصفح',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _sendEmail(String email) {
    Get.snackbar(
      'إرسال بريد إلكتروني',
      'سيتم فتح تطبيق البريد الإلكتروني',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _callSupport(String phone) {
    Get.snackbar(
      'الاتصال بالدعم',
      'سيتم الاتصال بـ $phone',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void _checkForUpdates() {
    Get.dialog(
      const AlertDialog(
        title: Text('البحث عن تحديثات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري البحث عن تحديثات...'),
          ],
        ),
      ),
    );

    // محاكاة البحث عن تحديثات
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
      Get.snackbar(
        'لا توجد تحديثات',
        'أنت تستخدم أحدث إصدار من التطبيق',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }

  void _shareApp() {
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
            'مشاركة التطبيق'.text.xl.bold.make(),
            const SizedBox(height: 20),
            const Text(
              'شارك تطبيق الكتب الشيعية مع الأصدقاء والعائلة',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'تطبيق الكتب الشيعية - مكتبة شاملة للكتب والمراجع الشيعية\n\nحمل التطبيق من:\nhttps://play.google.com/store/apps/details?id=com.shiabooks',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.snackbar('تم النسخ', 'تم نسخ رابط التطبيق');
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('نسخ الرابط'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.snackbar('مشاركة', 'تم فتح قائمة المشاركة');
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLicense() {
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
            'الترخيص وشروط الاستخدام'.text.xl.bold.make(),
            const SizedBox(height: 20),
            const Expanded(
              child: SingleChildScrollView(
                child: Text('''
شروط الاستخدام والترخيص

1. الاستخدام المسموح:
يُسمح باستخدام هذا التطبيق للأغراض التعليمية والدينية الشخصية.

2. حقوق الطبع والنشر:
جميع النصوص والكتب محمية بحقوق الطبع والنشر لأصحابها.

3. المسؤولية:
المطورون غير مسؤولين عن أي أضرار قد تنتج عن استخدام التطبيق.

4. التحديثات:
يحق للمطورين تحديث شروط الاستخدام في أي وقت.

5. الخصوصية:
نحن نحترم خصوصيتك ولا نجمع بيانات شخصية بدون إذنك.

6. الاستخدام التجاري:
يُمنع الاستخدام التجاري للتطبيق أو محتوياته بدون إذن مكتوب.

7. التوزيع:
يُمنع إعادة توزيع التطبيق أو أجزاء منه بدون إذن.

8. الدعم:
نقدم الدعم الفني حسب الإمكانيات المتاحة.

9. إنهاء الخدمة:
يحق لنا إنهاء الخدمة أو تعليقها في أي وقت.

10. القانون المطبق:
تخضع هذه الشروط للقوانين المحلية.

آخر تحديث: 15 رجب 1445 هـ
                  ''', style: TextStyle(fontSize: 12, height: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('موافق'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
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
            'سياسة الخصوصية'.text.xl.bold.make(),
            const SizedBox(height: 20),
            const Expanded(
              child: SingleChildScrollView(
                child: Text('''
سياسة الخصوصية

نحن في تطبيق الكتب الشيعية نقدر خصوصيتك ونلتزم بحمايتها.

البيانات التي نجمعها:
• إعدادات التطبيق والتفضيلات
• سجل القراءة والعلامات المرجعية
• الملاحظات الشخصية
• معلومات الجهاز الأساسية

كيف نستخدم البيانات:
• تحسين تجربة الاستخدام
• حفظ التقدم والإعدادات
• تقديم المحتوى المناسب
• إصلاح الأخطاء والمشاكل

مشاركة البيانات:
• لا نشارك بياناتك الشخصية مع أطراف ثالثة
• قد نستخدم خدمات تحليلية مجهولة الهوية
• البيانات المحلية تبقى على جهازك

حماية البيانات:
• تشفير البيانات الحساسة
• تخزين آمن للمعلومات
• عدم الوصول غير المصرح به

حقوقك:
• الوصول إلى بياناتك
• تعديل أو حذف البيانات
• إيقاف جمع البيانات
• تصدير بياناتك

ملفات تعريف الارتباط:
• نستخدم ملفات تعريف الارتباط لتحسين الأداء
• يمكنك إيقافها من إعدادات المتصفح

التحديثات:
• قد نحدث سياسة الخصوصية من وقت لآخر
• سنخطرك بأي تغييرات مهمة

الاتصال بنا:
إذا كان لديك أسئلة حول الخصوصية، تواصل معنا على:
privacy@shiabooks.com

آخر تحديث: 15 رجب 1445 هـ
                  ''', style: TextStyle(fontSize: 12, height: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('فهمت'),
            ),
          ],
        ),
      ),
    );
  }
}
