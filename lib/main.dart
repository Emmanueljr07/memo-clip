import 'package:flutter/material.dart';
import 'package:memo_clip/splash_screen.dart';
import 'package:memo_clip/styles/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memo-Clip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
          onSurface: AppColors.textPrimary,
        ),
      ),
      // darkTheme: ThemeData(
      //   colorScheme: ColorScheme.dark(
      //     primary: AppColors.darkPrimary,
      //     secondary: AppColors.darkSecondary,
      //     surface: AppColors.darkBackground,
      //     onSurface: AppColors.darkTextPrimary,
      //   ),
      // ),
      home: const SplashScreen(),
    );
  }
}
