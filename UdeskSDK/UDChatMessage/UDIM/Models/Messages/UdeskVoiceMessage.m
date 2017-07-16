//
//  UdeskVoiceMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVoiceMessage.h"
#import "UdeskUtils.h"
#import "UdeskVoiceCell.h"
#import "UdeskCaheHelper.h"

/** 语音时长 height */
const CGFloat kUDVoiceDurationLabelHeight = 15.0;
/** 聊天气泡和其中语音播放图片水平间距 */
const CGFloat kUDBubbleToAnimationVoiceImageHorizontalSpacing     = 20.0f;
/** 聊天气泡和其中语音播放图片垂直间距 */
const CGFloat kUDBubbleToAnimationVoiceImageVerticalSpacing     = 11.0f;
/** 语音播放图片 width */
const CGFloat kUDAnimationVoiceImageViewWidth     = 12.0f;
/** 语音播放图片 height */
const CGFloat kUDAnimationVoiceImageViewHeight    = 17.0f;
/** 语音气泡最小长度 */
const CGFloat kUDCellBubbleVoiceMinContentWidth = 50;
/** 语音气泡最大长度 */
const CGFloat kUDCellBubbleVoiceMaxContentWidth = 150.0;

@interface UdeskVoiceMessage()

//语音动画frame
@property (nonatomic, assign, readwrite) CGRect  voiceAnimationFrame;
//语音时长frame
@property (nonatomic, assign, readwrite) CGRect  voiceDurationFrame;

@end

@implementation UdeskVoiceMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        if (message.voiceData && message.messageId) {
            //语音缓存
            [[UdeskCaheHelper sharedManager] setObject:message.voiceData forKey:message.messageId];
        }
        
        [self getAnimationVoiceImages];
        [self layoutVoiceMessage];
    }
    return self;
}

- (void)layoutVoiceMessage {

    
    CGSize voiceSize = CGSizeMake(kUDCellBubbleVoiceMinContentWidth, kUDAvatarDiameter);
    if (self.message.voiceDuration) {
        voiceSize = CGSizeMake(kUDCellBubbleVoiceMinContentWidth + self.message.voiceDuration*3.5f, kUDAvatarDiameter);
        if (voiceSize.width>kUDCellBubbleVoiceMaxContentWidth) {
            voiceSize = CGSizeMake(kUDCellBubbleVoiceMaxContentWidth, kUDAvatarDiameter);
        }
    }
    
    switch (self.message.messageFrom) {
        case UDMessageTypeSending:
            
            //语音气泡frame
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDBubbleToAnimationVoiceImageHorizontalSpacing-kUDAvatarToBubbleSpacing-voiceSize.width, self.avatarFrame.origin.y, voiceSize.width+kUDBubbleToAnimationVoiceImageHorizontalSpacing, voiceSize.height);
            //语音时长frame
            self.voiceDurationFrame = CGRectMake(self.bubbleFrame.origin.x-kUDAvatarToBubbleSpacing-voiceSize.width, self.bubbleFrame.origin.y+kUDBubbleToAnimationVoiceImageVerticalSpacing, voiceSize.width, kUDVoiceDurationLabelHeight);
            //发送的语音播放动画图片
            self.voiceAnimationFrame = CGRectMake(self.bubbleFrame.size.width-kUDAnimationVoiceImageViewWidth-kUDArrowMarginWidth-kUDBubbleToAnimationVoiceImageVerticalSpacing, kUDBubbleToAnimationVoiceImageVerticalSpacing, kUDAnimationVoiceImageViewWidth, kUDAnimationVoiceImageViewHeight);
            //发送中
            self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败
            self.failureFrame = self.loadingFrame;
            
            break;
        case UDMessageTypeReceiving:{
            
            //接收的语音气泡frame
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, voiceSize.width+kUDBubbleToAnimationVoiceImageHorizontalSpacing, voiceSize.height);
            //接收的语音时长frame
            self.voiceDurationFrame = CGRectMake(self.bubbleFrame.origin.x+kUDAvatarToBubbleSpacing+self.bubbleFrame.size.width, self.bubbleFrame.origin.y+kUDBubbleToAnimationVoiceImageVerticalSpacing, voiceSize.width, kUDVoiceDurationLabelHeight);
            //发送的语音播放动画图片
            self.voiceAnimationFrame = CGRectMake(kUDBubbleToAnimationVoiceImageHorizontalSpacing,kUDBubbleToAnimationVoiceImageVerticalSpacing, kUDAnimationVoiceImageViewWidth, kUDAnimationVoiceImageViewHeight);
            
            break;
        }
            
        default:
            break;
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (void)getAnimationVoiceImages {
    
    @try {
        
        NSString *imageSepatorName;
        switch (self.message.messageFrom) {
            case UDMessageTypeSending:
                imageSepatorName = @"udSender";
                break;
            case UDMessageTypeReceiving:
                imageSepatorName = @"udReceiver";
                break;
            default:
                break;
        }
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger i = 1; i < 4; i ++) {
            UIImage *image = [UIImage imageWithContentsOfFile:getUDBundlePath([imageSepatorName stringByAppendingFormat:@"VoiceNodePlaying00%ld@2x.png", (long)i])];
            if (image)
                [images addObject:image];
        }
        
        self.animationVoiceImage = [UIImage imageWithContentsOfFile:getUDBundlePath([imageSepatorName stringByAppendingString:@"VoiceNodePlaying003@2x.png"])];
        self.animationVoiceImages = images;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
