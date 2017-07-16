//
//  UdeskResendManager.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/27.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UdeskMessage;

@interface UdeskResendManager : NSObject

#pragma mark - 重发失败的消息
+ (void)resendFailedMessage:(NSMutableArray *)resendMessageArray
                 completion:(void(^)(UdeskMessage *failedMessage,BOOL sendStatus))completion;

@end
