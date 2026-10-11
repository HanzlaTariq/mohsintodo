import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/signup_view.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/tasks/views/add_edit_task_view.dart';
import '../../modules/tasks/views/task_details_view.dart';
import 'app_routes.dart';

/// Auth guard: unauthenticated users are always sent to the login screen.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
}

class AppPages {
  AppPages._();

  /// Initial route depends on the persisted Firebase session.
  static String get initial =>
      FirebaseAuth.instance.currentUser == null ? Routes.login : Routes.home;

  static final List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: Routes.login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage<dynamic>(
      name: Routes.signup,
      page: () => const SignupView(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage<dynamic>(
      name: Routes.home,
      page: () => const HomeView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage<dynamic>(
      name: Routes.addEditTask,
      page: () => const AddEditTaskView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage<dynamic>(
      name: Routes.taskDetails,
      page: () => const TaskDetailsView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
  ];
}
