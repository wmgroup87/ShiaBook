import 'package:get/get.dart';
import 'package:shia_book/models/menu_item.dart';

class HomeController extends GetxController {
  final RxList<MenuItem> menuItems = <MenuItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMenuItems();
  }

  void _loadMenuItems() {
    menuItems.value = [
      MenuItem(
        title: 'القرآن الكريم',
        icon: 'assets/icons/quran.svg',
        description: 'القرآن الكريم كاملاً مع التفسير',
      ),
      MenuItem(
        title: 'الأدعية',
        icon: 'assets/icons/dua.svg',
        description: 'مجموعة من الأدعية المأثورة',
      ),
      MenuItem(
        title: 'الزيارات',
        icon: 'assets/icons/karbala.svg',
        description: 'زيارات الأئمة والأولياء',
      ),
      MenuItem(
        title: 'المناسبات',
        icon: 'assets/icons/occasions.svg',
        description: 'المناسبات الدينية والتواريخ المهمة',
      ),
      MenuItem(
        title: 'خريطة العراق المقدس',
        icon: 'assets/icons/map.svg',
        description: 'خريطة تفاعلية للأماكن المقدسة',
      ),
      MenuItem(
        title: 'الإعدادات',
        icon: 'assets/icons/settings.svg',
        description: 'إعدادات التطبيق',
      ),
    ];
  }
}
