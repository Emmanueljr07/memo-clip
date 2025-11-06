import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:memo_clip/models/reminder_item.dart';
import 'package:memo_clip/models/video_metadata.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class UserRemindersNotifier extends StateNotifier<List<ReminderItem>> {
  UserRemindersNotifier() : super(const []);

  Future<Database> _getDatabase() async {
    // Implement database initialization and return the database instance
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'reminders.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE user_reminders(id TEXT PRIMARY KEY, title TEXT, video_path TEXT, scheduled_date TEXT, scheduled_time TEXT, thumbnail TEXT, is_active INTEGER)',
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
      );
    }).toList();

    state = reminders;
  }

  void addReminder(
    File videoPath,
    String title,
    DateTime scheduledDate,
    TimeOfDay scheduledTime,
    File thumbnail,
    bool isActive,
  ) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final videoFileName = path.basename(videoPath.path);
    final copiedVideo = await videoPath.copy('${appDir.path}/$videoFileName');

    final thumbnailFileName = path.basename(thumbnail.path);
    final copiedThumbnail = await thumbnail.copy(
      '${appDir.path}/$thumbnailFileName',
    );

    final reminder = ReminderItem(
      videoPath: copiedVideo,
      title: title,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      thumbnail: copiedThumbnail,

      isActive: isActive,
    );

    final db = await _getDatabase();

    db.insert("user_reminders", {
      "id": reminder.id,
      "title": reminder.title,
      "video_path": reminder.videoPath.path,
      "scheduled_date": reminder.scheduledDate.toIso8601String(),
      "scheduled_time":
          '${reminder.scheduledTime.hour}:${reminder.scheduledTime.minute}',
      "thumbnail": reminder.thumbnail.path,
      "is_active": reminder.isActive ? 1 : 0,
    });
    state = [...state, reminder];

    print('Reminder added: ${reminder.title}');
    print('Date added: ${reminder.scheduledDate}');
  }

  void updateReminders(List<ReminderItem> newReminders) {
    state = newReminders;
  }

  void removeReminder(String id) {
    state = state.where((reminder) => reminder.id != id).toList();
  }
}

final userRemindersProvider =
    StateNotifierProvider<UserRemindersNotifier, List<ReminderItem>>((ref) {
      return UserRemindersNotifier();
    });
