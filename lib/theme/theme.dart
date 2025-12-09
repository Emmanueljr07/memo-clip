import 'package:flutter/material.dart';
import 'package:memo_clip/styles/app_colors.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkPrimary,
    // secondary: AppColors.darkSecondary,
    secondary: const Color(0xFF102A36),
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkTextPrimary,
  ),
);
