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
#import "UdeskChatViewController.h"
#import "NSAttributedString+UdeskHTML.h"

@implementation UdeskSDKAlert 

//提示
+ (void)showWithMessage:(NSString *)message handler:(void(^)(void))handler {
    
    UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:nil attributedMessage:[[NSAttributedString alloc] initWithString:message] preferredStyle:UdeskAlertControllerStyleAlert];
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UdeskAlertActionStyleDefault handler:^(UdeskAlertAction *action) {
        if (handler) {
            handler();
        }
    }]];
    [self presentViewController:alert];
}

//提示
+ (void)showWithTitle:(NSString *)title message:(NSString *)message handler:(void(^)(void))handler {
    
    UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:title attributedMessage:[[NSAttributedString alloc] initWithString:message] preferredStyle:UdeskAlertControllerStyleAlert];
    
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") style:UdeskAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
        if (handler) {
            handler();
        }
    }]];
    
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UdeskAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert];
}

//根据客服code显示
+ (void)showWithAgentCode:(NSInteger)agentCode message:(NSString *)message enableFeedback:(BOOL)enableFeedback leaveMsgHandler:(void(^)(void))leaveMsgHandler {
    
    if (agentCode == 2002) {
        //客服不在线提示
        [self showAgentOfflineWithMessage:message enableFeedback:enableFeedback leaveMsgHandler:leaveMsgHandler];
    }
    else if (agentCode == 2003) {
        //无网络提示
        [self showWithMessage:getUDLocalizedString(@"udesk_network_disconnect") handler:nil];
    }
    else if (agentCode == 2001) {
        //排队提示
        [self showQueueWithMessage:message enableFeedback:enableFeedback leaveMsgHandler:leaveMsgHandler];
    }
    else if (agentCode == 2004) {
        //重新分配客服提示
        [self showWithMessage:getUDLocalizedString(@"udesk_reassign_agent") handler:nil];
    }
    else if (agentCode == 5050) {
        //客服或客服组不存在提示
        [self showWithMessage:getUDLocalizedString(@"udesk_agent_not_exist") handler:nil];
    }
    else if (agentCode == 5060) {
        //客服或客服组不存在提示
        [self showWithMessage:getUDLocalizedString(@"udesk_group_not_exist") handler:nil];
    }
    else {
        //正在连接提示
        [self showWithMessage:getUDLocalizedString(@"udesk_connecting") handler:nil];
    }
}

//客服不在线Alert
+ (void)showAgentOfflineWithMessage:(NSString *)message enableFeedback:(BOOL)enableFeedback leaveMsgHandler:(void(^)(void))leaveMsgHandler {
    
    if ([UdeskSDKUtil isBlankString:message]) {
        message = getUDLocalizedString(@"udesk_alert_view_leave_msg");
    }
    
    NSAttributedString *attriStr = [NSAttributedString attributedStringFromHTML:message customFont:[UIFont systemFontOfSize:15]];

    NSString *title = getUDLocalizedString(@"udesk_leave_msg");
    if (!enableFeedback) {
        title = @"";
    }
    NSString *cancelButtonTitle = getUDLocalizedString(@"udesk_close");
    NSString *ticketButtonTitle = getUDLocalizedString(@"udesk_leave_msg");
    
    UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:title attributedMessage:attriStr preferredStyle:UdeskAlertControllerStyleAlert];
    [alert addAction:[UdeskAlertAction actionWithTitle:cancelButtonTitle style:UdeskAlertActionStyleDefault handler:nil]];
    
    if (enableFeedback) {
        [alert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle style:UdeskAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
            if (leaveMsgHandler) {
                leaveMsgHandler();
            }
        }]];
    }
    
    [self presentViewController:alert];
}

//排队Alert
+ (void)showQueueWithMessage:(NSString *)message enableFeedback:(BOOL)enableFeedback leaveMsgHandler:(void(^)(void))leaveMsgHandler {
    
    UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:nil attributedMessage:[[NSAttributedString alloc] initWithString:message] preferredStyle:UdeskAlertControllerStyleAlert];
    
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UdeskAlertActionStyleDefault handler:nil]];
    
    if (enableFeedback) {
        [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_leave_msg") style:UdeskAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
            if (leaveMsgHandler) {
                leaveMsgHandler();
            }
        }]];
    }
    
    [self presentViewController:alert];
}

+ (void)presentViewController:(UdeskAlertController *)alertController {
    
    if ([[UdeskSDKUtil currentViewController] isKindOfClass:[UdeskAlertController class]]) {
        [[UdeskSDKUtil currentViewController] dismissViewControllerAnimated:YES completion:^{
            [[UdeskSDKUtil currentViewController] presentViewController:alertController animated:YES completion:nil];
        }];
        return;
    }
    
    if (![[UdeskSDKUtil currentViewController] isKindOfClass:[UdeskChatViewController class]]) {
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
