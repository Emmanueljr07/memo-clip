import 'dart:io';

import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.image,
    required this.title,
    required this.scheduleDate,
    required this.scheduleTime,
  });

  final File image;
  final String title;
  final String scheduleDate;
  final String scheduleTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(right: 1, left: 2, top: 2, bottom: 0),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 5),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 60,
            width: 55,
            child: Image.file(image, fit: BoxFit.cover),
          ),
          // child: CircleAvatar(radius: 26, backgroundImage: FileImage(image)),
        ),
        isThreeLine: false,
        title: Text(title),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        subtitle: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(scheduleDate), Text(scheduleTime)],
          ),
        ),
      ),
    );
  }
}
