import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'dart:io';

enum RepeatInterval { noRepeat, daily, weekly, monthly, yearly }

class ReminderItem {
  final String id;
  final String title;
  final File videoPath;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final File thumbnail;
  final bool isRepeating;
  final RepeatInterval repeatInterval; // e.g., "Daily", "Weekly"
  final bool isActive;

  ReminderItem({
    String? id,
    required this.videoPath,
    required this.title,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.thumbnail,
    required this.isRepeating,
    required this.repeatInterval,
    required this.isActive,
  }) : id = id ?? Uuid().v4();

  @override
  String toString() {
    return 'ReminderItem(id: $id, videoPath: $videoPath, title: $title, scheduledDate: $scheduledDate, scheduledTime: $scheduledTime, isActive: $isActive)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'video_path': videoPath.path,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_time': '${scheduledTime.hour}:${scheduledTime.minute}',
      'thumbnail': thumbnail.path,
      'is_active': isActive ? 1 : 0,
      'is_repeating': isRepeating ? 1 : 0,
      'repeat_interval': repeatInterval.name,
      // 'repeat_interval': repeatInterval.toString().split('.').last,
    };
  }

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id'] as String,
      title: json['title'] as String,
      videoPath: File(json['video_path'] as String),
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      scheduledTime: TimeOfDay(
        hour: int.parse((json['scheduled_time'] as String).split(':')[0]),
        minute: int.parse((json['scheduled_time'] as String).split(':')[1]),
      ),
      thumbnail: File(json['thumbnail'] as String),
      isActive: (json['is_active'] as int) == 1,
      isRepeating: (json['is_repeating'] as int) == 1,
      repeatInterval: RepeatInterval.values.firstWhere(
        (e) => e.toString().split('.').last == json['repeat_interval'],
        orElse: () => RepeatInterval.noRepeat,
      ),
    );
  }
}
