#import "AudioRecorderAPI.h"
#import <Cordova/CDV.h>

@implementation AudioRecorderAPI

#define RECORDINGS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library/NoCloud"]

- (void)getDuration:(CDVInvokedUrlCommand*)command {
    
    // Ning Wei 20180903
    // Retrieving duration of an audio file
    @try {
        
        NSString* filePath = [command argumentAtIndex:0];
        
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
        CMTime audioDuration = audioAsset.duration;
        int audioDurationSeconds = (int) CMTimeGetSeconds(audioDuration);
        
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsInt:audioDurationSeconds];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId: command.callbackId];
    }
    @catch (NSException *exception) {
        
        NSLog(@"[AudioRecorderAPI] getDuration failed: %@", exception);
        
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:(NSString*)exception];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId: command.callbackId];
    }
    
    // END
}

- (void)checkPermission:(CDVInvokedUrlCommand*)command {
    
    // Ning Wei 20180717
    // Check permission of accessing microphone
    CDVPluginResult* pluginResult = nil;
    int checkReseult = 1000; // Defualt is GRANTED
    
    
    if([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionDenied){
        checkReseult = 1001;
    }
    
    if([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionUndetermined){
        checkReseult = 1002;
    }
    
    pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsInt:checkReseult];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId: command.callbackId];
    
    // END
}

- (void)record:(CDVInvokedUrlCommand*)command {
    _command = command;
    
    // Ning Wei 20180608
    // Load bitrate and duration from args
    
    duration = [NSNumber numberWithInt:7]; // Default is 7 secs.
    int bitrate = 32*1024; // Default is 32kbps
    
    if(_command.arguments.count >=1){
        duration = [_command.arguments objectAtIndex:0];
    }
    
    if(_command.arguments.count >=2){
        bitrate = [[_command.arguments objectAtIndex:1] intValue] * 1024;
    }
    
    // END
    
    [self.commandDelegate runInBackground:^{
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        NSError *err;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
        if (err)
        {
            NSLog(@"%@ %d %@", [err domain], [err code], [[err userInfo] description]);
        }
        err = nil;
        [audioSession setActive:YES error:&err];
        if (err)
        {
            NSLog(@"%@ %d %@", [err domain], [err code], [[err userInfo] description]);
        }
        
        NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
        
        // Ning Wei 20180608
        // Adapt different options for EncoderBitRate, default aac options for others.
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        
        [recordSettings setObject:[NSNumber numberWithInt:bitrate] forKey:AVEncoderBitRateKey];
        // END
        
        
        
        // Create a new dated file
        NSString *uuid = [[NSUUID UUID] UUIDString];
        recorderFilePath = [NSString stringWithFormat:@"%@/%@.m4a", RECORDINGS_FOLDER, uuid];
        NSLog(@"recording file path: %@", recorderFilePath);
        
        NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
        err = nil;
        recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&err];
        if(!recorder){
            NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return;
        }
        
        [recorder setDelegate:self];
        
        if (![recorder prepareToRecord]) {
            NSLog(@"prepareToRecord failed");
            return;
        }
        
        if (![recorder recordForDuration:(NSTimeInterval)[duration intValue]]) {
            NSLog(@"recordForDuration failed");
            return;
        }
        
    }];
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    _command = command;
    
    // Ning Wei 20180803
    // 先判断是否处于录制状态
    if(recorder && recorder.isRecording){
        
        NSLog(@"stopRecording");
        
        [recorder stop];
        
        NSLog(@"stopped");
        
    }else{
        NSLog(@"already stopped");
    }
    
    // END
}

- (void)playback:(CDVInvokedUrlCommand*)command {
    _command = command;
    [self.commandDelegate runInBackground:^{
        NSLog(@"recording playback");
        NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
        NSError *err;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
        player.numberOfLoops = 0;
        player.delegate = self;
        [player prepareToPlay];
        [player play];
        if (err) {
            NSLog(@"%@ %d %@", [err domain], [err code], [[err userInfo] description]);
        }
        NSLog(@"playing");
    }];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"audioPlayerDidFinishPlaying");
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"playbackComplete"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
    NSError *err = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if(!audioData) {
        NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    } else {
        NSLog(@"recording saved: %@", recorderFilePath);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:recorderFilePath];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
    }
}

@end
