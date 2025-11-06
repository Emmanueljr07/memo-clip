import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DateInputField extends StatefulWidget {
  final TextEditingController dateController;
  DateTime? selectedDate;
  DateInputField({
    super.key,
    required this.dateController,
    required this.selectedDate,
  });

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  // final TextEditingController _dateController = TextEditingController();
  // DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    // Show the built-in date picker dialog
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000), // Set minimum selectable date
      lastDate: DateTime(2101), // Set maximum selectable date
    );

    // If a date was picked, update the state
    if (picked != null && picked != widget.selectedDate) {
      setState(() {
        widget.selectedDate = picked;
        // Format the date and set it to the text field
        widget.dateController.text = DateFormat(
          'dd-MM-yyyy',
        ).format(widget.selectedDate!);
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
        controller: widget.dateController,
        readOnly: true, // Prevent manual text input
        onTap: () => _selectDate(context),
        decoration: const InputDecoration(
          labelText: 'Select a Date',
          labelStyle: TextStyle(fontSize: 13),
          hintText: 'yyyy-MM-dd',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
