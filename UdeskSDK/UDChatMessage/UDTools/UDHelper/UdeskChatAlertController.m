//
//  UdeskChatAlertController.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/17.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskChatAlertController.h"
#import "UdeskAlertController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "UdeskTicketViewController.h"
#import "UdeskSDKShow.h"
#import "UdeskOverlayTransitioningDelegate.h"
#import "UdeskTools.h"

@interface UdeskChatAlertController()

@property (nonatomic, strong) UdeskOverlayTransitioningDelegate *transitioningDelegate;

@end

@implementation UdeskChatAlertController {

    UdeskAlertController *queueAlert;
    UdeskAlertController *sessionOverAlert;
}

#pragma mark - Alert
//排队Alert
- (void)showQueueStatusAlertWithMessage:(NSString *)message
                    enableWebImFeedback:(BOOL)enableWebImFeedback {
    
    if (queueAlert) {
        return;
    }
    
    NSString *ticketButtonTitle = getUDLocalizedString(@"udesk_leave_msg");
    queueAlert = [UdeskAlertController alertControllerWithTitle:ticketButtonTitle message:message preferredStyle:UDAlertControllerStyleAlert];
    
    [queueAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_cancel") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
        
        queueAlert = nil;
    }]];

    if (enableWebImFeedback) {
    
        @udWeakify(self);
        [queueAlert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
            
            queueAlert = nil;
            @udStrongify(self);
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(didSelectSendTicket)]) {
                    [self.delegate didSelectSendTicket];
                }
            }
        }]];
    }
    
    [self presentViewController:queueAlert];
}

//客服不在线Alert
- (void)showAgentNotOnlineAlert {

    NSString *title = getUDLocalizedString(@"udesk_agent_offline");
    NSString *message = getUDLocalizedString(@"udesk_alert_view_leave_msg");
    NSString *cancelButtonTitle = getUDLocalizedString(@"udesk_cancel");
    NSString *ticketButtonTitle = getUDLocalizedString(@"udesk_leave_msg");
    
    UdeskAlertController *notOnlineAlert = [UdeskAlertController alertControllerWithTitle:title message:message preferredStyle:UDAlertControllerStyleAlert];
    
    [notOnlineAlert addAction:[UdeskAlertAction actionWithTitle:cancelButtonTitle style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
    }]];
    
    @udWeakify(self);
    [notOnlineAlert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
        
        @udStrongify(self);
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didSelectSendTicket)]) {
                [self.delegate didSelectSendTicket];
            }
        }
    }]];
    
    [self presentViewController:notOnlineAlert];
}

//客服不在线Alert
- (void)showAgentNotOnlineAlertWithMessage:(NSString *)message
                       enableWebImFeedback:(BOOL)enableWebImFeedback {

    NSString *title = getUDLocalizedString(@"udesk_agent_offline");
    NSString *cancelButtonTitle = getUDLocalizedString(@"udesk_cancel");
    NSString *ticketButtonTitle = getUDLocalizedString(@"udesk_leave_msg");
    if ([UdeskTools isBlankString:message]) {
        message = getUDLocalizedString(@"udesk_alert_view_leave_msg");
    }
    
    UdeskAlertController *notOnlineAlert = [UdeskAlertController alertControllerWithTitle:title message:message preferredStyle:UDAlertControllerStyleAlert];
    [notOnlineAlert addAction:[UdeskAlertAction actionWithTitle:cancelButtonTitle style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
    }]];
    
    if (enableWebImFeedback) {
        @udWeakify(self);
        [notOnlineAlert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
            
            @udStrongify(self);
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(didSelectSendTicket)]) {
                    [self.delegate didSelectSendTicket];
                }
            }
        }]];
    }
    
    [self presentViewController:notOnlineAlert];
}

//无网络Alert
- (void)showNetWorkDisconnectAlert {

    UdeskAlertController *notNetworkAlert = [UdeskAlertController alertControllerWithTitle:nil message:getUDLocalizedString(@"udesk_network_disconnect") preferredStyle:UDAlertControllerStyleAlert];
    [notNetworkAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_cancel") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:notNetworkAlert];
}

//不存在客服或客服组
- (void)showNotExistAgentAlert:(NSString *)message {
    
    UdeskAlertController *notExistAgentAlert = [UdeskAlertController alertControllerWithTitle:nil message:message preferredStyle:UDAlertControllerStyleAlert];
    [notExistAgentAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:notExistAgentAlert];
}

//黑名单
- (void)showIsBlacklistedAlert:(NSString *)message {
    
    if ([UdeskTools isBlankString:message]) {
        message = getUDLocalizedString(@"udesk_alert_view_blocked_list");
    }
    
    UdeskAlertController *blacklisted = [UdeskAlertController alertControllerWithTitle:nil message:message preferredStyle:UDAlertControllerStyleAlert];
    
    @udWeakify(self);
    [blacklisted addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
        @udStrongify(self);
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didSelectBlacklistedAlertViewOkButton)]) {
                [self.delegate didSelectBlacklistedAlertViewOkButton];
            }
        }
    }]];
    
    [blacklisted addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:blacklisted];
}

