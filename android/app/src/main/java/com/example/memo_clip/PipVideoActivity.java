package com.example.memo_clip;

import android.app.PictureInPictureParams;
import android.content.res.Configuration;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.util.Rational;
import android.view.View;
import android.widget.MediaController;
import android.widget.VideoView;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import android.app.Activity;

public class PipVideoActivity extends Activity {
    private static final String TAG = "PipVideoActivity";
    private VideoView videoView;
    private String videoUrl;
    private int currentPosition = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Create VideoView programmatically
        videoView = new VideoView(this);
        videoView.setLayoutParams(new android.view.ViewGroup.LayoutParams(
            android.view.ViewGroup.LayoutParams.MATCH_PARENT,
            android.view.ViewGroup.LayoutParams.MATCH_PARENT
        ));
        setContentView(videoView);

        // Get video URL from intent
        videoUrl = getIntent().getStringExtra("videoUrl");
        String title = getIntent().getStringExtra("title");

        if (videoUrl == null || videoUrl.isEmpty()) {
            Log.e(TAG, "No video URL provided");
            finish();
            return;
        }

        setupVideoView();
    }

    private void setupVideoView() {
        // Add media controls
        MediaController mediaController = new MediaController(this);
        mediaController.setAnchorView(videoView);
        videoView.setMediaController(mediaController);

        // Set video URI
        Uri videoUri = Uri.parse(videoUrl);
        videoView.setVideoURI(videoUri);

        // Setup listeners
        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                Log.d(TAG, "Video prepared, duration: " + mp.getDuration());
                videoView.start();
                
                // Enter PiP mode automatically after a short delay
                videoView.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        enterPipMode();
                    }
                }, 1000);
            }
        });

        videoView.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
                Log.e(TAG, "Video error: " + what + ", " + extra);
                return false;
            }
        });

        videoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                Log.d(TAG, "Video completed");
                finish();
            }
        });

        // Request focus and start loading
        videoView.requestFocus();
    }

    private void enterPipMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                Rational aspectRatio = new Rational(16, 9);
                PictureInPictureParams params = new PictureInPictureParams.Builder()
                    .setAspectRatio(aspectRatio)
                    .build();
                enterPictureInPictureMode(params);
            } catch (Exception e) {
                Log.e(TAG, "Failed to enter PiP mode", e);
            }
        }
    }

    @Override
    public void onUserLeaveHint() {
        super.onUserLeaveHint();
        // Enter PiP when user presses home button
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            enterPipMode();
        }
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, 
                                               Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        
        if (isInPictureInPictureMode) {
            Log.d(TAG, "Entered PiP mode");
            // Hide media controller in PiP mode
            videoView.setMediaController(null);
        } else {
            Log.d(TAG, "Exited PiP mode");
            // Restore media controller
            MediaController mediaController = new MediaController(this);
            mediaController.setAnchorView(videoView);
            videoView.setMediaController(mediaController);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (videoView != null && videoView.isPlaying()) {
            currentPosition = videoView.getCurrentPosition();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (currentPosition > 0 && videoView != null) {
            videoView.seekTo(currentPosition);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (videoView != null) {
            videoView.stopPlayback();
        }
    }
}
