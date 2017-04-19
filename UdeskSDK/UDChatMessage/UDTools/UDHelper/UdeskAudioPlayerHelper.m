//
//  UdeskAudioPlayerHelper.m
//  UdeskSDK
//
//  Created by Udesk on 15/6/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskAudioPlayerHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@implementation UdeskAudioPlayerHelper

#pragma mark - action

//播放转换后wav
- (void)playAudioWithVoiceData:(NSData *)voiceData {
    
    if (voiceData) {
        
        //不随着静音键和屏幕关闭而静音。code by Aevit
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        if (_player) {
            [_player stop];
            self.player = nil;
        }
        //播放语音
        [self playAudio:voiceData];
    }
}

- (void)playAudio:(NSData *)data {
    
    self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    self.player.delegate = self;
    [self.player play];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}

- (void)stopAudio {
    
    if (_player && _player.isPlaying) {
        [_player stop];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

#pragma mark - Getter

- (AVAudioPlayer*)player {
    return _player;
}

- (BOOL)isPlaying {
    if (!_player) {
        return NO;
    }
    return _player.isPlaying;
}

#pragma mark - Setter 

- (void)setDelegate:(id<UDAudioPlayerHelperDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        
        if (_delegate == nil) {
            [self stopAudio];
        }
    }
}

#pragma mark - Life Cycle

+ (id)shareInstance {
    static UdeskAudioPlayerHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UdeskAudioPlayerHelper alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self changeProximityMonitorEnableState:YES];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    return self;
}

- (void)dealloc {
    [self changeProximityMonitorEnableState:NO];
}

#pragma mark - audio delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {

    @try {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didAudioPlayerStopPlay:)]) {
                [self.delegate didAudioPlayerStopPlay:_player];
            }
        }
    } @catch (NSException *exception) {
    } @finally {
    }
}

#pragma mark - 近距离传感器

- (void)changeProximityMonitorEnableState:(BOOL)enable {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        if (enable) {
            
            //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
            
        } else {
            
            //删除近距离事件监听
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

- (void)sensorStateChange:(NSNotificationCenter *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        //黑屏
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    } else {
        //没黑屏幕
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_player || !_player.isPlaying) {
            //没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

@end
