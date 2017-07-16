//
//  UdeskEventMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/4/25.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@class UdeskMessage;

@interface UdeskEventMessage : UdeskBaseMessage

/** 提示文字Frame */
@property (nonatomic, assign, readonly) CGRect eventLabelFrame;

@end
