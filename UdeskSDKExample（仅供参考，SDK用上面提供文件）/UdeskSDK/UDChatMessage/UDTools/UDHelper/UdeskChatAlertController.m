//
//  UdeskChatAlertController.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/17.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskChatAlertController.h"
#import "UdeskAlertController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "UDStatus.h"
#import "ZKAlertController.h"

@implementation UdeskChatAlertController

#pragma mark - Alert
//排队Alert
- (void)showQueueStatusAlert {

    NSString *mesage = nil;
    if (![UDStatus shareInstance].enable_web_im_feedback) {
        mesage = [[NSUserDefaults standardUserDefaults] objectForKey:@"agentMessage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UdeskAlertController *queueAlert = [UdeskAlertController alertWithTitle:nil message:mesage];
        [queueAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_cancel") Handler:NULL];

        [queueAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    }else{
        mesage  = getUDLocalizedString(@"udesk_alert_view_agent_busy_leave_msg");
        NSString *ticketButtonTitle = getUDLocalizedString(@"udesk_leave_msg");
        UdeskAlertController *queueAlert = [UdeskAlertController alertWithTitle:nil message:mesage];
        [queueAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_cancel") Handler:NULL];
        @udWeakify(self);
        [queueAlert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle handler:^(UdeskAlertAction * _Nonnull action) {

            @udStrongify(self);
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(didSelectSendTicket)]) {
                    [self.delegate didSelectSendTicket];
                }
            }
        }]];

        [queueAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    }

//        NSString *ticketButtonTitle = getUDLocalizedString(@"udesk_leave_msg");
//        UdeskAlertController *queueAlert = [UdeskAlertController alertWithTitle:nil message:mesage];
//        [queueAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_cancel") Handler:NULL];
//        @udWeakify(self);
//        [queueAlert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle handler:^(UdeskAlertAction * _Nonnull action) {
//
//            @udStrongify(self);
//            if (self.delegate) {
//                if ([self.delegate respondsToSelector:@selector(didSelectSendTicket)]) {
//                    [self.delegate didSelectSendTicket];
//                }
//            }
//        }]];
//
//        [queueAlert showWithSender:nil controller:nil animated:YES completion:NULL];

}

//客服不在线Alert
- (void)showAgentNotOnlineAlert {

    if (![UDStatus shareInstance].enable_web_im_feedback) {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAgentNotOnlineAlert" object:nil];

    } else {
        NSString *message = getUDLocalizedString(@"udesk_alert_view_leave_msg");
        NSString *title = getUDLocalizedString(@"udesk_agent_offline");
        //NSString *message = getUDLocalizedString(@"udesk_alert_view_leave_msg");
        NSString *cancelButtonTitle = getUDLocalizedString(@"udesk_cancel");
        NSString *ticketButtonTitle = getUDLocalizedString(@"udesk_leave_msg");

        UdeskAlertController *notOnlineAlert = [UdeskAlertController alertWithTitle:title message:message];
        [notOnlineAlert addCloseActionWithTitle:cancelButtonTitle Handler:NULL];

        @udWeakify(self);
        [notOnlineAlert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle handler:^(UdeskAlertAction * _Nonnull action) {

            @udStrongify(self);
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(didSelectSendTicket)]) {
                    [self.delegate didSelectSendTicket];
                }
            }
        }]];
        
        [notOnlineAlert showWithSender:nil controller:nil animated:YES completion:NULL];

    }

}

//无网络Alert
- (void)showNetWorkDisconnectAlert {

    UdeskAlertController *notNetworkAlert = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"udesk_network_disconnect")];
    [notNetworkAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_sure") Handler:NULL];
    [notNetworkAlert showWithSender:nil controller:nil animated:YES completion:NULL];
}

//不存在客服或客服组
- (void)showNotExistAgentAlert:(NSString *)message {
    
    UdeskAlertController *notExistAgentAlert = [UdeskAlertController alertWithTitle:nil message:message];
    [notExistAgentAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_sure") Handler:NULL];
    [notExistAgentAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    
}

//黑名单
- (void)showIsBlacklistedAlert {
    
    UdeskAlertController *blacklisted = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"udesk_alert_view_blocked_list")];
    
    @udWeakify(self);
    [blacklisted addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") handler:^(UdeskAlertAction * _Nonnull action) {
        @udStrongify(self);
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didSelectBlacklistedAlertViewOkButton)]) {
                [self.delegate didSelectBlacklistedAlertViewOkButton];
            }
        }
    }]];
    
    [blacklisted addCloseActionWithTitle:getUDLocalizedString(@"udesk_close") Handler:nil];
    
    [blacklisted showWithSender:nil controller:nil animated:YES completion:NULL];
}

//未知错误
- (void)showNotConnectedAlert {

    if ([UDStatus shareInstance].no_reply_hint.length) {

          [[NSNotificationCenter defaultCenter] postNotificationName:@"showNotInworkTime" object:nil];
        NSLog(@"%s",__func__);

//        UdeskAlertController *notExistAgentAlert = [UdeskAlertController alertWithTitle:nil message:[UDStatus shareInstance].no_reply_hint];
//        [notExistAgentAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_sure") Handler:NULL];
//        [notExistAgentAlert showWithSender:nil controller:nil animated:YES completion:NULL];

    }else{

#warning  添加点击去留言界面的实现方法
        NSLog(@"%s",__func__);

        [[NSNotificationCenter defaultCenter] postNotificationName:@"showNotInworkTime" object:nil];
        
//        UdeskAlertController *notExistAgentAlert = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"udesk_alert_view_leave_msg")];;
//        [notExistAgentAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_sure") Handler:NULL];
//        [notExistAgentAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    }
}

//评价提交成功Alert
- (void)surveyCompletion {
    
    UdeskAlertController *completionAlert = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"udesk_thanks")];
    [completionAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_close") Handler:NULL];
    
    [completionAlert showWithSender:nil controller:nil animated:YES completion:NULL];
}

//评价提交成功Alert
- (void)requestAgentAgain {
    
    UdeskAlertController *agentAlert = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"udesk_reassign_agent")];
    [agentAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_close") Handler:NULL];
    
    [agentAlert showWithSender:nil controller:nil animated:YES completion:NULL];
}


//根据客服code弹出提示窗
- (void)showChatAlertViewWithCode:(NSInteger)code {
	
    if (code == 2002) {
        //客服不在线提示
        [self showAgentNotOnlineAlert];
    }
    else if (code == 2003) {
        //无网络提示
        [self showNetWorkDisconnectAlert];
    }
    else if (code == 2001) {
        //排队提示
        [self showQueueStatusAlert];
    }
    else if (code == 2004) {
        //排队提示
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

@end
