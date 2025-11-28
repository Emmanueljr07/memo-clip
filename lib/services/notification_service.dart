import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:memo_clip/main.dart';
import 'package:memo_clip/screens/pip_player/pip_video_player.dart';

class NotificationService {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      null, //'resource://drawable/res_app_icon',//
      [
        NotificationChannel(
          channelKey: 'memoclip',
          channelName: 'Video Alarm',
          channelDescription: 'Channel for video alarms',
          importance: NotificationImportance.Max,
          defaultColor: Colors.deepPurple,
          ledColor: Colors.white,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications().getInitialNotificationAction(
      removeFromActionEvents: false,
    );
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort(
      'Notification action port in main isolate',
    )..listen((silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
      receivePort!.sendPort,
      'notification_action_port',
    );
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    // BuildContext context = MyApp.navigatorKey.currentContext!;

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // this process is only necessary when you need to redirect the user
    // to a new page or use a valid context, since parallel isolates do not
    // have valid context, so you need redirect the execution to main isolate
    if (receivePort == null) {
      debugPrint(
        'onActionReceivedMethod was called inside a parallel dart isolate.',
      );
      SendPort? sendPort = IsolateNameServer.lookupPortByName(
        'notification_action_port',
      );

      if (sendPort != null) {
        debugPrint('Redirecting the execution to main isolate process.');
        sendPort.send(receivedAction);
        return;
      }
    }

    return onActionReceivedImplementationMethod(receivedAction);
  }

  static Future<void> onActionReceivedImplementationMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint("Implementation Method: ");

    final title = receivedAction.payload?['title'] ?? '';
    final videoUrl = receivedAction.payload?['videoUrl'] ?? '';
    final alarmId = receivedAction.payload?['alarmId'] ?? '';
    debugPrint("Title: $title");

    if (receivedAction.buttonKeyPressed == 'PLAY' ||
        receivedAction.payload?['action'] == 'play_video') {
      // Play video when notification is tapped
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (ctx) =>
              PipVideoPlayer(title: title, videoUrl: videoUrl, id: alarmId),
        ),
      );
    }
  }

  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Get Notified!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/logo.jpg',
                      height: MediaQuery.of(context).size.height * 0.3,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Allow Awesome Notifications to send you beautiful notifications!',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Deny',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                userAuthorized = true;
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Allow',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  static Future<void> createNewNotification({
    required String videoUrl,
    required String title,
    required int notId,
    required String thumbnailUrl,
  }) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notId,
        channelKey: 'memoclip',
        title: '🎬 Time to Watch Video!',
        body: "Tap to open and play your scheduled video",
        bigPicture: thumbnailUrl,
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          'action': 'play_video',
          'videoUrl': videoUrl,
          'title': title,
          'notId': notId.toString(),
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'PLAY',
          label: 'Play Now',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
        ),
      ],
    );
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
