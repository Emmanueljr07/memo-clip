import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:memo_clip/theme/theme.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(ThemeData.light());

  void themeData(ThemeData themeData) {
    state = themeData;
  }

  void toggleTheme() {
    if (state == lightMode) {
      state = darkMode;
    } else {
      state = darkMode;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});
