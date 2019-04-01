//
//  UdeskLinkMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskLinkMessage : UdeskBaseMessage

//消息的文字
@property (nonatomic, copy  , readonly) NSAttributedString *attributedString;
//文本frame
@property (nonatomic, assign, readonly) CGRect textFrame;

@end
