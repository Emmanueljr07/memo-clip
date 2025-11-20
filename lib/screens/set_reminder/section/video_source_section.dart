import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// ignore: must_be_immutable
class VideoSourceSection extends StatefulWidget {
  // final String? videoPath;
  // final String? thumbnailFilePath;
  final void Function(File path, File thumbnail) onVideoPicked;
  const VideoSourceSection({
    super.key,
    // required this.videoPath,
    // required this.thumbnailFilePath,
    required this.onVideoPicked,
  });

  @override
  State<VideoSourceSection> createState() => _VideoSourceSectionState();
}

class _VideoSourceSectionState extends State<VideoSourceSection> {
  bool _isVideoUrl = false;
  bool _isVideoFile = false;
  List<XFile>? mediaFileList;

  File? _videoPath;
  File? _thumbnailFile;

  void _setImageFileListFromFile(XFile? value) {
    mediaFileList = value == null ? null : <XFile>[value];
  }

  bool isVideo = false;

  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _playVideo(XFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      final VideoPlayerController controller;
      if (kIsWeb) {
        controller = VideoPlayerController.networkUrl(Uri.parse(file.path));
      } else {
        controller = VideoPlayerController.file(File(file.path));
      }
      _controller = controller;
      // In web, most browsers won't honor a programmatic call to .play
      // if the video has a sound track (and is not muted).
      // Mute the video so it auto-plays in web!
      // This is not needed if the call to .play is the result of user
      // interaction (clicking on a "play" button, for example).
      const double volume = kIsWeb ? 0.0 : 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();
      setState(() {});
    }
  }

  Future<XFile?> generateThumbnail(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat:
          ImageFormat.JPEG, // You can choose other formats like PNG, WEBP
      maxHeight: 128, // Customize thumbnail size
      quality: 75, // Customize thumbnail quality (0-100)
    );
    if (thumbnailPath != null) {
      return XFile(thumbnailPath);
    }
    return null;
  }

  Future<void> _onVideoButtonPressed(
    ImageSource source, {
    required BuildContext context,
    bool allowMultiple = false,
  }) async {
    if (_controller != null) {
      await _controller!.setVolume(0.0);
    }
    if (context.mounted) {
      if (isVideo) {
        final List<XFile> files;
        if (allowMultiple) {
          files = await _picker.pickMultiVideo();
        } else {
          // Picking a Video
          final XFile? file = await _picker.pickVideo(
            source: source,
            maxDuration: const Duration(minutes: 1, seconds: 10),
          );
          files = <XFile>[if (file != null) file];

          // Getting Video Path
          final pickedPath = file?.path;
          if (pickedPath != null) {
            setState(() {
              _videoPath = File(pickedPath);
            });
          }

          // Generating Thumbnail
          final generatedthumbnail = await generateThumbnail(pickedPath!);
          if (generatedthumbnail != null) {
            setState(() {
              _thumbnailFile = File(generatedthumbnail.path);
            });
          }
          // Callback to parent
          if (generatedthumbnail != null) {
            widget.onVideoPicked(_videoPath!, _thumbnailFile!);
          }
        }

        debugPrint('Video path: $_videoPath');
        debugPrint('Thumbnail path: ${_thumbnailFile!.path}');
        // Just play the first file, to keep the example simple.
        await _playVideo(files.firstOrNull);
      }
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _previewVideo() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  @override
  void initState() {
    super.initState();
    _isVideoUrl = true;
  }

  @override
  void deactivate() {
    if (_controller != null) {
      // _controller!.setVolume(0.0); // Mute the video
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget _handlePreview() {
    if (!isVideo) {
      return const Text(
        'You have not yet picked a video.',
        textAlign: TextAlign.center,
      );
    }
    return _previewVideo();
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          if (response.files == null) {
            _setImageFileListFromFile(response.file);
          } else {
            mediaFileList = response.files;
          }
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Video Source",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),

        // Video source
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              // Video URL Button
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isVideoUrl = true;
                      _isVideoFile = false;
                    });
                  },
                  child: VideoUrlButton(
                    isVideoUrl: _isVideoUrl,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // File Upload Button
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isVideoUrl = false;
                      _isVideoFile = true;
                    });
                  },
                  child: FileUploadButton(
                    isVideoFile: _isVideoFile,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // Input Video Url
        Visibility(
          visible: _isVideoUrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Video URL"),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(child: TextField()),
                  ElevatedButton(onPressed: null, child: Text('Add')),
                ],
              ),
            ],
          ),
        ),

        // Upload Video File
        Visibility(
          visible: _isVideoFile,
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Video File',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      isVideo = true;
                      _onVideoButtonPressed(
                        ImageSource.gallery,
                        context: context,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.onSurface.withAlpha(120),
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: AspectRatio(
                          aspectRatio: 2.8,
                          child: ListTile(
                            leading: Icon(Icons.slideshow_rounded),
                            title: Text('Choose File'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text('Maximum file size: 100MB, 60 Seconds'),
                // if (_thumbnailFile != null)
                //   Image.file(
                //     File(_thumbnailFile!.path),
                //     width: 100,
                //     height: 100,
                //   ),
              ],
            ),
          ),
        ),

        Center(
          child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
              ? FutureBuilder<void>(
                  future: retrieveLostData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return const Text(
                              'You have not yet picked an image.',
                              textAlign: TextAlign.center,
                            );
                          case ConnectionState.done:
                            return _handlePreview();
                          case ConnectionState.active:
                            if (snapshot.hasError) {
                              return Text(
                                'Pick image/video error: ${snapshot.error}}',
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return const Text(
                                'You have not yet picked an image.',
                                textAlign: TextAlign.center,
                              );
                            }
                        }
                      },
                )
              : _handlePreview(),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, {super.key});

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          // aspectRatio: controller!.value.aspectRatio,
          aspectRatio: 2,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}

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
