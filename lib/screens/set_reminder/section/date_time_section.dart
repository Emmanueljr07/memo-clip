import 'package:flutter/material.dart';
import 'package:memo_clip/widgets/date_input_field.dart';
import 'package:memo_clip/widgets/time_input_field.dart';

class DateTimeSection extends StatefulWidget {
  final TextEditingController dateController;
  final TextEditingController timeController;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const DateTimeSection({
    super.key,
    required this.dateController,
    required this.timeController,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<DateTimeSection> createState() => _DateTimeSectionState();
}

class _DateTimeSectionState extends State<DateTimeSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(Icons.date_range_outlined),
                      title: Text("Date"),
                    ),
                    DateInputField(
                      dateController: widget.dateController,
                      selectedDate: widget.selectedDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(Icons.watch_later_outlined),
                      title: Text("Time"),
                    ),
                    TimeInputField(
                      timeController: widget.timeController,
                      selectedTime: widget.selectedTime,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
