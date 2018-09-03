package com.emj365.plugins;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.pm.PackageManager;
import android.media.MediaMetadataRetriever;
import android.media.MediaRecorder;
import android.media.MediaPlayer;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Build;
import android.os.CountDownTimer;
import android.os.Environment;
import android.content.Context;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import java.util.UUID;
import java.io.FileInputStream;
import java.io.File;
import java.io.IOException;

public class AudioRecorderAPI extends CordovaPlugin {

  private MediaRecorder myRecorder;
  private String outputFile;
  private CountDownTimer countDowntimer;

  @Override
  public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
    Context context = cordova.getActivity().getApplicationContext();


    // Ning Wei 20180903
    // Retrieve duration
    if (action.equals("getDuration")) {

      try{

        String filePath;
        Integer durationInSecs;

        // 先判断入口参数
        if (args.length() >= 1) {

          filePath = args.getString(0);

          // 使用MediaMetadataRetriever获取音频时长，这个方法速度快，要求API>=10
          String mediaPath = Uri.parse(filePath).getPath();
          MediaMetadataRetriever mmr = new MediaMetadataRetriever();
          mmr.setDataSource(mediaPath);

          // 获取时长数据，单位是毫秒
          String durationMsStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);

          // 释放资源
          mmr.release();

          // 格式转换到秒
          durationInSecs = Integer.parseInt(durationMsStr)/1000;

          // 成功的回调
          callbackContext.success(durationInSecs);

        } else {

          // 参数为空时，记录日志并回调
          Log.e("AudioRecorderAPI","filePath is null");
          callbackContext.error("ARGUMENT IS NULL OR EMPTY: filePath");
        }

      }catch(Exception e){

        // 异常时，记录日志并回调
        Log.e("AudioRecorderAPI","Exception in getDuration: \r\n"+ e.toString());

        callbackContext.error(e.getMessage());
      }


    }
    // END

    // Ning Wei 20180717
    // Check permission
    if (action.equals("checkPermission")) {

	  int resultCode = 1000; // Default is GRANTED
	  
      // Targeting M and newer
      if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M){
        if(ContextCompat.checkSelfPermission(cordova.getActivity(),
                android.Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_DENIED){
                	resultCode = 1001;
                }
      }

      callbackContext.success(resultCode);
    }
    // END

    if (action.equals("record")) {

      // Ning Wei 20180608
      // Load bitrate from args[1]
      Integer seconds;

      if (args.length() >= 1) {
        seconds = args.getInt(0);
      } else {
        seconds = 7;
      }

      Integer bitrate = 32 * 1024; // Default is 32kbps
      if (args.length() >= 2) {
        bitrate = args.getInt(1) * 1024;
      }
      //END

      outputFile = context.getFilesDir().getAbsoluteFile() + "/"
              + UUID.randomUUID().toString() + ".m4a";
      myRecorder = new MediaRecorder();
      myRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
      myRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
      myRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
      myRecorder.setAudioSamplingRate(44100);
      myRecorder.setAudioChannels(1);

      // Ning Wei 20180608
      // Apply bit rate
      myRecorder.setAudioEncodingBitRate(bitrate);

      LOG.i("AudioRecorderAPI","AudioEncodingBitRate set to " + bitrate +"bps");
      // END

      myRecorder.setOutputFile(outputFile);

      try {
        myRecorder.prepare();
        myRecorder.start();
      } catch (final Exception e) {
        cordova.getThreadPool().execute(new Runnable() {
          public void run() {
            callbackContext.error(e.getMessage());
          }
        });
        return false;
      }

      countDowntimer = new CountDownTimer(seconds * 1000, 1000) {
        public void onTick(long millisUntilFinished) {}
        public void onFinish() {
          stopRecord(callbackContext);
        }
      };
      countDowntimer.start();
      return true;
    }

    if (action.equals("stop")) {
      countDowntimer.cancel();
      stopRecord(callbackContext);
      return true;
    }

    if (action.equals("playback")) {
      MediaPlayer mp = new MediaPlayer();
      mp.setAudioStreamType(AudioManager.STREAM_MUSIC);
      try {
        FileInputStream fis = new FileInputStream(new File(outputFile));
        mp.setDataSource(fis.getFD());
      } catch (IllegalArgumentException e) {
        e.printStackTrace();
      } catch (SecurityException e) {
        e.printStackTrace();
      } catch (IllegalStateException e) {
        e.printStackTrace();
      } catch (IOException e) {
        e.printStackTrace();
      }
      try {
        mp.prepare();
      } catch (IllegalStateException e) {
        e.printStackTrace();
      } catch (IOException e) {
        e.printStackTrace();
      }
      mp.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
        public void onCompletion(MediaPlayer mp) {
          callbackContext.success("playbackComplete");
        }
      });
      mp.start();
      return true;
    }

    return false;
  }

  private void stopRecord(final CallbackContext callbackContext) {
    myRecorder.stop();
    myRecorder.release();
    cordova.getThreadPool().execute(new Runnable() {
      public void run() {
        callbackContext.success(outputFile);
      }
    });
  }

}
