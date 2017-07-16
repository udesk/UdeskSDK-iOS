//
//  UdeskVoiceCell.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseCell.h"

@interface UdeskVoiceCell : UdeskBaseCell

/** 语音时长 */
@property (nonatomic, strong) UILabel *voiceDurationTextLabel;
/** 语音动画图片 */
@property (nonatomic, strong) UIImageView *voiceAnimationImageView;

@end
