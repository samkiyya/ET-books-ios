import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const color1 = Color(0xFF6A331E); // Replace with your primary color
  static const color2 = Color(0xFFA47A4A); // Accent color
  static const color3 = Color(0xFFE4DDD5); // Background color
  static const color4 = Color(0xFF040404); // Default text color
  static const color5 = Color(0xFF5A5535); // Error color
  static const color6 = Color(0xFFC4AA89);
}

// Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.color3,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: AppColors.color3,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16.0,
    color: AppColors.color3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14.0,
    color: AppColors.color5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

// Padding & Margins


