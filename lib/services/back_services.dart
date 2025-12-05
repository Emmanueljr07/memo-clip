import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:memo_clip/constants/constants.dart';
import 'package:workmanager/workmanager.dart';

const platform = MethodChannel(Constants.plateformSTRING);

Future<void> initializeServie() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  // Background activity
  debugPrint("Background activity is running");
  onListenAlarmChannel();
  // Keep the service running
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

void onListenAlarmChannel() {
  debugPrint("Background Listening...");
  // Set the handler to receive messages from Java
  platform.setMethodCallHandler((call) async {
    // Check method name
    switch (call.method) {
      case 'onAlarmTriggered':
        debugPrint(">>> Alarm Method Called In Background");
        try {
          final data = Map<String, dynamic>.from(call.arguments);

          final String videoUrl = data['videoUrl'] ?? '';
          final String title = data['title'] ?? '';
          final int alarmId = data['alarmId'] as int;

          debugPrint(
            ">>> Parsed - ID: $alarmId, Title: $title, URL: $videoUrl",
          );
          // Extract the arguments passed from java

          // Register Background Task
          Workmanager().registerOneOffTask(
            "Alarm$alarmId",
            "showVideo",
            inputData: {
              'videoUrl': videoUrl,
              'title': title,
              'alarmId': alarmId,
            },
            initialDelay: const Duration(seconds: 1),
            constraints: Constraints(
              networkType: NetworkType.notRequired,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresDeviceIdle: false,
              requiresStorageNotLow: false,
            ),
          );
        } catch (e) {
          debugPrint(">>> Background ERROR in _handleAlarmTriggered: $e");
        }
        break;
      default:
        debugPrint('Unknown method: ${call.method}');
    }
  });
}
