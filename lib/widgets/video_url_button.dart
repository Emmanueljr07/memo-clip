import 'package:flutter/material.dart';

class VideoUrlButton extends StatelessWidget {
  const VideoUrlButton({
    super.key,
    required bool isVideoUrl,
    required this.colorScheme,
  }) : _isVideoUrl = isVideoUrl;

  final bool _isVideoUrl;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: _isVideoUrl ? colorScheme.onSurface : colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.onSurface.withAlpha(150),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link,
            color: _isVideoUrl ? colorScheme.surface : colorScheme.onSurface,
          ),
          const SizedBox(width: 5),
          Text(
            "Video URL",
            style: TextStyle(
              fontSize: 12,
              color: _isVideoUrl ? colorScheme.surface : colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
