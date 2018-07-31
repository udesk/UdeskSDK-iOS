//
//  UdeskSDKAlert.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/16.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSDKAlert.h"
#import "UdeskAlertController.h"
#import "UdeskSDKUtil.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKMacro.h"

@implementation UdeskSDKAlert 

//提示
+ (void)showWithMsg:(NSString *)message {
    
    UdeskAlertController *agentAlert = [UdeskAlertController alertControllerWithTitle:nil attributedMessage:[[NSAttributedString alloc] initWithString:message] preferredStyle:UDAlertControllerStyleAlert];
    [agentAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:nil]];
    [self presentViewController:agentAlert];
}

//提示
+ (void)showWithTitle:(NSString *)title message:(NSString *)message handler:(void(^)(void))handler {
    
    UdeskAlertController *blacklisted = [UdeskAlertController alertControllerWithTitle:title attributedMessage:[[NSAttributedString alloc] initWithString:message] preferredStyle:UDAlertControllerStyleAlert];
    
    [blacklisted addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
        if (handler) {
            handler();
        }
    }]];
    
    [blacklisted addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:nil]];
    [self presentViewController:blacklisted];
}

//黑名单
+ (void)showBlacklisted:(NSString *)message handler:(void(^)(void))handler {
    
    if ([UdeskSDKUtil isBlankString:message]) {
        message = getUDLocalizedString(@"udesk_alert_view_blocked_list");
    }
    
    [self showWithTitle:nil message:message handler:handler];
}

//视频超过最大限制
+ (void)showBigVideoPoint {
    
    [self showWithMsg:getUDLocalizedString(@"udesk_video_big_tips")];
}

//根据客服code显示
+ (void)showWithAgentCode:(NSInteger)agentCode message:(NSString *)message enableFeedback:(BOOL)enableFeedback leaveMsgHandler:(void(^)(void))leaveMsgHandler {
    
    if (agentCode == 2002) {
        //客服不在线提示
        [self showAgentOfflineWithMessage:message enableFeedback:enableFeedback leaveMsgHandler:leaveMsgHandler];
    }
    else if (agentCode == 2003) {
        //无网络提示
        [self showWithMsg:getUDLocalizedString(@"udesk_network_disconnect")];
    }
    else if (agentCode == 2001) {
        //排队提示
        [self showQueueWithMessage:message enableFeedback:enableFeedback leaveMsgHandler:leaveMsgHandler];
    }
    else if (agentCode == 2004) {
        //重新分配客服提示
        [self showWithMsg:getUDLocalizedString(@"udesk_reassign_agent")];
    }
    else if (agentCode == 5050) {
        //客服或客服组不存在提示
        [self showWithMsg:getUDLocalizedString(@"udesk_agent_not_exist")];
    }
    else if (agentCode == 5060) {
        //客服或客服组不存在提示
        [self showWithMsg:getUDLocalizedString(@"udesk_group_not_exist")];
    }
    else {
        //正在连接提示
        [self showWithMsg:getUDLocalizedString(@"udesk_connecting_agent")];
    }
}

//客服不在线Alert
+ (void)showAgentOfflineWithMessage:(NSString *)message enableFeedback:(BOOL)enableFeedback leaveMsgHandler:(void(^)(void))leaveMsgHandler {
    
    if ([UdeskSDKUtil isBlankString:message]) {
        message = getUDLocalizedString(@"udesk_alert_view_leave_msg");
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAgentOfflineWithAttributedMessage:[UdeskSDKUtil attributedStringWithHTML:message] enableFeedback:enableFeedback leaveMsgHandler:leaveMsgHandler];
        });
    }
    else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSAttributedString *attri = [UdeskSDKUtil attributedStringWithHTML:message];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAgentOfflineWithAttributedMessage:attri enableFeedback:enableFeedback leaveMsgHandler:leaveMsgHandler];
            });
        });
    }
}

+ (void)showAgentOfflineWithAttributedMessage:(NSAttributedString *)attributedMessage enableFeedback:(BOOL)enableFeedback leaveMsgHandler:(void(^)(void))leaveMsgHandler {
    
    NSString *title = getUDLocalizedString(@"udesk_leave_msg");
    if (!enableFeedback) {
        title = @"";
    }
    NSString *cancelButtonTitle = getUDLocalizedString(@"udesk_close");
    NSString *ticketButtonTitle = getUDLocalizedString(@"udesk_leave_msg");
    
    UdeskAlertController *notOnlineAlert = [UdeskAlertController alertControllerWithTitle:title attributedMessage:attributedMessage preferredStyle:UDAlertControllerStyleAlert];
    [notOnlineAlert addAction:[UdeskAlertAction actionWithTitle:cancelButtonTitle style:UDAlertActionStyleDefault handler:nil]];
    
    if (enableFeedback) {
        [notOnlineAlert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
            if (leaveMsgHandler) {
                leaveMsgHandler();
            }
        }]];
    }
    
    [self presentViewController:notOnlineAlert];
}

//排队Alert
+ (void)showQueueWithMessage:(NSString *)message enableFeedback:(BOOL)enableFeedback leaveMsgHandler:(void(^)(void))leaveMsgHandler {
    
    NSString *title = getUDLocalizedString(@"udesk_leave_msg");
    
    UdeskAlertController *queueAlert = [UdeskAlertController alertControllerWithTitle:@"" attributedMessage:[[NSAttributedString alloc] initWithString:message] preferredStyle:UDAlertControllerStyleAlert];
    
    [queueAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:nil]];
    
    if (enableFeedback) {
        [queueAlert addAction:[UdeskAlertAction actionWithTitle:title style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
            if (leaveMsgHandler) {
                leaveMsgHandler();
            }
        }]];
    }
    
    [self presentViewController:queueAlert];
}

+ (void)presentViewController:(UdeskAlertController *)alertController {
    
    if ([[UdeskSDKUtil currentViewController] isKindOfClass:[UdeskAlertController class]]) {
        [[UdeskSDKUtil currentViewController] dismissViewControllerAnimated:YES completion:^{
            [[UdeskSDKUtil currentViewController] presentViewController:alertController animated:YES completion:nil];
        }];
        return;
    }

    [[UdeskSDKUtil currentViewController] presentViewController:alertController animated:YES completion:nil];
}

+ (void)hide {
    
    if ([[UdeskSDKUtil currentViewController] isKindOfClass:[UdeskAlertController class]]) {
        [[UdeskSDKUtil currentViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
