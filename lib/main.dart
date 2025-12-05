import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_clip/provider/theme_provider.dart';
import 'package:memo_clip/services/notification_service.dart';
import 'package:memo_clip/splash_screen.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  log('MainDart Dispatcher called');
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "showVideo":
        try {
          final String videoUrl = inputData?['videoUrl'] ?? '';
          final String title = inputData?['title'] ?? '';
          final int alarmId = inputData?['alarmId'] ?? 0;
          debugPrint(">>> Manager Task - ID: $alarmId, URL: $videoUrl");

          // Create a high-priority notification to wake the app
          await NotificationService.createNewNotification(
            videoUrl: videoUrl,
            title: title,
            notId: alarmId,
            thumbnailUrl:
                'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
          );
        } catch (e) {
          debugPrint(">>> ERROR in background task: $e");
        }
        break;
      case 'createVideo':
        try {
          // _onListenAlarmChannel();
        } catch (e) {
          debugPrint("Error While Listening to Alarm channel");
        }

        break;
      default:
        break;
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize WorkManager
  Workmanager().initialize(callbackDispatcher);

  // Initialize Background Service
  // await initializeServie();

  // Initialize Awesome Notifications
  await NotificationService.initializeLocalNotifications();
  await NotificationService.initializeIsolateReceivePort();

  NotificationService.startListeningNotificationEvents();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // The navigator key is necessary to navigate using static methods
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTheme = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memo-Clip',
      theme: userTheme,
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
    );
  }
}
