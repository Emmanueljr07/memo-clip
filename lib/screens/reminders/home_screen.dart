import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo_clip/models/reminder_item.dart';
import 'package:memo_clip/provider/user_reminders.dart';
import 'package:memo_clip/widgets/reminder_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<void> _remindersFuture;
  // bool workmanagerInitialized = false;

  @override
  void initState() {
    super.initState();
    _remindersFuture = ref
        .read(userRemindersProvider.notifier)
        .fetchReminders();

    // _initializeApp();
  }

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
          child: FutureBuilder(
            future: _remindersFuture,
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : ReminderList(reminders: userReminders),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // if (!workmanagerInitialized) {
          //   try {
          //     await Workmanager().initialize(callbackDispatcher);
          //     print('Workmanager initialized successfully');
          //   } catch (e) {
          //     print('Error initializing Workmanager: $e');
          //     return;
          //   }
          //   setState(() => workmanagerInitialized = true);
          // }
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
              final reminderId = reminders[index].id;
              ref
                  .read(userRemindersProvider.notifier)
                  .removeReminder(reminderId);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Reminder deleted')));
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