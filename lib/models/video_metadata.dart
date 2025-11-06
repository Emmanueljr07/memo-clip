import 'dart:io';

class VideoMetadata {
  final File thumbnailPath;
  final String duration;
  final String fileSize;

  VideoMetadata({
    required this.thumbnailPath,
    required this.duration,
    required this.fileSize,
  });
}
