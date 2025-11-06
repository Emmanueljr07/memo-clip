import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_clip/provider/user_reminders.dart';
import 'package:memo_clip/screens/reminders/tabs.dart';
import 'package:memo_clip/screens/set_reminder/section/date_time_section.dart';
import 'package:memo_clip/screens/set_reminder/section/title_section.dart';
import 'package:memo_clip/screens/set_reminder/section/video_source_section.dart';

class SetRemindersScreen extends ConsumerStatefulWidget {
  const SetRemindersScreen({super.key});

  @override
  ConsumerState<SetRemindersScreen> createState() => _SetRemindersScreenState();
}

class _SetRemindersScreenState extends ConsumerState<SetRemindersScreen> {
  // Controller handler for TitleSection
  late final TextEditingController titleController;

  // Handlers for VideoSource Section
  File? videoPath;
  File? thumbnailFilePath;

  // Controller handlers for DateTimeSection
  late final TextEditingController dateController;
  late final TextEditingController timeController;
  late final DateTime selectedDate;
  late final TimeOfDay selectedTime;

  void _saveReminder() {
    final enteredtitle = titleController.text;
    final enteredVideo = videoPath;
    final scheduledDate = selectedDate;
    final scheduledTime = selectedTime;
    final thumbnail = thumbnailFilePath;
    final isActive = true;

    ref
        .read(userRemindersProvider.notifier)
        .addReminder(
          enteredVideo!,
          enteredtitle,
          scheduledDate,
          scheduledTime,
          thumbnail!,
          isActive,
        );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const TabsScreen();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    dateController = TextEditingController();
    timeController = TextEditingController();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    videoPath = null;
    thumbnailFilePath = null;
  }

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userRemindersProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const TabsScreen();
                },
              ),
            );
          },
          icon: Icon(Icons.close_rounded),
        ),
        centerTitle: true,
        title: const Text('Set Reminder'),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 100,
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleSection(titleController: titleController),

                      // Video Source Section
                      VideoSourceSection(
                        onVideoPicked: (File path, File thumbnail) {
                          setState(() {
                            videoPath = path;
                            thumbnailFilePath = thumbnail;
                          });
                        },
                      ),

                      // Data and Time Section
                      DateTimeSection(
                        dateController: dateController,
                        timeController: timeController,
                        selectedDate: selectedDate,
                        selectedTime: selectedTime,
                      ),
                    ],
                  ),
                ),

                // Cancel and Create Reminder Buttons
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (ctx) => TabsScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onPrimary,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancel ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _saveReminder();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
