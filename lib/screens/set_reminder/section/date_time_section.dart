import 'package:flutter/material.dart';
import 'package:memo_clip/widgets/date_input_field.dart';
import 'package:memo_clip/widgets/time_input_field.dart';

class DateTimeSection extends StatefulWidget {
  final void Function(DateTime selectedDate) onDateChanged;
  final void Function(TimeOfDay selectedTime) onTimeChanged;

  const DateTimeSection({
    super.key,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  State<DateTimeSection> createState() => _DateTimeSectionState();
}

class _DateTimeSectionState extends State<DateTimeSection> {
  DateTime? _date;
  TimeOfDay? _time;

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
                      onDateChanged: (DateTime selectedDate) {
                        setState(() {
                          _date = selectedDate;
                          widget.onDateChanged(_date!);
                        });
                      },
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
                      onTimeChanged: (TimeOfDay selectedTime) {
                        setState(() {
                          _time = selectedTime;
                          widget.onTimeChanged(_time!);
                        });
                      },
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
