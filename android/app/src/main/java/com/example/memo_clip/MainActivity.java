package com.example.memo_clip;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;    
import android.provider.Settings;
import androidx.annotation.NonNull;
import java.util.Calendar;
import java.util.Map;
import java.util.HashMap;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "memoclip.app/video_alarm_channel";
    private MethodChannel methodChannel;
    private BroadcastReceiver alarmBroadcastReceiver;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

       methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
            
       methodChannel.setMethodCallHandler(
                (call, result) -> {
            switch (call.method) {
                case "scheduleAlarm":
                    handleScheduleAlarm(call.arguments, result);
                    break;
                case "cancelAlarm":
                    handleCancelAlarm(call.arguments, result);
                    break;
                case "checkExactAlarmPermission":
                    checkExactAlarmPermission(result);
                    break;
                case "requestExactAlarmPermission":
                    requestExactAlarmPermission(result);
                    break;
                default:
                    result.notImplemented();
                    break;
            }
                });

        // Register broadcast receiver for alarm notifications
        setupBroadcastReceiver();
    }

/**
 * Setup broadcast receiver to listen for alarm triggers and send data to Flutter
 */
private void setupBroadcastReceiver() {
    alarmBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (AlarmReceiver.ACTION_ALARM_DATA.equals(intent.getAction())) {
                Log.d("MainActivity", "Broadcast received in MainActivity");
                
                final String videoUrl = intent.getStringExtra("videoUrl");
                final String title = intent.getStringExtra("title");
                final int alarmId = intent.getIntExtra("alarmId", -1);
                final long timestamp = intent.getLongExtra("timestamp", 0);

                Log.d("MainActivity", "Extracted data - ID: " + alarmId + ", Title: " + title);

                // Post to main/UI thread
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        if (methodChannel == null) {
                            Log.e("MainActivity", "ERROR: methodChannel is NULL!");
                            return;
                        }
                        
                        // Prepare data to send to Flutter
                        Map<String, Object> data = new HashMap<>();
                        data.put("videoUrl", videoUrl);
                        data.put("title", title);
                        data.put("alarmId", alarmId);
                        data.put("timestamp", timestamp);
                        data.put("receivedAt", System.currentTimeMillis());
                        
                        Log.d("MainActivity", "Calling Flutter method with data: " + data);
                        
                        try {
                            methodChannel.invokeMethod("onAlarmTriggered", data);
                            Log.d("MainActivity", "Flutter method invoked successfully!");
                        } catch (Exception e) {
                            Log.e("MainActivity", "Error invoking Flutter: " + e.getMessage());
                            e.printStackTrace();
                        }
                    }
                });
            }
        }
    };

    IntentFilter filter = new IntentFilter(AlarmReceiver.ACTION_ALARM_DATA);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        registerReceiver(alarmBroadcastReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
    } else {
        registerReceiver(alarmBroadcastReceiver, filter);
    }
    
    Log.d("MainActivity", "Broadcast receiver registered successfully");
}

        private void handleScheduleAlarm(Object arguments, MethodChannel.Result result) {
        try {
            Map<String, Object> args = (Map<String, Object>) arguments;
            int alarmId = (int) args.get("alarmId");
            long triggerTimeMillis = ((Number) args.get("triggerTimeMillis")).longValue();
            String videoUrl = (String) args.get("videoUrl");
            String title = (String) args.get("title");

            AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
            
            // Create intent for AlarmReceiver
            Intent intent = new Intent(this, AlarmReceiver.class);
            intent.putExtra("alarmId", alarmId);
            intent.putExtra("videoUrl", videoUrl);
            intent.putExtra("title", title);
            intent.setAction("com.yourapp.ALARM_TRIGGER_" + alarmId);

            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                this,
                alarmId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );

            // Schedule exact alarm
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                );
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                );
            }
            // System.out.println("Scheduled alarm ID: " + alarmId + " at " + triggerTimeMillis);
            result.success("Alarm scheduled successfully for ID: " + alarmId);
        } catch (Exception e) {
            result.error("SCHEDULE_ERROR", e.getMessage(), null);
        }
    }

        private void handleCancelAlarm(Object arguments, MethodChannel.Result result) {
        try {
            int alarmId = (int) arguments;
            AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
            
            Intent intent = new Intent(this, AlarmReceiver.class);
            intent.setAction("com.yourapp.ALARM_TRIGGER_" + alarmId);
            
            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                this,
                alarmId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );

            alarmManager.cancel(pendingIntent);
            pendingIntent.cancel();

            result.success("Alarm cancelled successfully");
        } catch (Exception e) {
            result.error("CANCEL_ERROR", e.getMessage(), null);
        }
    }
                
        private void checkExactAlarmPermission(MethodChannel.Result result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
            result.success(alarmManager.canScheduleExactAlarms());
        } else {
            result.success(true); // Permission not needed on older versions
        }
    }

        private void requestExactAlarmPermission(MethodChannel.Result result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Intent intent = new Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM);
            startActivity(intent);
            result.success(null);
        } else {
            result.success(null);
        }
    }
}


                