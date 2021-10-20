//
//  UdeskTextMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskTextMessage : UdeskBaseMessage

/** 消息的文字 */
@property (nonatomic, copy  , readonly) NSAttributedString *cellText;
//文本frame(包括下方留白)
@property (nonatomic, assign, readonly) CGRect  textFrame;
/** 需要高亮的文字 */
@property (nonatomic, strong) NSArray       *matchArray;
/** 高亮文字对应的超链接 */
@property (nonatomic, strong) NSDictionary  *richURLDictionary;
/** 高亮文字对应的超链接 */
@property (nonatomic, strong) NSDictionary  *numberRangeDic;

- (void)linkText:(NSString *)content;

@end
