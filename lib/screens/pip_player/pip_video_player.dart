import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player_pip/index.dart';

class PipVideoPlayer extends StatefulWidget {
  const PipVideoPlayer({
    super.key,
    required this.title,
    required this.videoUrl,
    required this.id,
  });

  final String title;
  final String videoUrl;
  final String id;

  @override
  State<PipVideoPlayer> createState() => _PipVideoPlayerState();
}

class _PipVideoPlayerState extends State<PipVideoPlayer> {
  VideoPlayerController? _controller;
  String _debugStatus = "Starting initialization";
  bool _videoInitialized = false;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    loadVideo(File(widget.videoUrl));
  }

  Future<void> loadVideo(File? file) async {
    try {
      if (!mounted) return;
      setState(() {
        _debugStatus = "Creating controller";
      });

      if (file != null && mounted) {
        // await _controller.dispose();

        // _controller = VideoPlayerController.file(file);
        final VideoPlayerController controller;
        final isVideoLink =
            file.path.startsWith('http://') || file.path.startsWith('https://');
        if (kIsWeb || isVideoLink) {
          controller = VideoPlayerController.networkUrl(Uri.parse(file.path));
        } else {
          controller = VideoPlayerController.file(File(file.path));
        }

        const double volume = kIsWeb ? 0.0 : 1.0;
        await controller.setVolume(volume);

        if (!mounted) {
          await controller.dispose();
          return;
        }
        _controller = controller;
        await controller.initialize();

        _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
          setState(() {});
        });
        await _controller!.setLooping(false);
        await _controller!.play();
        try {
          await _controller!.enterPipMode(width: 350, height: 400);
        } catch (e) {
          debugPrint("PiP failed to start auto: $e");
        }
        // await _controller!.enterPipMode(width: 350, height: 400);

        setState(() {
          _debugStatus = "Initializing VideoPlayerController";
          _videoInitialized = true;
        });

        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _debugStatus = "Error initializing VideoPlayerController: $e";
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    // Check both boolean and null safety
    final isReady = _videoInitialized && _controller != null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          Center(
            child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(_debugStatus),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          if (isReady)
            Center(
              child: IconButton(
                onPressed: () {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                  setState(() {});
                },
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    final currentPosition = _controller!.value.position;
                    final newPosition =
                        currentPosition - const Duration(seconds: 5);
                    _controller!.seekTo(
                      newPosition >= Duration.zero
                          ? newPosition
                          : Duration.zero,
                    );
                  },
                  icon: Icon(Icons.replay_5_rounded, color: Colors.white),
                ),

                IconButton(
                  onPressed: () {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                    setState(() {});
                  },
                  icon: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    final currentPosition = _controller!.value.position;
                    final videoDuration = _controller!.value.duration;
                    final newPosition =
                        currentPosition + const Duration(seconds: 5);
                    _controller!.seekTo(
                      newPosition <= videoDuration
                          ? newPosition
                          : videoDuration,
                    );
                  },
                  icon: Icon(Icons.forward_5_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: (isReady && deviceHeight >= 500)
          ? FloatingActionButton(
              onPressed: () {
                final aspectRatio = _controller!.value.aspectRatio;
                const width = 300;
                final height = width / aspectRatio;
                _controller!.enterPipMode(width: width, height: height.toInt());
              },
              child: const Icon(Icons.picture_in_picture),
              //       child: Icon(
              //   _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              // ),
            )
          : null,
    );
  }
}
