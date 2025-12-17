import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:better_native_video_player/better_native_video_player.dart';
import 'package:memo_clip/widgets/loading_screen.dart';
import 'package:memo_clip/widgets/show_message.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class BetterVideoPlayer extends StatefulWidget {
  const BetterVideoPlayer({
    super.key,
    required this.title,
    required this.videoUrl,
    required this.id,
  });

  final String title;
  final String videoUrl;
  final int id;

  @override
  State<BetterVideoPlayer> createState() => _BetterVideoPlayerState();
}

class _BetterVideoPlayerState extends State<BetterVideoPlayer> {
  late NativeVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Create controller
      _controller = NativeVideoPlayerController(
        id: widget.id,
        autoPlay: true,
        allowsPictureInPicture: true,
        canStartPictureInPictureAutomatically: true,
      );
      final bool isConnected =
          await InternetConnectionChecker.instance.hasConnection;

      // Check if video is a web link
      final isVideoLink =
          widget.videoUrl.startsWith('http://') ||
          widget.videoUrl.startsWith('https://');

      if (isVideoLink && !isConnected) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('No Internet Connection'),
                content: Text('Please check your connection and try again '),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _initializePlayer();
                      Navigator.of(context).pop(true);
                    },

                    child: Text('Try again'),
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      // Listen to events
      _controller.addActivityListener(_handleActivityEvent);

      // Initialize
      await _controller.initialize();

      if (kIsWeb || isVideoLink) {
        // Load video:
        // Load remote URL (HLS stream)
        await _controller.loadUrl(url: widget.videoUrl);
      } else {
        // Option 3: Load local file from device storage
        await _controller.loadFile(path: widget.videoUrl);
      }

      await _controller.enterFullScreen();

      final isPIPAvailable = await _controller.isPictureInPictureAvailable();
      if (isPIPAvailable) {
        await _controller.enterPictureInPicture();
        _controller.canStartPictureInPictureAutomatically;
      }
    } catch (e) {
      debugPrint(e.toString());
      showMessage("Failed to play video", Colors.red);
    }
  }

  void _handleActivityEvent(PlayerActivityEvent event) {
    switch (event.state) {
      case PlayerActivityState.buffering:
        LoadingScreen();
        break;
      case PlayerActivityState.completed:
        _controller.exitFullScreen();
        _controller.exitPictureInPicture();
        break;
      case PlayerActivityState.error:
        debugPrint("Error: ${event.data?['message']}");
        showMessage("Something went wrong while Playing video", Colors.red);
      default:
        break;
    }
  }

  @override
  void dispose() {
    _controller.removeActivityListener(_handleActivityEvent);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: NativeVideoPlayer(controller: _controller));
  }
}
