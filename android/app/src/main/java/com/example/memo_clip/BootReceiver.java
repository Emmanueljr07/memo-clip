package com.example.memo_clip;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {
    private static final String TAG = "BootReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            System.out.println("Boot completed received");
            Log.d(TAG, "Device booted - reschedule alarms here");
            
            // You would typically:
            // 1. Read saved alarm data from SharedPreferences or database
            // 2. Reschedule each alarm using AlarmManager
            // This requires storing alarm details persistently in MainActivity
        }
    }
}