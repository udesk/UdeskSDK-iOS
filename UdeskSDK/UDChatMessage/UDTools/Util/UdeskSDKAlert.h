//
//  UdeskSDKAlert.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/16.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskSDKAlert : NSObject

//提示
+ (void)showWithMsg:(NSString *)message;
+ (void)showWithTitle:(NSString *)title message:(NSString *)message handler:(void(^)(void))handler;
//视频超过最大限制
+ (void)showBigVideoPoint;
//黑名单
+ (void)showBlacklisted:(NSString *)message handler:(void(^)(void))handler;

//根据客服code显示
+ (void)showWithAgentCode:(NSInteger)agentCode message:(NSString *)message enableFeedback:(BOOL)enableFeedback leaveMsgHandler:(void(^)(void))leaveMsgHandler;

+ (void)hide;

@end
