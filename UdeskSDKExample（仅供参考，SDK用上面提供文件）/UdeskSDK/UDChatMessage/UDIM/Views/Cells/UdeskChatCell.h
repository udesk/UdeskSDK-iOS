//
//  UdeskChatCell.h
//  UdeskSDK
//
//  Created by xuchen on 16/8/15.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseCell.h"
@class UdeskChatMessage;

@interface UdeskChatCell : UdeskBaseCell

/** 发送失败 */
@property (nonatomic, strong) UIImageView             *failureImageView;
/** 发送中 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
/** 语音时长 */
@property (nonatomic, strong) UILabel                 *voiceDurationLabel;

@end
