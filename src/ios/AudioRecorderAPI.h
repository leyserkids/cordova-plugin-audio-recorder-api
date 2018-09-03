#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecorderAPI : CDVPlugin {
    NSString *recorderFilePath;
    NSNumber *duration;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    CDVPluginResult *pluginResult;
    CDVInvokedUrlCommand *_command;
}

// Ning Wei 20180717
// New function for checking permission
- (void)checkPermission:(CDVInvokedUrlCommand*)command;
// Ning Wei 20180903
// New function for retrieving duration
- (void)getDuration:(CDVInvokedUrlCommand*)command;
- (void)record:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;
- (void)playback:(CDVInvokedUrlCommand*)command;

@end
