import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../shared/widgets/confirm_dialog.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Forms
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  final TextEditingController loginEmailCtrl = TextEditingController();
  final TextEditingController loginPasswordCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController signupEmailCtrl = TextEditingController();
  final TextEditingController signupPasswordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxBool hideLoginPassword = true.obs;
  final RxBool hideSignupPassword = true.obs;
  final RxBool hideConfirmPassword = true.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  String get displayName {
    final String? name = user.value?.name;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final String? authName = FirebaseAuth.instance.currentUser?.displayName;
    if (authName != null && authName.trim().isNotEmpty) return authName.trim();
    return 'Friend';
  }

  String get firstName => displayName.split(' ').first;

  String get userEmail =>
      user.value?.email ?? FirebaseAuth.instance.currentUser?.email ?? '';

  String get initial => displayName.isEmpty ? '?' : displayName[0].toUpperCase();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final User? current = _authService.currentUser;
    if (current == null) return;
    try {
      user.value = await _authService.fetchProfile(current.uid) ??
          UserModel(
            uid: current.uid,
            name: current.displayName ?? 'Friend',
            email: current.email ?? '',
          );
    } catch (_) {
      user.value = UserModel(
        uid: current.uid,
        name: current.displayName ?? 'Friend',
        email: current.email ?? '',
      );
    }
  }

  void toggleLoginPassword() => hideLoginPassword.toggle();
  void toggleSignupPassword() => hideSignupPassword.toggle();
  void toggleConfirmPassword() => hideConfirmPassword.toggle();

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    try {
      user.value = await _authService.signIn(
        email: loginEmailCtrl.text.trim(),
        password: loginPasswordCtrl.text,
      );
      loginEmailCtrl.clear();
      loginPasswordCtrl.clear();
      Get.offAllNamed(Routes.home);
      AppSnack.success('Welcome back, $firstName!');
    } on FirebaseAuthException catch (e) {
      AppSnack.error(AuthService.messageFor(e));
    } catch (_) {
      AppSnack.error(AppStrings.genericError);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(signupFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    try {
      user.value = await _authService.signUp(
        name: nameCtrl.text.trim(),
        email: signupEmailCtrl.text.trim(),
        password: signupPasswordCtrl.text,
      );
      nameCtrl.clear();
      signupEmailCtrl.clear();
      signupPasswordCtrl.clear();
      confirmPasswordCtrl.clear();
      Get.offAllNamed(Routes.home);
      AppSnack.success('Account created. Let\'s get things done!');
    } on FirebaseAuthException catch (e) {
      AppSnack.error(AuthService.messageFor(e));
    } on FirebaseException catch (e) {
      AppSnack.error(e.message ?? AppStrings.genericError);
    } catch (_) {
      AppSnack.error(AppStrings.genericError);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final bool confirmed = await ConfirmDialog.show(
      title: AppStrings.logoutTitle,
      message: AppStrings.logoutMessage,
      confirmText: AppStrings.logout,
      icon: AppIcons.logout,
    );
    if (!confirmed) return;

    try {
      await _authService.signOut();
      user.value = null;
      Get.offAllNamed(Routes.login);
    } catch (_) {
      AppSnack.error('Could not log out. Please try again.');
    }
  }

  @override
  void onClose() {
    loginEmailCtrl.dispose();
    loginPasswordCtrl.dispose();
    nameCtrl.dispose();
    signupEmailCtrl.dispose();
    signupPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}
