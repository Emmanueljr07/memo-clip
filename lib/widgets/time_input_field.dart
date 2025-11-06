import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TimeInputField extends StatefulWidget {
  final TextEditingController timeController;
  TimeOfDay? selectedTime;
  TimeInputField({
    super.key,
    required this.timeController,
    required this.selectedTime,
  });

  @override
  State<TimeInputField> createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<TimeInputField> {
  // final TextEditingController _timeController = TextEditingController();
  // TimeOfDay? _selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    // Show the built-in time picker dialog
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.selectedTime ?? TimeOfDay.now(),
    );

    // If a time was picked, update the state
    if (picked != null && picked != widget.selectedTime) {
      setState(() {
        widget.selectedTime = picked;
        // Format the time and set it to the text field
        widget.timeController.text = widget.selectedTime!.format(context);
      });
    }
  }

  // @override
  // void dispose() {
  //   widget.timeController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: TextField(
        controller: widget.timeController,
        readOnly: true, // Prevent manual text input
        onTap: () => _selectTime(context),
        decoration: const InputDecoration(
          labelText: 'Select a Time',
          labelStyle: TextStyle(fontSize: 13),
          prefixIcon: Icon(Icons.access_time),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
