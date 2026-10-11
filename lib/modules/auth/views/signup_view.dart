import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/sun_header.dart';
import '../controllers/auth_controller.dart';
import '../controllers/validators.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

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
              height: 280,
              child: SunHeader(
                subtitle: AppStrings.signUpSubtitle,
                height: 280,
                showBack: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 215, 20, 32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.softShadow,
                ),
                child: Form(
                  key: controller.signupFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.createAccount,
                        style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 22),
                      CustomTextField(
                        controller: controller.nameCtrl,
                        label: AppStrings.fullName,
                        icon: AppIcons.person,
                        textInputAction: TextInputAction.next,
                        validator: Validators.name,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: controller.signupEmailCtrl,
                        label: AppStrings.email,
                        icon: AppIcons.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => CustomTextField(
                          controller: controller.signupPasswordCtrl,
                          label: AppStrings.password,
                          icon: AppIcons.lock,
                          obscureText: controller.hideSignupPassword.value,
                          textInputAction: TextInputAction.next,
                          validator: Validators.password,
                          suffix: IconButton(
                            onPressed: controller.toggleSignupPassword,
                            icon: Icon(
                              controller.hideSignupPassword.value
                                  ? AppIcons.hidden
                                  : AppIcons.visible,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => CustomTextField(
                          controller: controller.confirmPasswordCtrl,
                          label: AppStrings.confirmPassword,
                          icon: AppIcons.lock,
                          obscureText: controller.hideConfirmPassword.value,
                          textInputAction: TextInputAction.done,
                          validator: (value) => Validators.confirmPassword(
                            value,
                            controller.signupPasswordCtrl.text,
                          ),
                          suffix: IconButton(
                            onPressed: controller.toggleConfirmPassword,
                            icon: Icon(
                              controller.hideConfirmPassword.value
                                  ? AppIcons.hidden
                                  : AppIcons.visible,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Obx(
                        () => CustomButton(
                          label: AppStrings.signUp,
                          icon: AppIcons.sparkle,
                          isLoading: controller.isLoading.value,
                          onPressed: controller.signUp,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Text.rich(
                            TextSpan(
                              text: AppStrings.haveAccount,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                              children: [
                                TextSpan(
                                  text: AppStrings.login,
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
