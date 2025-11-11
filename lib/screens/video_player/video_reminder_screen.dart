// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:memo_clip/models/reminder_item.dart';
// import 'package:memo_clip/screens/video_player/video_player.dart';
// import 'package:memo_clip/services/background_video_service.dart';

// class VideoReminderScreen extends StatefulWidget {
//   const VideoReminderScreen({super.key});

//   @override
//   State<VideoReminderScreen> createState() => _VideoReminderScreenState();
// }

// class _VideoReminderScreenState extends State<VideoReminderScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     await BackgroundVideoService.initialize();

//     // Set up notification tap handler
//     BackgroundVideoService.notificationsPlugin
//         .getNotificationAppLaunchDetails()
//         .then((details) {
//           if (details?.didNotificationLaunchApp ?? false) {
//             _handleNotificationPayload(details!.payload);
//           }
//         });

//     // Listen for new notifications while app is running
//     BackgroundVideoService.notificationsPlugin
//         .initialize(
//           const InitializationSettings(
//             android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//           ),
//         )
//         .then((_) {
//           BackgroundVideoService.notificationsPlugin.stream.listen((
//             notificationResponse,
//           ) {
//             if (notificationResponse.payload != null) {
//               _handleNotificationPayload(notificationResponse.payload!);
//             }
//           });
//         });
//   }

//   void _handleNotificationPayload(String? payload) {
//     if (payload != null) {
//       final video = ReminderItem.fromJson(json.decode(payload));
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => VideoPlayerScreen(videoItem: video),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Video Reminders')),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: _viewScheduledVideos,
//             child: const Text('View Scheduled Videos'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _viewScheduledVideos() async {
//     final videos = await BackgroundVideoService.getScheduledVideos();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Scheduled Videos'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: videos.length,
//             itemBuilder: (context, index) {
//               final video = videos[index];
//               return ListTile(
//                 title: Text(video.title),
//                 subtitle: Text('Scheduled: ${video.scheduledTime.toString()}'),
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }
