//
//  UDAudioPlayerHelper.h
//  Udesk
//
//  Created by xuchen on 15/6/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "UDMessage.h"

@protocol UDAudioPlayerHelperDelegate <NSObject>

@optional
- (void)didAudioPlayerBeginPlay:(AVAudioPlayer*)audioPlayer;
- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer;
- (void)didAudioPlayerPausePlay:(AVAudioPlayer*)audioPlayer;

@end

@interface UDAudioPlayerHelper : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;
/**
 *  播放文件地址
 */
@property (nonatomic, copy) NSString *playingFileName;

@property (nonatomic, assign) id <UDAudioPlayerHelperDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *playingIndexPathInFeedList;//给动态列表用

+ (id)shareInstance;
/**
 *  语音播放对象
 *
 *  @return 语音对象
 */
- (AVAudioPlayer*)player;
/**
 *  查看是否在播放
 *
 *  @return 播放状态
 */
- (BOOL)isPlaying;
/**
 *  播放语音
 *
 *  @param message 播放的内容
 *  @param toPlay  是否在播放
 */
- (void)managerAudio:(UDMessage *)message toPlay:(BOOL)toPlay;
/**
 *  暂停播放
 */
- (void)pausePlayingAudio;
/**
 *  停止播放
 */
- (void)stopAudio;

@end


