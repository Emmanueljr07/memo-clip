import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:memo_clip/constants/constants.dart';
import 'package:memo_clip/models/reminder_item.dart';
import 'package:memo_clip/widgets/show_message.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class UserRemindersNotifier extends StateNotifier<List<ReminderItem>> {
  UserRemindersNotifier() : super(const []);

  static const platform = MethodChannel(Constants.plateformSTRING);

  // final FlutterLocalNotificationsPlugin notificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  Future<Database> _getDatabase() async {
    // Implement database initialization and return the database instance
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'reminders.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE user_reminders(id TEXT PRIMARY KEY, title TEXT, video_path TEXT, scheduled_date TEXT, scheduled_time TEXT, thumbnail TEXT, is_active INTEGER,is_repeating INTEGER, repeat_interval TEXT)',
        );
      },
      version: 1,
    );

    return db;
  }

  Future<void> fetchReminders() async {
    final db = await _getDatabase();
    final data = await db.query('user_reminders');
    final reminders = data.map((item) {
      return ReminderItem(
        id: item['id'] as String,
        title: item['title'] as String,
        videoPath: File(item['video_path'] as String),
        scheduledDate: DateTime.parse(item['scheduled_date'] as String),
        scheduledTime: TimeOfDay(
          hour: int.parse((item['scheduled_time'] as String).split(':')[0]),
          minute: int.parse((item['scheduled_time'] as String).split(':')[1]),
        ),
        thumbnail: File(item['thumbnail'] as String),
        isActive: (item['is_active'] as int) == 1,
        isRepeating: (item['is_repeating'] as int) == 1,
        repeatInterval: RepeatInterval.values.firstWhere(
          (e) => e.toString().split('.').last == item['repeat_interval'],
          orElse: () => RepeatInterval.noRepeat,
        ),
      );
    }).toList();

    for (var i = 0; i < reminders.length; i++) {
      final now = DateTime.now();
      final date = reminders[i].scheduledDate;
      final time = reminders[i].scheduledTime;
      final year = date.year;
      final month = date.month;
      final day = date.day;
      final hour = time.hour;
      final minute = time.minute;

      final reminderDate = DateTime(year, month, day, hour, minute);
      final dateCheck = reminderDate.isBefore(now);
      if (dateCheck && reminders[i].repeatInterval == RepeatInterval.noRepeat) {
        reminders[i].isActive = false;
      }
    }

    state = reminders;
  }

  void addReminder(
    File videoPath,
    String title,
    DateTime scheduledDate,
    TimeOfDay scheduledTime,
    File thumbnail,
    bool isActive,
    RepeatInterval interval,
  ) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final videoFileName = path.basename(videoPath.path);
    final copiedVideo = await videoPath.copy('${appDir.path}/$videoFileName');

    final thumbnailFileName = path.basename(thumbnail.path);
    final copiedThumbnail = await thumbnail.copy(
      '${appDir.path}/$thumbnailFileName',
    );

    final reminder = ReminderItem(
      title: title,
      videoPath: copiedVideo,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      thumbnail: copiedThumbnail,
      isActive: isActive,
      isRepeating: false,
      repeatInterval: interval,
    );

    final db = await _getDatabase();

    db.insert("user_reminders", reminder.toJson());
    state = [...state, reminder];

    debugPrint('Reminder added: ${reminder.title}');
    debugPrint('Date added: ${reminder.scheduledDate}');

    // Schedule background check
    final videoUrl = reminder.videoPath.path;
    final alarmTitle = reminder.title;
    final alarmId = (reminder.id).hashCode;
    final repeatInterval = reminder.repeatInterval.name;
    debugPrint("Interval: $repeatInterval");
    // final alarmId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (videoUrl.isEmpty) {
      // _showError('Please enter a video URL');
      // showMessage(context, "Please enter a video URL", Colors.red);
      debugPrint("Video URL is empty");
      return;
    }
    final pickedDate = reminder.scheduledDate;
    final pickedTime = reminder.scheduledTime;
    try {
      final year = pickedDate.year;
      final month = pickedDate.month;
      final day = pickedDate.day;
      final hour = pickedTime.hour;
      final minute = pickedTime.minute;
      // Calculate trigger time in milliseconds
      final now = DateTime.now();
      final scheduledDate = DateTime(year, month, day, hour, minute);

      // If selected time is in the past today, schedule for tomorrow
      final triggerTime = scheduledDate.isBefore(now)
          ? scheduledDate.add(const Duration(days: 1))
          : scheduledDate;

      final triggerTimeMillis = triggerTime.millisecondsSinceEpoch;

      // Call native method to schedule alarm
      final result = await platform.invokeMethod('scheduleAlarm', {
        'alarmId': alarmId,
        'triggerTimeMillis': triggerTimeMillis,
        'videoUrl': videoUrl,
        'title': alarmTitle,
        'interval': repeatInterval,
      });

      showMessage("$title Video Reminder created", Colors.green);

      debugPrint("Alarm scheduled with result: $result");
    } on PlatformException catch (e) {
      debugPrint("Failed to schedule alarm: ${e.message}");
    }
  }

  // Future<void> checkAndShowScheduledVideos() async {
  //   // final prefs = await SharedPreferences.getInstance();
  //   // final videosJson = prefs.getStringList('scheduled_videos') ?? [];

  //   final db = await _getDatabase();
  //   final data = await db.query('user_reminders');
  //   // final now = DateTime.now();

  //   for (final videoJson in data) {
  //     final video = ReminderItem.fromJson(videoJson);

  //     // Check if it's time to show this video (Video Time is the same as Time of the day)
  //     final now = DateTime.now();
  //     final timeOfTheDay = TimeOfDay.now();
  //     if (video.scheduledDate.isAtSameMomentAs(now) &&
  //         video.scheduledTime.isAtSameTimeAs(timeOfTheDay)) {
  //       await _showVideoNotification(video);

  //       // Remove non-recurring videos after showing
  //       if (!video.isActive) {
  //         await removeScheduledVideo(video.id);
  //       }
  //     }
  //   }
  // }

  Future<void> showVideoNotification({
    required String videoUrl,
    required String title,
    required int notId,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notId,
        channelKey: 'memoclip',
        title: '$title video reminder',
        body: "You created a video reminder",
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        payload: {
          'action': 'create_video',
          'videoUrl': videoUrl,
          'title': title,
          'notId': notId.toString(),
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS_REMINDER',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
        ),
      ],
    );
  }

  void updateReminders(List<ReminderItem> newReminders) {
    state = newReminders;
  }

  void removeReminder(String id, String title) async {
    final db = await _getDatabase();
    final alarmId = id.hashCode;
    await db.delete('user_reminders', where: 'id = ?', whereArgs: [id]);
    try {
      await platform.invokeMethod('cancelAlarm', alarmId);
    } on PlatformException catch (e) {
      showMessage('Failed to cancel alarm: ${e.message}', Colors.red);
    }

    state = state.where((reminder) => reminder.id != id).toList();
    showMessage('Reminder $title deleted successfully.', Colors.green);
  }
}

final userRemindersProvider =
    StateNotifierProvider<UserRemindersNotifier, List<ReminderItem>>((ref) {
      return UserRemindersNotifier();
    });
