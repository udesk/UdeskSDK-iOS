//
//  UdeskListMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

/** 单个选项高度 */
extern const CGFloat kUDListHeight;

@interface UdeskListMessage : UdeskBaseMessage

@property (nonatomic, copy  , readonly) NSAttributedString *titleAttributedString;
@property (nonatomic, assign, readonly) CGRect titleFrame;
@property (nonatomic, assign, readonly) CGRect lineFrame;
@property (nonatomic, assign, readonly) CGRect listFrame;

@end
