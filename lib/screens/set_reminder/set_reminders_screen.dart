import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_clip/models/reminder_item.dart';
import 'package:memo_clip/provider/user_reminders.dart';
import 'package:memo_clip/screens/reminders/tabs.dart';
import 'package:memo_clip/screens/set_reminder/section/date_time_section.dart';
import 'package:memo_clip/screens/set_reminder/section/title_section.dart';
import 'package:memo_clip/screens/set_reminder/section/video_source_section.dart';
import 'package:memo_clip/widgets/loading_screen.dart';
import 'package:memo_clip/widgets/show_message.dart';
import 'package:uuid/uuid.dart';

class SetRemindersScreen extends ConsumerStatefulWidget {
  const SetRemindersScreen({super.key});

  @override
  ConsumerState<SetRemindersScreen> createState() => _SetRemindersScreenState();
}

class _SetRemindersScreenState extends ConsumerState<SetRemindersScreen> {
  // static const platform = MethodChannel('memoclip.app/video_alarm_channel');
  // Controller handler for TitleSection
  late final TextEditingController titleController;

  // Handlers for VideoSource Section
  File? _videoPath;
  File? _thumbnailFilePath;

  // Controller handlers for DateTimeSection
  DateTime? pickedDate;
  TimeOfDay? pickedTime;

  bool _isLoading = false;
  RepeatInterval _interval = RepeatInterval.noRepeat;

  // default reminder name
  var number = Uuid().v4().substring(0, 8);

  void _saveReminder() {
    // Show Loading Indicator
    setState(() {
      _isLoading = true;
    });

    var enteredtitle = titleController.text;
    final enteredVideo = _videoPath;
    final scheduledDate = pickedDate;
    final scheduledTime = pickedTime;
    final thumbnail = _thumbnailFilePath;
    final isActive = true;

    if (enteredVideo == null ||
        scheduledDate == null ||
        scheduledTime == null ||
        thumbnail == null) {
      showMessage("Enter valid details", Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    } else {
      if (enteredtitle.isEmpty) {
        enteredtitle = 'Reminder $number';
      }
      ref
          .read(userRemindersProvider.notifier)
          .addReminder(
            enteredVideo,
            enteredtitle,
            scheduledDate,
            scheduledTime,
            thumbnail,
            isActive,
            _interval,
          );

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const TabsScreen();
              },
            ),
          );
        }
      });
    }
    // debugPrint("Time: $pickedTime");
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    // selectedDate = DateTime.now();
    // selectedTime = TimeOfDay.now();
    _videoPath = null;
    _thumbnailFilePath = null;
  }

  @override
  void dispose() {
    titleController.dispose();
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
        child: Container(
          width: double.infinity,
          // height: MediaQuery.of(context).size.height - 50,
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleSection(titleController: titleController),

                          // Video Source Section
                          VideoSourceSection(
                            onVideoPicked: (File path, File thumbnail) {
                              setState(() {
                                _videoPath = path;
                                _thumbnailFilePath = thumbnail;
                              });
                            },
                          ),

                          // Data and Time Section
                          DateTimeSection(
                            // selectedDate: DateTime.now(),
                            // selectedTime: TimeOfDay.now(),
                            onDateChanged: (DateTime selectedDate) {
                              setState(() {
                                pickedDate = selectedDate;
                              });
                            },
                            onTimeChanged: (TimeOfDay selectedTime) {
                              setState(() {
                                pickedTime = selectedTime;
                              });
                            },
                          ),

                          SizedBox(height: 20),
                          // Dropdown for Repeating Interval
                          Text(
                            "Select a Repeat Interval",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: colorScheme.onSurface,
                                width: 1,
                              ),
                            ),
                            child: DropdownButton<RepeatInterval>(
                              value: _interval,
                              underline: Container(),
                              items: RepeatInterval.values
                                  .map<DropdownMenuItem<RepeatInterval>>((
                                    RepeatInterval value,
                                  ) {
                                    return DropdownMenuItem<RepeatInterval>(
                                      value: value,
                                      child: switch (value) {
                                        RepeatInterval.noRepeat => Text(
                                          'Never Repeat',
                                        ),
                                        RepeatInterval.hour => Text(
                                          'Every hour',
                                        ),
                                        RepeatInterval.half => Text(
                                          "Every 12 hours",
                                        ),
                                        RepeatInterval.daily => Text('Daily'),
                                        RepeatInterval.weekly => Text('Weekly'),
                                      },
                                    );
                                  })
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _interval = newValue!;
                                });
                                debugPrint("New Value: $_interval");
                              },
                            ),
                          ),
                        ],
                      ),
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
                                MaterialPageRoute(
                                  builder: (ctx) => TabsScreen(),
                                ),
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

                  if (_isLoading) LoadingScreen(),
                ],
              ),
              if (_isLoading) LoadingScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
