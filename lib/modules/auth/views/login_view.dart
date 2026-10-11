import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/sun_header.dart';
import '../controllers/auth_controller.dart';
import '../controllers/validators.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 320,
              child: SunHeader(subtitle: AppStrings.tagline),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 250, 20, 32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.softShadow,
                ),
                child: Form(
                  key: controller.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.welcomeBack,
                        style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.loginSubtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: controller.loginEmailCtrl,
                        label: AppStrings.email,
                        icon: AppIcons.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => CustomTextField(
                          controller: controller.loginPasswordCtrl,
                          label: AppStrings.password,
                          icon: AppIcons.lock,
                          obscureText: controller.hideLoginPassword.value,
                          textInputAction: TextInputAction.done,
                          validator: Validators.password,
                          suffix: IconButton(
                            onPressed: controller.toggleLoginPassword,
                            icon: Icon(
                              controller.hideLoginPassword.value
                                  ? AppIcons.hidden
                                  : AppIcons.visible,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Obx(
                        () => CustomButton(
                          label: AppStrings.login,
                          icon: AppIcons.sun,
                          isLoading: controller.isLoading.value,
                          onPressed: controller.login,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () => Get.toNamed(Routes.signup),
                          child: Text.rich(
                            TextSpan(
                              text: AppStrings.noAccount,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                              children: [
                                TextSpan(
                                  text: AppStrings.signUp,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
