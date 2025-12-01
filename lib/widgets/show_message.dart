import 'package:flutter/material.dart';
import 'package:memo_clip/main.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMessage(
  String message,
  Color color,
) {
  BuildContext context = MyApp.navigatorKey.currentContext!;
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 5),
    ),
  );
}
