//
//  UdeskAudioPlayerHelper.h
//  UdeskSDK
//
//  Created by xuchen on 15/6/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@protocol UDAudioPlayerHelperDelegate <NSObject>

@optional

- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer;

@end

@interface UdeskAudioPlayerHelper : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, assign) id <UDAudioPlayerHelperDelegate> delegate;

+ (id)shareInstance;

- (AVAudioPlayer*)player;
- (BOOL)isPlaying;
- (void)stopAudio;//停止
- (void)playAudioWithVoiceData:(NSData *)voiceData;

@end


