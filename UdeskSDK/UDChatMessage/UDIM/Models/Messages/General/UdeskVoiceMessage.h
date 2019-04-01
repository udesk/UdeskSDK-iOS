//
//  UdeskVoiceMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

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
