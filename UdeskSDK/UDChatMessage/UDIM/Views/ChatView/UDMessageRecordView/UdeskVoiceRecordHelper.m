//
//  UdeskVoiceRecordHelper.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskVoiceRecordHelper.h"
#import "UdeskTools.h"
#import "UdeskFoundationMacro.h"

@interface UdeskVoiceRecordHelper () <AVAudioRecorderDelegate> {
    NSTimer *_timer;
    
    //记录是否暂停
    BOOL _isPause;
    
}
/**
 *  语音录入地址
 */
@property (nonatomic, copy, readwrite) NSString *recordPath;
/**
 *  当前语音时间
 */
@property (nonatomic, readwrite) NSTimeInterval currentTimeInterval;


@end

@implementation UdeskVoiceRecordHelper

- (id)init {
    self = [super init];
    if (self) {
        self.maxRecordTime = UdeskVoiceRecorderTotalTime;
        self.recordDuration = @"0";

    }
    return self;
}

- (void)dealloc {
    [self stopRecord];
    self.recordPath = nil;
}

- (void)resetTimer {
    if (!_timer)
        return;
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
}
//取消录音
- (void)cancelRecording {
    if (!_recorder)
        return;
    
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    
    self.recorder = nil;
}
//停止录音
- (void)stopRecord {
    [self cancelRecording];
    [self resetTimer];
}

//获取地址
- (NSString *)getRecorderPath {
    
    NSString *indetAAC = [NSString stringWithFormat:@"%@.aac",[UdeskTools soleString]];
    
    NSString *recorderPath = [NSTemporaryDirectory() stringByAppendingPathComponent:indetAAC];
    
    return recorderPath;
}
//录音准备工作，配置录音
- (void)prepareRecordingCompletion:(UDPrepareRecorderCompletion)completion {
    
    @udWeakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            
            _isPause = NO;
            
            NSError *error = nil;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&error];
            if(error) {
                return;
            }
            
            error = nil;
            [audioSession setActive:YES error:&error];
            if(error) {
                return;
            }
            
            NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
            [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
            [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
            [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
            
            if (self) {
                @udStrongify(self);
                self.recordPath = [self getRecorderPath];
                error = nil;
                
                if (self.recorder) {
                    [self cancelRecording];
                } else {
                    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordPath] settings:recordSetting error:&error];
                    self.recorder.delegate = self;
                    [self.recorder prepareToRecord];
                    self.recorder.meteringEnabled = YES;
                    [self.recorder recordForDuration:(NSTimeInterval) 160];
                    
                }
                
                if(error) {
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //上层如果传回来说已经取消了，那这边就坐原先取消的动作
                    if (!completion()) {
                        [self cancelledDeleteWithCompletion:^{
                        }];
                    }
                });
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    });
}
//开始录音
- (void)startRecordingWithStartRecorderCompletion:(UDStartRecorderCompletion)startRecorderCompletion {
    if ([_recorder record]) {
        [self resetTimer];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
        if (startRecorderCompletion)
            dispatch_async(dispatch_get_main_queue(), ^{
                if (startRecorderCompletion) {
                    startRecorderCompletion();
                }
            });
    }
}
//恢复录音
- (void)resumeRecordingWithResumeRecorderCompletion:(UDResumeRecorderCompletion)resumeRecorderCompletion {
    _isPause = NO;
    if (_recorder) {
        if ([_recorder record]) {
            dispatch_async(dispatch_get_main_queue(), resumeRecorderCompletion);
        }
    }
}
//暂停录音
- (void)pauseRecordingWithPauseRecorderCompletion:(UDPauseRecorderCompletion)pauseRecorderCompletion {
    _isPause = YES;
    if (_recorder) {
        [_recorder pause];
    }
    if (!_recorder.isRecording)
        dispatch_async(dispatch_get_main_queue(), pauseRecorderCompletion);
}
//停止录音
- (void)stopRecordingWithStopRecorderCompletion:(UDStopRecorderCompletion)stopRecorderCompletion {
    _isPause = NO;
    [self stopRecord];
    [self getVoiceDuration:_recordPath];
//    if (self.currentTimeInterval>1.5f) {
    dispatch_async(dispatch_get_main_queue(), ^{
        stopRecorderCompletion();
    });
//        dispatch_async(dispatch_get_main_queue(), stopRecorderCompletion);
//    }
//    else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.tooShortRecorderFailue();
//        });
//    }
    
}
//取消录音
- (void)cancelledDeleteWithCompletion:(UDCancellRecorderDeleteFileCompletion)cancelledDeleteCompletion {
    
    _isPause = NO;
    [self stopRecord];
    
    if (self.recordPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cancelledDeleteCompletion) {
                cancelledDeleteCompletion(nil);
            }
        });
    }
}

- (void)updateMeters {
    
    @try {
        
        if (!_recorder)
            return;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_recorder updateMeters];
            
            self.currentTimeInterval = _recorder.currentTime;
            
            if (!_isPause) {
                float progress = self.currentTimeInterval / self.maxRecordTime * 1.0;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_recordProgress) {
                        _recordProgress(progress);
                    }
                });
            }
            
            float peakPower = [_recorder averagePowerForChannel:0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新扬声器
                if (_peakPowerForChannel) {
                    _peakPowerForChannel(peakPower);
                }
            });
            
            if (self.currentTimeInterval > self.maxRecordTime) {
                [self stopRecord];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _maxTimeStopRecorderCompletion();
                });
            }
        });
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
    
}
//获取语音时长
- (void)getVoiceDuration:(NSString*)recordPath {
    NSError *error = nil;
    AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordPath] error:&error];
    if (error) {
        self.recordDuration = @"";
    } else {
        self.recordDuration = [NSString stringWithFormat:@"%.f", play.duration];
    }
}

- (void)tooShortRecordWithFailue:(UDTooShortRecorderFailue)tooShortRecorderFailue {

    _tooShortRecorderFailue = tooShortRecorderFailue;
}

@end
