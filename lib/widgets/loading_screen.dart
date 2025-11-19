import 'dart:ui';

import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final bool showLoading;
  const LoadingScreen({super.key, required this.showLoading});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      enabled: showLoading,
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