//未知错误
- (void)showNotConnectedAlert {

    UdeskAlertController *notExistAgentAlert = [UdeskAlertController alertControllerWithTitle:nil message:getUDLocalizedString(@"udesk_connecting_agent") preferredStyle:UDAlertControllerStyleAlert];
    [notExistAgentAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:notExistAgentAlert];
}

- (void)showBigVideoPoint {

    UdeskAlertController *bigVideoAlert = [UdeskAlertController alertControllerWithTitle:nil message:getUDLocalizedString(@"udesk_video_big_tips") preferredStyle:UDAlertControllerStyleAlert];
    [bigVideoAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:bigVideoAlert];
}

//评价提交成功Alert
- (void)surveyCompletion {
    
    UdeskAlertController *completionAlert = [UdeskAlertController alertControllerWithTitle:nil message:getUDLocalizedString(@"udesk_thanks") preferredStyle:UDAlertControllerStyleAlert];
    [completionAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:completionAlert];
}

//客服重连Alert
- (void)requestAgentAgain {
    
    //已经弹出不用再弹
    if (sessionOverAlert) {
        return;
    }
    sessionOverAlert = [UdeskAlertController alertControllerWithTitle:nil message:getUDLocalizedString(@"udesk_reassign_agent") preferredStyle:UDAlertControllerStyleAlert];
    [sessionOverAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
        sessionOverAlert = nil;
    }]];
    
    [self presentViewController:sessionOverAlert];
}

- (void)showAlertWithMessage:(NSString *)message {

    UdeskAlertController *agentAlert = [UdeskAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UDAlertControllerStyleAlert];
    [agentAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:agentAlert];
}

- (void)presentViewController:(UdeskAlertController *)alertController {
    
    if ([[UdeskTools currentViewController] isKindOfClass:[UdeskAlertController class]]) {
        sessionOverAlert = nil;
        queueAlert = nil;
        return;
    }
    
    if (ud_isIOS7 && [[[UIDevice currentDevice]systemVersion] floatValue] < 8.0) {
        _transitioningDelegate = [[UdeskOverlayTransitioningDelegate alloc] init];
        alertController.modalPresentationStyle = UIModalPresentationCustom;
        alertController.transitioningDelegate = _transitioningDelegate;
    }
    
    [[UdeskTools currentViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showChatAlertViewWithCode:(NSInteger)code
                       andMessage:(NSString *)message
              enableWebImFeedback:(BOOL)enableWebImFeedback {

    if (code == 2002) {
        //客服不在线提示
        [self showAgentNotOnlineAlertWithMessage:message enableWebImFeedback:enableWebImFeedback];
    }
    else if (code == 2003) {
        //无网络提示
        [self showNetWorkDisconnectAlert];
    }
    else if (code == 2001) {
        //排队提示
        [self showQueueStatusAlertWithMessage:message enableWebImFeedback:enableWebImFeedback];
    }
    else if (code == 2004) {
        //重新分配客服提示
        [self requestAgentAgain];
    }
    else if (code == 5050) {
        //客服或客服组不存在提示
        [self showNotExistAgentAlert:getUDLocalizedString(@"udesk_agent_not_exist")];
    }
    else if (code == 5060) {
        //客服或客服组不存在提示
        [self showNotExistAgentAlert:getUDLocalizedString(@"udesk_group_not_exist")];
    }
    else {
        //正在连接提示
        [self showNotConnectedAlert];
    }
}

- (void)hideAlert {

    if ([[UdeskTools currentViewController] isKindOfClass:[UdeskAlertController class]]) {
        if (sessionOverAlert || queueAlert) {
         
            [[UdeskTools currentViewController] dismissViewControllerAnimated:YES completion:nil];
            sessionOverAlert = nil;
            queueAlert = nil;
        }
    }
}

@end
