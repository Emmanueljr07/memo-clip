import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_clip/services/notification_service.dart';
import 'package:memo_clip/splash_screen.dart';
import 'package:memo_clip/styles/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeLocalNotifications();
  NotificationService.startListeningNotificationEvents();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // The navigator key is necessary to navigate using static methods
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
    );
  }
}
