import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DateInputField extends StatefulWidget {
  final void Function(DateTime selectedDate) onDateChanged;

  const DateInputField({super.key, required this.onDateChanged});

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    // Show the built-in date picker dialog
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Set minimum selectable date
      lastDate: DateTime(2101), // Set maximum selectable date
    );

    // If a date was picked, update the state
    if (picked != null && picked != _selectedDate) {
      setState(() {
        // print(' picked date: $picked');
        _selectedDate = picked;
        widget.onDateChanged(_selectedDate!);
        // Format the date and set it to the text field
        _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
      });
    }
  }

  // @override
  // void dispose() {
  //   widget.dateController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: TextField(
        controller: _dateController,
        readOnly: true, // Prevent manual text input
        onTap: () => _selectDate(context),
        decoration: const InputDecoration(
          labelText: 'Select a Date',
          labelStyle: TextStyle(fontSize: 13),
          hintText: 'dd-MM-yyyy',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
