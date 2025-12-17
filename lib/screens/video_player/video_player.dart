// screens/video_player_screen.dart
// import 'dart:io';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/reminder_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  final ReminderItem videoItem;

  const VideoPlayerScreen({super.key, required this.videoItem});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  // Future<void> loadVideo(File? file) async {
  //   if (file != null && mounted) {
  //     await _controller.dispose();

  //     // _controller = VideoPlayerController.file(file);
  //     final VideoPlayerController controller;
  //     if (kIsWeb) {
  //       controller = VideoPlayerController.networkUrl(Uri.parse(file.path));
  //     } else {
  //       controller = VideoPlayerController.file(File(file.path));
  //     }
  //     _controller = controller;
  //     const double volume = kIsWeb ? 0.0 : 1.0;
  //     await controller.setVolume(volume);
  //     await controller.initialize();
  //     await controller.setLooping(false);
  //     await controller.play();
  //     setState(() {});
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoItem.videoPath);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.videoItem.title)),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        height: 300,
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: 2 / 1,
                child: VideoPlayer(_controller),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
