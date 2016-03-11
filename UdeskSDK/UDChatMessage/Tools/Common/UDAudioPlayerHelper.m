//
//  UDAudioPlayerHelper.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDAudioPlayerHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "UDCache.h"

@implementation UDAudioPlayerHelper

#pragma mark - Public Methed

- (void)managerAudio:(UDMessage *)message toPlay:(BOOL)toPlay {
    if (toPlay) {
        [self playAudioWithFileName:message];
    } else {
        [self pausePlayingAudio];
    }
}

//暂停
- (void)pausePlayingAudio {
    if (_player) {
        [_player pause];
        if ([self.delegate respondsToSelector:@selector(didAudioPlayerPausePlay:)]) {
            [self.delegate didAudioPlayerPausePlay:_player];
        }
    }
}

- (void)stopAudio {
    [self setPlayingFileName:@""];
    [self setPlayingIndexPathInFeedList:nil];
    if (_player && _player.isPlaying) {
        [_player stop];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerStopPlay:)]) {
        [self.delegate didAudioPlayerStopPlay:_player];
    }
}

#pragma mark - action

//播放转换后wav
- (void)playAudioWithFileName:(UDMessage *)message {
    if (message.contentId.length > 0) {
        
        //不随着静音键和屏幕关闭而静音。code by Aevit
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        if (_playingFileName && [message.contentId isEqualToString:_playingFileName]) {//上次播放的录音
            if (_player) {
                [_player play];
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                if ([self.delegate respondsToSelector:@selector(didAudioPlayerBeginPlay:)]) {
                    [self.delegate didAudioPlayerBeginPlay:_player];
                }
            }
        } else {//不是上次播放的录音
            if (_player) {
                [_player stop];
                self.player = nil;
            }
    
            NSData *audioData = [[UDCache sharedUDCache] dataFromDiskCacheForKey:message.contentId];
            
            if (audioData) {
                [self playAudio:audioData];
            }
            else {
                
                NSString *newURL = [message.voiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:newURL]];
                
                NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    
                    if (data) {
                        
                        [self playAudio:data];
                        
                        [[UDCache sharedUDCache] storeData:data forKey:message.contentId];
                    }
                    
                }];
                
                [dataTask resume];
                
            }
            
            
        }
        self.playingFileName = message.contentId;
    }
}

- (void)playAudio:(NSData *)data {

    self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    self.player.delegate = self;
    [self.player play];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerBeginPlay:)]) {
        [self.delegate didAudioPlayerBeginPlay:_player];
    }

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
    static UDAudioPlayerHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UDAudioPlayerHelper alloc] init];
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
    [self stopAudio];
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerStopPlay:)]) {
        [self.delegate didAudioPlayerStopPlay:_player];
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
