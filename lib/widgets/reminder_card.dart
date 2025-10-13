import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 10, left: 2, top: 10, bottom: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 5),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            color: Colors.amber,
            'assets/logo.jpg',
            fit: BoxFit.cover,
            width: 60,
            height: 50,
          ),
        ),
        title: Text('Reminder Title'),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        subtitle: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tomorrow, 12:00 PM'),
              Text('Reminder details go here'),
            ],
          ),
        ),
      ),
    );
  }
}
