import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/settings_controller.dart';
import 'package:velocity_x/velocity_x.dart';

class NotificationSettingsView extends GetView<SettingsController> {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'إعدادات الإشعارات'.text.xl.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () => _testNotification(),
            tooltip: 'اختبار الإشعار',
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // General Notifications
              _buildSection(
                title: 'الإشعارات العامة',
                icon: Icons.notifications,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('تفعيل الإشعارات'),
                      subtitle: const Text('السماح للتطبيق بإرسال الإشعارات'),
                      value: controller.settings.value.notificationsEnabled,
                      onChanged: controller.updateNotifications,
                      secondary: Icon(
                        controller.settings.value.notificationsEnabled
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: controller.settings.value.notificationsEnabled
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                    ),
                    if (!controller.settings.value.notificationsEnabled)
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
                            const Icon(Icons.warning,
                                color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تم إيقاف جميع الإشعارات. لن تتلقى أي تنبيهات.',
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
              ),

              const SizedBox(height: 16),

              // Prayer Notifications
              _buildSection(
                title: 'إشعارات الصلاة',
                icon: Icons.access_time,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('تذكير أوقات الصلاة'),
                      subtitle: const Text('إشعار عند دخول وقت كل صلاة'),
                      value: controller.settings.value.prayerReminders,
                      onChanged: controller.settings.value.notificationsEnabled
                          ? controller.updatePrayerReminders
                          : null,
                      secondary: Icon(
                        Icons.schedule,
                        color: controller.settings.value.prayerReminders
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Event Notifications
              _buildSection(
                title: 'إشعارات المناسبات',
                icon: Icons.event,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('تذكير المناسبات الإسلامية'),
                      subtitle: const Text('إشعار بالمناسبات والأحداث المهمة'),
                      value: controller.settings.value.eventReminders,
                      onChanged: controller.settings.value.notificationsEnabled
                          ? controller.updateEventReminders
                          : null,
                      secondary: Icon(
                        Icons.calendar_today,
                        color: controller.settings.value.eventReminders
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _resetNotificationSettings(),
                      icon: const Icon(Icons.refresh, color: Colors.red),
                      label: const Text(
                        'إعادة تعيين',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _testNotification(),
                      icon: const Icon(Icons.notifications),
                      label: const Text('اختبار الإشعار'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
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

  void _testNotification() {
    Get.snackbar(
      'إشعار تجريبي',
      'هذا إشعار تجريبي للتأكد من عمل الإشعارات بشكل صحيح',
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.notifications, color: Colors.white),
    );
  }

  void _resetNotificationSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('إعادة تعيين إعدادات الإشعارات'),
        content: const Text(
          'هل تريد إعادة تعيين جميع إعدادات الإشعارات إلى القيم الافتراضية؟',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              controller.updateNotifications(true);
              controller.updatePrayerReminders(true);
              controller.updateEventReminders(true);
              Get.back();
              Get.snackbar(
                'تم بنجاح',
                'تم إعادة تعيين إعدادات الإشعارات',
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
