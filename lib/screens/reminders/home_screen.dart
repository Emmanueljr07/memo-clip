import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo_clip/models/reminder_item.dart';
import 'package:memo_clip/provider/user_reminders.dart';
import 'package:memo_clip/widgets/reminder_card.dart';
import 'package:memo_clip/widgets/show_message.dart';

const platform = MethodChannel('memoclip.app/video_alarm_channel');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<void> _remindersFuture;
  bool _hasExactAlarmPermission = false;

  @override
  void initState() {
    super.initState();
    // Listen to channel
    _onListenAlarmChannel();

    _remindersFuture = ref
        .read(userRemindersProvider.notifier)
        .fetchReminders();

    _checkExactAlarmPermission();
  }

  /// Check if the app has permission to schedule exact alarms (Android 12+)
  Future<void> _checkExactAlarmPermission() async {
    try {
      final bool hasPermission = await platform.invokeMethod(
        'checkExactAlarmPermission',
      );
      setState(() {
        _hasExactAlarmPermission = hasPermission;
        if (!hasPermission) {
          // _statusMessage = 'Exact alarm permission required (Android 12+)';
        }
      });
    } on PlatformException catch (e) {
      _showError('Permission check failed: ${e.message}');
    }
  }

  /// Request exact alarm permission (opens system settings on Android 12+)
  Future<void> _requestExactAlarmPermission() async {
    try {
      await platform.invokeMethod('requestExactAlarmPermission');
      // Re-check after user returns from settings
      await Future.delayed(const Duration(milliseconds: 500));
      await _checkExactAlarmPermission();
    } on PlatformException catch (e) {
      _showError('Permission request failed: ${e.message}');
    }
  }

  // void cancelAlarm(int alarmId) async {
  //   try {
  //     await platform.invokeMethod('cancelAlarm', alarmId);
  //     // print("Alarm cancelled with result: $result");
  //     // _showSuccess('Alarm $alarmId cancelled successfully.');
  //     showMessage(
  //       context,
  //       'New Alarm $alarmId cancelled successfully.',
  //       Colors.green,
  //     );
  //   } on PlatformException catch (e) {
  //     _showError('Failed to cancel alarm: ${e.message}');
  //   }
  // }

  void _onListenAlarmChannel() {
    debugPrint("Listening...");
    // Set the handler to receive messages from Java
    platform.setMethodCallHandler((call) async {
      // Check method name
      switch (call.method) {
        case 'onAlarmTriggered':
          _handleAlarmTriggered(call.arguments);
          break;
        default:
          debugPrint('Unknown method: ${call.method}');
      }
    });
  }

  void _handleAlarmTriggered(dynamic arguments) {
    final data = Map<String, dynamic>.from(arguments);

    // Extract the arguments passed from java
    debugPrint("Alarm triggered method called in Flutter");
    debugPrint("Arguments: $data");

    // final String videoUrl = data['videoUrl'];
    // final String title = data['title'];
    // final String alarmId = data['alarmId'];

    // Navigate to Video Player Screen
    if (mounted) {
      // Navigator.of(context).push(MaterialPageRoute(builder:   (context)=> PipVideoPlayer))
    }
  }

  /// Schedule an alarm to trigger at the selected time
  // Future<void> _scheduleAlarm() async {
  //   final videoUrl = _videoUrlController.text.trim();
  //   // var uuid = Uuid();

  //   // // Generate a v4 (random) id that will use cryptRNG for its rng function
  //   // final yid = uuid.v4();
  //   // print("Random Id" + yid);
  //   // print("Random hashcode " + (yid.hashCode).toString());

  //   if (videoUrl.isEmpty) {
  //     _showError('Please enter a video URL');
  //     return;
  //   }

  //   if (!_hasExactAlarmPermission) {
  //     _showError('Please grant exact alarm permission first');
  //     return;
  //   }

  //   try {
  //     // Calculate trigger time in milliseconds
  //     final now = DateTime.now();
  //     final scheduledDate = DateTime(
  //       now.year,
  //       now.month,
  //       now.day,
  //       22,
  //       04,
  //       // _selectedTime.hour,
  //       // _selectedTime.minute,
  //     );

  //     // If selected time is in the past today, schedule for tomorrow
  //     final triggerTime = scheduledDate.isBefore(now)
  //         ? scheduledDate.add(const Duration(days: 1))
  //         : scheduledDate;

  //     final triggerTimeMillis = triggerTime.millisecondsSinceEpoch;

  //     // Call native method to schedule alarm
  //     final result = await platform.invokeMethod('scheduleAlarm', {
  //       'alarmId': _currentAlarmId,
  //       'triggerTimeMillis': triggerTimeMillis,
  //       'videoUrl': videoUrl,
  //       'title': _titleController.text.trim(),
  //     });

  //     setState(() {
  //       _statusMessage =
  //           'Alarm scheduled for ${_formatDateTime(triggerTime)}\nID: $_currentAlarmId';
  //       _currentAlarmId++; // Increment for next alarm
  //     });
  //     print("Alarm scheduled with result: $result");

  //     _showSuccess(result.toString());
  //   } on PlatformException catch (e) {
  //     _showError('Failed to schedule alarm: ${e.message}');
  //   }
  // }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // void _showSuccess(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.green,
  //       duration: const Duration(seconds: 3),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final userReminders = ref.watch(userRemindersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Text(''),
        centerTitle: true,
        title: Text('Reminders'),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [IconButton(onPressed: null, icon: Icon(Icons.add))],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: _hasExactAlarmPermission
              ? FutureBuilder(
                  future: _remindersFuture,
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : ReminderList(reminders: userReminders),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Android requires permission to schedule exact alarms',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _requestExactAlarmPermission,
                        icon: const Icon(Icons.settings),
                        label: const Text('Grant Permission'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // _requestExactAlarmPermission();
          // _scheduleAlarm();
          // Example: Set alarm for 2:30 PM
          // cancelAlarm(2);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ReminderList extends ConsumerWidget {
  const ReminderList({super.key, required this.reminders});

  final List<ReminderItem> reminders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (reminders.isEmpty) {
      return Center(child: Text('No Reminders Added Yet!'));
    }

    void cancelAlarm(int alarmId) async {
      try {
        await platform.invokeMethod('cancelAlarm', alarmId);
        showMessage(
          // ignore: use_build_context_synchronously
          context,
          'New Alarm $alarmId cancelled successfully.',
          Colors.green,
        );
      } on PlatformException catch (e) {
        showMessage(
          // ignore: use_build_context_synchronously
          context,
          'Failed to cancel alarm: ${e.message}',
          Colors.red,
        );
      }
    }

    return ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final date = DateFormat(
          'yyyy-MM-dd',
        ).format(reminders[index].scheduledDate);
        final time = reminders[index].scheduledTime.format(context);
        final image = reminders[index].thumbnail;
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: Key(reminders[index].id),
            confirmDismiss: (direction) {
              return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Delete Reminder'),
                    content: Text(
                      'Are you sure you want to delete this reminder?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),

                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              // Handle reminder deletion here
              final reminderId = (reminders[index].id);
              final alarmId = reminderId.hashCode;
              ref
                  .read(userRemindersProvider.notifier)
                  .removeReminder(reminderId);

              cancelAlarm(alarmId);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.blue,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: ReminderCard(
              image: image,
              title: reminders[index].title,
              scheduleDate: date,
              scheduleTime: time,
            ),
          ),
        );
      },
    );
  }
}





  // Future<void> _initializeApp() async {
  //   await Workmanager().initialize(callbackDispatcher);
  //   await backgroundVideoService.initialize();

  //   // Set up notification tap handler
  //   backgroundVideoService.notificationsPlugin
  //       .getNotificationAppLaunchDetails();

  //   // Listen for new notifications while app is running
  //   backgroundVideoService.notificationsPlugin.initialize(
  //     const InitializationSettings(
  //       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  //     ),
  //     onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  //   );
  // }

  // void onDidReceiveNotificationResponse(
  //   NotificationResponse notificationResponse,
  // ) async {
  //   final String? payload = notificationResponse.payload;
  //   if (notificationResponse.payload != null) {
  //     debugPrint('notification payload: $payload');
  //   }
  //   // await Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute<void>(builder: (context) => VideoPlayerScreen(videoItem: ReminderItem.fromJson(json.decode(payload!)))),
  //   // );
  //   _handleNotificationPayload(payload);
  // }

  // void _handleNotificationPayload(String? payload) {
  //   if (payload != null) {
  //     final video = ReminderItem.fromJson(json.decode(payload));
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => VideoPlayerScreen(videoItem: video),
  //       ),
  //     );
  //   }
  // }