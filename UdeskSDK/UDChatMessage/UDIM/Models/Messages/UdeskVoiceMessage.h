//
//  UdeskVoiceMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

/** 语音时长 height */
extern const CGFloat kUDVoiceDurationLabelHeight;
/** 聊天气泡和其中语音播放图片水平间距 */
extern const CGFloat kUDBubbleToAnimationVoiceImageHorizontalSpacing;
/** 聊天气泡和其中语音播放图片垂直间距 */
extern const CGFloat kUDBubbleToAnimationVoiceImageVerticalSpacing;
/** 语音气泡最大长度 */
extern const CGFloat kUDCellBubbleVoiceMaxContentWidth;
/** 语音气泡最小长度 */
extern const CGFloat kUDCellBubbleVoiceMinContentWidth;
/** 语音播放图片 width */
extern const CGFloat kUDAnimationVoiceImageViewWidth;
/** 语音播放图片 height */
extern const CGFloat kUDAnimationVoiceImageViewHeight;

@interface UdeskVoiceMessage : UdeskBaseMessage

/** 语音播放image */
@property (nonatomic, strong) UIImage         *animationVoiceImage;
/** 语音播放动画图片数组 */
@property (nonatomic, strong) NSMutableArray  *animationVoiceImages;
//语音动画frame
@property (nonatomic, assign, readonly) CGRect  voiceAnimationFrame;
//语音时长frame
@property (nonatomic, assign, readonly) CGRect  voiceDurationFrame;

@end
