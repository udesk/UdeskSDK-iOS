//
//  UdeskVideoCallMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/12/6.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskVideoCallMessage : UdeskBaseMessage

/** 消息的文字 */
@property (nonatomic, copy  , readonly) NSAttributedString *cellText;
//文本frame(包括下方留白)
@property (nonatomic, assign, readonly) CGRect  textFrame;

@end
