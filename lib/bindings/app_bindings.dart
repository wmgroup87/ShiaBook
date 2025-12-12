import 'package:get/get.dart';
import 'package:shia_book/controllers/home_controller.dart';
import 'package:shia_book/controllers/islamic_events_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IslamicEventsController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
