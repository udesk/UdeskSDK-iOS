//
//  UdeskVoiceCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVoiceCell.h"
#import "UdeskVoiceMessage.h"
#import "UdeskSDKConfig.h"
#import "UdeskCacheUtil.h"
#import "UdeskAudioPlayer.h"

#define VoicePlayHasInterrupt @"VoicePlayHasInterrupt"

@interface UdeskVoiceCell()<UDAudioPlayerHelperDelegate> {

    BOOL _contentVoiceIsPlaying;
    /** 语音时长 */
    UILabel *_voiceDurationTextLabel;
    /** 语音动画图片 */
    UIImageView *_voiceAnimationImageView;
}

@end

@implementation UdeskVoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initVoiceAnimationImageView];
        [self initVoiceDurationTextLabel];
        [self initVoiceBubbleGesture];
    }
    return self;
}

- (void)initVoiceBubbleGesture {
    
    //长按手势
    UITapGestureRecognizer *tapPressBubbleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoicePlay:)];
    tapPressBubbleGesture.cancelsTouchesInView = false;
    [self.bubbleImageView addGestureRecognizer:tapPressBubbleGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVAudioPlayerDidFinishPlay) name:VoicePlayHasInterrupt object:nil];
    _contentVoiceIsPlaying = NO;
}

- (void)tapVoicePlay:(UITapGestureRecognizer *)tap {

    //获取语音文件
    [self getVoiceData];
    
    UdeskAudioPlayer *playerHelper = [UdeskAudioPlayer shared];
    
    if (!_contentVoiceIsPlaying) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VoicePlayHasInterrupt object:nil];
        _contentVoiceIsPlaying = YES;
        [_voiceAnimationImageView startAnimating];
        playerHelper.delegate = self;
        [playerHelper playAudioWithVoiceData:self.baseMessage.message.voiceData];
    }
    else {
        
        [self AVAudioPlayerDidFinishPlay];
    }
}

- (void)AVAudioPlayerDidFinishPlay {
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [_voiceAnimationImageView stopAnimating];
    _contentVoiceIsPlaying = NO;
    [[UdeskAudioPlayer shared] stopAudio];
}

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    
    [_voiceAnimationImageView stopAnimating];
    _contentVoiceIsPlaying = NO;
}

- (void)initVoiceAnimationImageView {

    _voiceAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _voiceAnimationImageView.animationDuration = 1.0;
    _voiceAnimationImageView.userInteractionEnabled = YES;
    [_voiceAnimationImageView stopAnimating];
    
    [self.bubbleImageView addSubview:_voiceAnimationImageView];
}

- (void)initVoiceDurationTextLabel {

    _voiceDurationTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _voiceDurationTextLabel.font = [UIFont systemFontOfSize:14.f];
    _voiceDurationTextLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_voiceDurationTextLabel];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {

    [super updateCellWithMessage:baseMessage];
    
    UdeskVoiceMessage *voiceMessage = (UdeskVoiceMessage *)baseMessage;
    if (!voiceMessage || ![voiceMessage isKindOfClass:[UdeskVoiceMessage class]]) return;
    
    //语音时长
    if (voiceMessage.message.voiceDuration==0) {
        
        //获取语音文件
        [self getVoiceData];
        AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithData:voiceMessage.message.voiceData error:nil];
        //语音时长
        NSString *voiceDuration = [NSString stringWithFormat:@"%.f",play.duration];
        _voiceDurationTextLabel.text = [NSString stringWithFormat:@"%.f\'\'", voiceDuration.floatValue];
    }
    else {
        _voiceDurationTextLabel.text = [NSString stringWithFormat:@"%.f\'\'", voiceMessage.message.voiceDuration];
    }
    
    //语音播放动画
    _voiceAnimationImageView.hidden = NO;
    _voiceAnimationImageView.image = voiceMessage.animationVoiceImage;
    _voiceAnimationImageView.animationImages = voiceMessage.animationVoiceImages;
    
    //语音播放图片
    _voiceAnimationImageView.frame = voiceMessage.voiceAnimationFrame;
    _voiceDurationTextLabel.frame = voiceMessage.voiceDurationFrame;
    
    //昵称
    if (voiceMessage.message.messageFrom == UDMessageTypeReceiving) {
        
        _voiceDurationTextLabel.textColor = [UdeskSDKConfig customConfig].sdkStyle.agentVoiceDurationColor;
        _voiceDurationTextLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    else {
        
        _voiceDurationTextLabel.textColor = [UdeskSDKConfig customConfig].sdkStyle.customerVoiceDurationColor;
        _voiceDurationTextLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (void)getVoiceData {

    @try {
        
        UdeskVoiceMessage *voiceMessage = (UdeskVoiceMessage *)self.baseMessage;
        if (!voiceMessage || ![voiceMessage isKindOfClass:[UdeskVoiceMessage class]]) return;
        
        if (!voiceMessage.message.voiceData) {
            if (![[UdeskCacheUtil sharedManager] containsObjectForKey:voiceMessage.message.messageId]) {
                NSString *content = [voiceMessage.message.content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url = [[NSURL alloc]initWithString:content];
                NSData *audioData = [NSData dataWithContentsOfURL:url];
                voiceMessage.message.voiceData = audioData;
                
                [[UdeskCacheUtil sharedManager] setObject:audioData forKey:voiceMessage.message.messageId];
            }
            else {
                voiceMessage.message.voiceData = (NSData *)[[UdeskCacheUtil sharedManager] objectForKey:voiceMessage.message.messageId];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VoicePlayHasInterrupt object:nil];
}

@end
