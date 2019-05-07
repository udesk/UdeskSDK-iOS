//
//  UdeskVoiceMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVoiceMessage.h"
#import "UdeskBundleUtils.h"
#import "UdeskVoiceCell.h"
#import "UdeskCacheUtil.h"

/** 语音时长 height */
static CGFloat const kUDVoiceDurationLabelHeight = 15.0;
/** 聊天气泡和其中语音播放图片水平间距 */
static CGFloat const kUDBubbleToAnimationVoiceImageHorizontalSpacing     = 16.0f;
/** 聊天气泡和其中语音播放图片垂直间距 */
static CGFloat const kUDBubbleToAnimationVoiceImageVerticalSpacing     = 10.0f;
/** 动画和时长的间距 */
static CGFloat const kUDReceiveAnimationToDurationHorizontalSpacing     = 9.0f;
/** 动画和时长的间距 */
static CGFloat const kUDSendAnimationToDurationHorizontalSpacing     = 14.0f;
/** 聊天气泡和其中语音时长垂直间距 */
static CGFloat const kUDBubbleToDurationVerticalSpacing     = 11.0f;
/** 语音播放图片 width */
static CGFloat const kUDAnimationVoiceImageViewWidth     = 18.0f;
/** 语音播放图片 height */
static CGFloat const kUDAnimationVoiceImageViewHeight    = 18.0f;
/** 语音气泡最小长度 */
static CGFloat const kUDCellBubbleVoiceMinContentWidth = 68;
/** 语音气泡最大长度 */
static CGFloat const kUDCellBubbleVoiceMaxContentWidth = 150.0;
/** 语音气泡高度 */
static CGFloat const kUDCellBubbleVoiceHeight = 38;
/** 语音气泡长度 */
static CGFloat const kUDCellVoiceDurationWidth = 30;

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
        
        if (message.sourceData && message.messageId) {
            //语音缓存
            [[UdeskCacheUtil sharedManager] setObject:message.sourceData forKey:message.messageId];
        }
        
        [self getAnimationVoiceImages];
        [self layoutVoiceMessage];
    }
    return self;
}

- (void)layoutVoiceMessage {

    
    CGSize voiceSize = CGSizeMake(kUDCellBubbleVoiceMinContentWidth, kUDAvatarDiameter);
    if (self.message.duration) {
        voiceSize = CGSizeMake(kUDCellBubbleVoiceMinContentWidth + self.message.duration*2.75f, kUDAvatarDiameter);
        if (voiceSize.width>kUDCellBubbleVoiceMaxContentWidth) {
            voiceSize = CGSizeMake(kUDCellBubbleVoiceMaxContentWidth, kUDAvatarDiameter);
        }
    }
    
    switch (self.message.messageFrom) {
        case UDMessageTypeSending:{
            
            CGFloat bubbleX = UD_SCREEN_WIDTH-kUDBubbleToHorizontalEdgeSpacing-voiceSize.width-kUDBubbleToAnimationVoiceImageHorizontalSpacing;
            //语音气泡frame
            self.bubbleFrame = CGRectMake(bubbleX, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, voiceSize.width+kUDBubbleToAnimationVoiceImageHorizontalSpacing, kUDCellBubbleVoiceHeight);
            //发送的语音播放动画图片
            self.voiceAnimationFrame = CGRectMake(CGRectGetWidth(self.bubbleFrame)-kUDAnimationVoiceImageViewWidth-kUDBubbleToAnimationVoiceImageHorizontalSpacing, kUDBubbleToAnimationVoiceImageVerticalSpacing, kUDAnimationVoiceImageViewWidth, kUDAnimationVoiceImageViewHeight);
            //语音时长frame
            self.voiceDurationFrame = CGRectMake(CGRectGetMidX(self.voiceAnimationFrame)-kUDSendAnimationToDurationHorizontalSpacing-kUDCellVoiceDurationWidth, kUDBubbleToDurationVerticalSpacing, kUDCellVoiceDurationWidth, kUDVoiceDurationLabelHeight);
            //发送中
            self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败
            self.failureFrame = self.loadingFrame;
            
            break;
        }
        case UDMessageTypeReceiving:{
            
            CGFloat bubbleHeight = kUDCellBubbleVoiceHeight;
            CGFloat bubbleWidth = voiceSize.width+kUDBubbleToAnimationVoiceImageHorizontalSpacing;
            CGFloat voiceAnimationY = kUDBubbleToAnimationVoiceImageVerticalSpacing;
            CGFloat voiceDurationY = kUDBubbleToDurationVerticalSpacing;
            
            if (self.message.showUseful) {
                bubbleHeight = kUDAnswerBubbleMinHeight;
                bubbleWidth = (310.0/375.0) * UD_SCREEN_WIDTH;
                voiceAnimationY = (kUDAnswerBubbleMinHeight-kUDAnimationVoiceImageViewHeight)/2;
                voiceDurationY = (kUDAnswerBubbleMinHeight-kUDVoiceDurationLabelHeight)/2;
            }
            
            //接收的语音气泡frame
            self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, bubbleWidth, bubbleHeight);
            //发送的语音播放动画图片
            self.voiceAnimationFrame = CGRectMake(kUDBubbleToAnimationVoiceImageHorizontalSpacing,voiceAnimationY, kUDAnimationVoiceImageViewWidth, kUDAnimationVoiceImageViewHeight);
            //接收的语音时长frame
            self.voiceDurationFrame = CGRectMake(CGRectGetMaxX(self.voiceAnimationFrame)+kUDReceiveAnimationToDurationHorizontalSpacing,voiceDurationY, kUDCellVoiceDurationWidth, kUDVoiceDurationLabelHeight);
            
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
