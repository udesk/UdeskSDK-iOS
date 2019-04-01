//
//  UdeskRichMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/16.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskRichMessage : UdeskBaseMessage

/** 消息的文字 */
@property (nonatomic, copy  , readonly) NSAttributedString *attributedString;
//文本frame(包括下方留白)
@property (nonatomic, assign, readonly) CGRect  richTextFrame;

@end
