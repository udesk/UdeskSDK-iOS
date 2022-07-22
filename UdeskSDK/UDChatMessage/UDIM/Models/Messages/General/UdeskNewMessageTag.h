//
//  UdeskNewMessageTag.h
//  UdeskSDK
//
//  Created by 姚光辉 on 2022/5/9.
//  Copyright © 2022 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface UdeskNewMessageTag : UdeskBaseMessage

/** 提示文字Frame */
@property (nonatomic, assign, readonly) CGRect newLabelFrame;

@end

NS_ASSUME_NONNULL_END
