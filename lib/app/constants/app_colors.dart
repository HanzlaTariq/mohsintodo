import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF7A45);
  static const Color secondary = Color(0xFFFF5E78);
  static const Color background = Color(0xFFFFF7ED);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color sunYellow = Color(0xFFFFB347);
  static const Color textDark = Color(0xFF3B2A20);
  static const Color textMuted = Color(0xFF9A8578);
  static const Color border = Color(0xFFF3E3D3);

  static const Color low = Color(0xFF34D399);
  static const Color medium = Color(0xFFFBBF24);
  static const Color high = Color(0xFFEF4444);
  static const Color success = Color(0xFF34D399);
  static const Color overdue = Color(0xFFEF4444);

  static const LinearGradient sunGradient = LinearGradient(
    colors: [sunYellow, primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x26FF7A45),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary: secondary,
    onSecondary: Colors.white,
    error: high,
    onError: Colors.white,
    surface: surface,
    onSurface: textDark,
  );

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return high;
      case 'Medium':
        return medium;
      default:
        return low;
    }
  }
}
