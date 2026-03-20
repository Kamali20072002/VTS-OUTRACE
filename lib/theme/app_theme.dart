import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color purple = Color(0xFF6C5CE7);
  static const Color purpleLight = Color(0xFF8B7CF8);
  static const Color purpleSoft = Color(0xFFEEF0FF);

  // Dark surfaces
  static const Color dark = Color(0xFF1C1C1E);
  static const Color dark2 = Color(0xFF2C2C2E);
  static const Color dark3 = Color(0xFF3A3A3C);

  // Backgrounds
  static const Color bg = Color(0xFFF2F2F7);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic
  static const Color green = Color(0xFF34C759);
  static const Color greenSoft = Color(0xFFE9F8EE);
  static const Color red = Color(0xFFFF3B30);
  static const Color redSoft = Color(0xFFFFE9E9);
  static const Color amber = Color(0xFFFF9500);

  // Text
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textTertiary = Color(0xFFAEAEB2);

  // Border
  static const Color border = Color(0xFFE5E5EA);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.purple,
        surface: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.dark),
      ),
    );
  }
}