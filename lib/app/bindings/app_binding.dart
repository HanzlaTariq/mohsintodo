import 'package:get/get.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/task_service.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/tasks/controllers/task_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<TaskService>(TaskService(), permanent: true);

    // Controllers
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<TaskController>(() => TaskController(), fenix: true);
  }
}
