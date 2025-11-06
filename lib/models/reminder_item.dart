import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'dart:io';

class ReminderItem {
  final String id;
  final File videoPath;
  final String title;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final File thumbnail;
  // final bool isRepeating;
  // final String repeatInterval; // e.g., "Daily", "Weekly"
  final bool isActive;

  ReminderItem({
    String? id,
    required this.videoPath,
    required this.title,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.thumbnail,
    // required this.isRepeating,
    // required this.repeatInterval,
    required this.isActive,
  }) : id = id ?? Uuid().v4();

  @override
  String toString() {
    return 'ReminderItem(id: $id, videoPath: $videoPath, title: $title, scheduledDate: $scheduledDate, scheduledTime: $scheduledTime, isActive: $isActive)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_path': videoPath.path,
      'title': title,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_time': '${scheduledTime.hour}:${scheduledTime.minute}',
      'thumbnail': thumbnail.path,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id'] as String,
      videoPath: File(json['video_path'] as String),
      title: json['title'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      scheduledTime: TimeOfDay(
        hour: int.parse((json['scheduled_time'] as String).split(':')[0]),
        minute: int.parse((json['scheduled_time'] as String).split(':')[1]),
      ),
      thumbnail: File(json['thumbnail'] as String),
      isActive: (json['is_active'] as int) == 1,
    );
  }
}
