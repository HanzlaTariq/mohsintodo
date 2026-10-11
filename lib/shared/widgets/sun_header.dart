import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/constants/app_colors.dart';
import '../../app/constants/app_icons.dart';
import '../../app/constants/app_strings.dart';

/// Sun-gradient header shared by the Login and Sign-Up screens.
class SunHeader extends StatelessWidget {
  const SunHeader({
    super.key,
    required this.subtitle,
    this.height = 320,
    this.showBack = false,
  });

  final String subtitle;
  final double height;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.sunGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
            ),
          ),
          Positioned(top: -40, right: -30, child: _bubble(170, 0.14)),
          Positioned(bottom: 90, left: -50, child: _bubble(140, 0.10)),
          Positioned(top: 90, left: 30, child: _bubble(36, 0.18)),
          SafeArea(
            child: Stack(
              children: [
                if (showBack)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(AppIcons.back, color: Colors.white),
                      ),
                    ),
                  ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(AppIcons.sun, size: 44, color: AppColors.primary),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.appName,
                          style: GoogleFonts.nunito(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
