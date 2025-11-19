package com.example.memo_clip;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

public class AlarmReceiver extends BroadcastReceiver {
    private static final String TAG = "AlarmReceiver";
    public static final String ACTION_ALARM_DATA = "com.memo_clip.AlarmReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(TAG, "Alarm triggered");

        // Extract data from intent
        int alarmId = intent.getIntExtra("alarmId", -1);
        String videoUrl = intent.getStringExtra("videoUrl");
        String title = intent.getStringExtra("title");

        Log.d(TAG, "Alarm ID: " + alarmId + ", Video: " + videoUrl);

        // Send broadcase directly to MainActivity
        Intent broadcastIntent = new Intent(ACTION_ALARM_DATA);
        broadcastIntent.putExtra("videoUrl", videoUrl);
        broadcastIntent.putExtra("title", title);
        broadcastIntent.putExtra("alarmId", alarmId);
        broadcastIntent.putExtra("timestamp", System.currentTimeMillis());
        broadcastIntent.setPackage(context.getPackageName());

        context.sendBroadcast(broadcastIntent);

        Log.d(TAG, "Data broadcast send successfully");

        // Launch PiP Video Activity
        // Intent pipIntent = new Intent(context, PipVideoActivity.class);
        // pipIntent.putExtra("videoUrl", videoUrl);
        // pipIntent.putExtra("title", title);
        // pipIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        
        // context.startActivity(pipIntent);
    }
}
