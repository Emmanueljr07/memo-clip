import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_clip/provider/theme_provider.dart';
import 'package:memo_clip/theme/theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final userTheme = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              // General
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "General",
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorScheme.secondary.withAlpha(100),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.language),
                            title: Text("Language"),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          SwitchListTile(
                            value: true,
                            onChanged: (isChecked) {},
                            title: Row(
                              children: [
                                Icon(Icons.notifications_none),
                                SizedBox(width: 15),
                                Text("Notification Sound"),
                              ],
                            ),
                          ),
                          Divider(),
                          SwitchListTile(
                            value: true,
                            onChanged: (isChecked) {},
                            title: Text("Haptic Feedback"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Theme
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Appearance",
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12),
                      height: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorScheme.secondary.withAlpha(100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Theme",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),

                          // LIGHT, DARK AND SYSTEM THEMES
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // LIGHT THEME
                              GestureDetector(
                                onTap: () {
                                  userTheme.themeData(lightMode);
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 103,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.wb_sunny_outlined,
                                          size: 30,
                                          color: Colors.blue[400],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "Light",
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // DARK THEME
                              GestureDetector(
                                onTap: () {
                                  userTheme.themeData(darkMode);
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 103,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black,
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.dark_mode_outlined,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "Dark",
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // SYSTEM THEME
                              GestureDetector(
                                onTap: () {
                                  if (ThemeMode.system == ThemeMode.dark) {
                                    userTheme.themeData(darkMode);
                                  } else {
                                    userTheme.themeData(lightMode);
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 103,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black26,
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Text(''),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "System",
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
