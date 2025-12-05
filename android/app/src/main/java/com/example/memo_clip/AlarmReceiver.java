package com.example.memo_clip;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import androidx.core.app.NotificationCompat;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;


public class AlarmReceiver extends BroadcastReceiver {
    private static final String TAG = "AlarmReceiver";
    public static final String ACTION_ALARM_DATA = "com.memo_clip.AlarmReceiver";

    // Notification channel ID for Android 8.0+
    private static final String NOTIFICATION_CHANNEL_ID = "alarm_notifications";
    
    // Notification ID to update or cancel specific notifications
    private static final int NOTIFICATION_ID = 1001;

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(TAG, "Alarm triggered");

        // Extract data from intent
        int alarmId = intent.getIntExtra("alarmId", -1);
        String videoUrl = intent.getStringExtra("videoUrl");
        String title = intent.getStringExtra("title");

        Log.d(TAG, "Alarm ID: " + alarmId + ", Video: " + videoUrl);

        boolean isWeb = videoUrl.startsWith("https") || videoUrl.startsWith("http");

        if(isWeb && !isInternetAvailable()) {
            // GUI notification
        showNotification(context, title," Verify your connection to continue", videoUrl);
        // Also print to console
        System.out.println("[ERROR] Internet connection is unavailable");
            return ;
        }

        // Check if the Flutter app is currently running
        // if (isAppRunning(context))
        // If MainActivity.methodChannel is NOT null, the app is in memory (Foreground or Background)
          if (MainActivity.methodChannel != null)   {
            // If app is running (foreground or background), try to send data to Main Activity
             // Send broadcast directly to MainActivity
        Intent broadcastIntent = new Intent(ACTION_ALARM_DATA);
        broadcastIntent.putExtra("videoUrl", videoUrl);
        broadcastIntent.putExtra("title", title);
        broadcastIntent.putExtra("alarmId", alarmId);
        broadcastIntent.putExtra("timestamp", System.currentTimeMillis());
        broadcastIntent.setPackage(context.getPackageName());

        context.sendBroadcast(broadcastIntent);

        Log.d(TAG, "Data broadcast send successfully");
        } 
        else {
        // ALWAYS show a notification regardless of app state
        // This ensures the user sees the alarm even if Flutter communication fails
        showNotification(context, title, "Tap to open and play your video", videoUrl);
        }       

        // Launch PiP Video Activity
        // Intent pipIntent = new Intent(context, PipVideoActivity.class);
        // pipIntent.putExtra("videoUrl", videoUrl);
        // pipIntent.putExtra("title", title);
        // pipIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        
        // context.startActivity(pipIntent);
    }

     public static boolean isInternetAvailable() {
        try {
            // Try to reach a well-known, highly available server like Google's DNS server
            InetAddress address = InetAddress.getByName("8.8.8.8");
            // Attempt to reach the address within a timeout (e.g., 5 seconds)
            return address.isReachable(5000); 
        } catch (UnknownHostException e) {
            // Host is unknown, likely no internet or DNS resolution issue
            return false;
        } catch (IOException e) {
            // Other IO errors, like network unreachable
            return false;
        }
    }

        /**
     * Checks if the Flutter application is currently running (foreground or background).
     * This helps determine if we should attempt to communicate with Flutter.
     */
    private boolean isAppRunning(Context context) {
        // Get the ActivityManager to check running processes
        android.app.ActivityManager activityManager = 
            (android.app.ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        
        // Get list of currently running app processes
        java.util.List<android.app.ActivityManager.RunningAppProcessInfo> appProcesses = 
            activityManager.getRunningAppProcesses();
        
        // If no processes are running, return false
        if (appProcesses == null) {
            return false;
        }
        
        // Get your app's package name
        String packageName = context.getPackageName();
        
        // Loop through running processes to find our app
        for (android.app.ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
            // Check if our app's package name matches and the process is in a usable state
            if (appProcess.processName.equals(packageName) && 
                appProcess.importance <= android.app.ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                return true; // App is running
            }
        }
        
        return false; // App is not running
    }


        /**
     * Creates and displays a notification that opens the app when clicked.
     * This method works regardless of whether the app is running or terminated.
     */
    private void showNotification(Context context, String title, String body, String videoUrl) {
        // Get the NotificationManager system service
        NotificationManager notificationManager = 
            (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        
        initializeNotificationChannel(notificationManager);
        
        // Create an intent to launch your PipVideo activity when notification is clicked
        // Intent notificationIntent = new Intent(context, MainActivity.class);
        Intent notificationIntent = new Intent(context, PipVideoActivity.class);
        notificationIntent.putExtra("videoUrl", videoUrl);
        notificationIntent.putExtra("title", title);
        
        // Add flags to control how the activity is launched
        notificationIntent.setFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK |      // Create new task if needed
            Intent.FLAG_ACTIVITY_CLEAR_TOP       // Clear other activities on top
        );
        
        
        // Create a PendingIntent that wraps the intent
        // This allows the notification to launch our app on behalf of the user
        PendingIntent pendingIntent = PendingIntent.getActivity(
            context,
            0,                                    // Request code
            notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT |  // Update existing intent if present
            PendingIntent.FLAG_IMMUTABLE         // Required for Android 12+
        );
        
        // Build the notification using NotificationCompat for backwards compatibility
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)// .setSmallIcon(R.drawable.ic_notification)  // Small icon (required) - you need to add this icon
            .setContentTitle("🎬 Time to Watch Video!")                     // Notification title
            .setContentText(body)                       // Notification body text
            .setPriority(NotificationCompat.PRIORITY_HIGH) // Priority for Android 7.1 and below
            .setCategory(NotificationCompat.CATEGORY_ALARM) // Categorize as alarm
            .setAutoCancel(true)                        // Auto dismiss when clicked
            .setContentIntent(pendingIntent)            // Set the intent to launch when clicked
            .setVibrate(new long[]{0, 500, 200, 500})  // Vibration pattern
            .setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI); // Notification sound
        
        // Optional: Add action buttons to the notification
        // builder.addAction(R.drawable.ic_dismiss, "Dismiss", dismissIntent);
        
        
        // Display the notification
        notificationManager.notify(NOTIFICATION_ID, builder.build());
    }

    public static void initializeNotificationChannel(NotificationManager notificationManager) {  
        // Create notification channel for Android 8.0 (API 26) and above
        // Channels are required for notifications on newer Android versions
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                NOTIFICATION_CHANNEL_ID,           // Unique channel ID
                "Alarm Notifications",             // Channel name visible to user
                NotificationManager.IMPORTANCE_HIGH // High importance for alarm notifications
            );
            
            // Configure channel properties
            channel.setDescription("Notifications for alarms"); // Channel description
            channel.enableVibration(true);                       // Enable vibration
            channel.enableLights(true);                          // Enable notification light
            
            // Register the channel with the system
            notificationManager.createNotificationChannel(channel);
        }
    }
}
