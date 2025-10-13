import 'package:flutter/material.dart';
import 'package:memo_clip/models/bottom_nav_bar_item.dart';
import 'package:memo_clip/screens/reminders/home_screen.dart';
import 'package:memo_clip/screens/reminders/section/bottom_nav_section.dart';
import 'package:memo_clip/screens/reminders/set_reminders_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int index = 0; // For Bottom Navigation Section
  int pageIndex = 0; // For Pages Section

  final pages = [
    const HomeScreen(),
    const SetRemindersScreen(),
    const Center(child: Text('Settings')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: // Bottom Navigation Section
      BottomNavigationSection(
        currentIndex: index,
        onTap: (value) => setState(() {
          index = value;
          pageIndex = value;
        }),
        children: [
          BottomNavBarItem(title: 'Reminders', icon: Icons.notifications_none),
          BottomNavBarItem(
            title: 'Set Reminder',
            icon: Icons.video_call_outlined,
          ),
          BottomNavBarItem(title: 'Settings', icon: Icons.settings_outlined),
        ],
      ),
    );
  }
}
