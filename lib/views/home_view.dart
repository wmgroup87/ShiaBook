import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shia_book/constants/app_colors.dart';
import 'package:shia_book/controllers/home_controller.dart';
import 'package:shia_book/models/menu_item.dart';
import 'package:shia_book/widgets/adhan_settings_dialog.dart';
import 'package:shia_book/widgets/prayer_header_widget.dart';
import 'package:shia_book/widgets/event_notification_widget.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'الكتب الشيعية'.text.xl2.bold.make(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              showAdhanSettingsDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط أوقات الصلاة والتاريخ الهجري
          const PrayerHeaderWidget(),

          // إشعارات المناسبات
          const EventNotificationWidget(),

          // باقي المحتوى
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: controller.menuItems.length,
              itemBuilder: (context, index) {
                final item = controller.menuItems[index];
                return _buildMenuItem(item);
              },
            ),
          ),
        ],
      ).box.color(Vx.gray50).make(),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (item.title == 'القرآن الكريم') {
            Get.toNamed('/quran');
          } else if (item.title == 'الأدعية') {
            Get.toNamed('/duas');
          } else if (item.title == 'الزيارات') {
            Get.toNamed('/ziyarat');
          } else if (item.title == 'المناسبات') {
            Get.toNamed('/events');
          } else if (item.title == 'خريطة العراق المقدس') {
            Get.toNamed('/map');
          } else if (item.title == 'الإعدادات') {
            Get.toNamed('/settings');
          } else {
            Get.snackbar('قريباً', 'سيتم تفعيل ${item.title} قريباً');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(item).pOnly(bottom: 8),
            item.title.text.xl.bold.color(Colors.black87).center.make(),
          ],
        ).p8(),
      ),
    );
  }

  Widget _buildIcon(MenuItem item) {
    // استخدام أيقونات Flutter المدمجة بدلاً من SVG
    IconData iconData;
    switch (item.title) {
      case 'القرآن الكريم':
        iconData = Icons.menu_book;
        break;
      case 'الأدعية':
        iconData = Icons.favorite;
        break;
      case 'الزيارات':
        iconData = Icons.mosque;
        break;
      case 'المناسبات':
        iconData = Icons.event;
        break;
      case 'خريطة العراق المقدس':
        iconData = Icons.map;
        break;
      case 'الإعدادات':
        iconData = Icons.settings;
        break;
      default:
        iconData = Icons.apps;
    }

    return Icon(
      iconData,
      size: 50,
      color: AppColors.primary,
    );
  }
}
