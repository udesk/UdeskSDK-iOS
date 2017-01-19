//
//  UdeskTipsMessage.h
//  UdeskSDK
//
//  Created by xuchen on 16/8/12.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseMessage.h"

@class UdeskMessage;

@interface UdeskTipsMessage : UdeskBaseMessage

/** 提示文字 */
@property (nonatomic, copy) NSString *tipText;

/** 提示文字Frame */
@property (nonatomic, assign, readonly) CGRect   tipLabelFrame;

- (instancetype)initWithUdeskMessage:(UdeskMessage *)message;

@end
