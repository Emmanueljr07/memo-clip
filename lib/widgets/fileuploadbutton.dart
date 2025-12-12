import 'package:flutter/material.dart';

class FileUploadButton extends StatelessWidget {
  const FileUploadButton({
    super.key,
    required bool isVideoFile,
    required this.colorScheme,
  }) : _isVideoFile = isVideoFile;

  final bool _isVideoFile;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: _isVideoFile ? colorScheme.onSurface : colorScheme.surface,
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
            Icons.file_upload_outlined,
            color: _isVideoFile ? colorScheme.surface : colorScheme.onSurface,
          ),
          const SizedBox(width: 5),
          Text(
            'File',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _isVideoFile ? colorScheme.surface : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
