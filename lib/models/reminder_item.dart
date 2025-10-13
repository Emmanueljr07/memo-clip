class ReminderItem {
  final String videoPath;
  final String reminderTitle;
  final DateTime reminderTime;
  final String reminderDescription;
  final bool isRepeating;
  // final String repeatInterval; // e.g., "Daily", "Weekly"
  final bool isActive;

  ReminderItem({
    required this.videoPath,
    required this.reminderTitle,
    required this.reminderTime,
    required this.reminderDescription,
    required this.isRepeating,
    // required this.repeatInterval,
    required this.isActive,
  });
}
