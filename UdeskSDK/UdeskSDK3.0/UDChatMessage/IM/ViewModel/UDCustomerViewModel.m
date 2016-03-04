//
//  UDCustomerViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 16/3/4.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDCustomerViewModel.h"
#import "UDReceiveChatMsg.h"

@implementation UDCustomerViewModel

+ (instancetype)store {

    return [[self alloc] init];
}

- (void)requestCustomerDataAndLoginUdesk:(id<UDCustomerDelegate>)delegate {
    
    self.delegate = delegate;
    
    [UDManager getCustomerLoginInfo:^(NSDictionary *loginInfoDic, NSError *error) {
        
        [UDManager loginUdesk:^(BOOL status) {
            
            if (status) {
                NSLog(@"登录Udesk成功");
            }
            
        } receiveDelegate:self];
        
    }];

}

#pragma mark - UDManagerDelegate
- (void)didReceiveMessages:(NSDictionary *)message {
    
    UDReceiveChatMsg *receiveMessage = UDReceiveChatMsg.store;

    //消息类型为转移的回调，代理传给VC
    receiveMessage.udAgentBlock = ^(UDAgentModel *agentModel){
        
        if ([self.delegate respondsToSelector:@selector(notificationRedirect:)]) {
            [self.delegate notificationRedirect:agentModel];
        }
    };
    
    NSDictionary *messageDic = [UDTools dictionaryWithJsonString:[message objectForKey:@"strContent"]];
    
    //解析消息创建消息体并添加到数组
    [receiveMessage resolveChatMsg:messageDic callbackMsg:^(UDMessage *message) {
        
        if ([self.delegate respondsToSelector:@selector(receiveAgentMessage:)]) {
            [self.delegate receiveAgentMessage:message];
        }
    }];
    
}
//接收客服状态
- (void)didReceivePresence:(NSDictionary *)presence {
    
    NSString *statusType = [presence objectForKey:@"type"];
    
//    if ([statusType isEqualToString:@"available"]) {
//        
//        self.viewModel.agentModel.code = 2000;
//        
//    } else {
//        
//        self.viewModel.agentModel.code = 2002;
//    }
    
    if ([self.delegate respondsToSelector:@selector(receiveAgentPresence:)]) {
        [self.delegate receiveAgentPresence:statusType];
    }
}

//接收客服发送的满意度调查
- (void)didReceiveSurvey:(NSString *)isSurvey withAgentId:(NSString *)agentId {
    
    //客服发送满意度调查
    if ([isSurvey isEqualToString:@"true"]) {
        
        [UDManager getSurveyOptions:^(id responseObject, NSError *error) {
            //解析数据
            NSDictionary *result = [responseObject objectForKey:@"result"];
            NSString *title = [result objectForKey:@"title"];
            NSString *desc = [result objectForKey:@"desc"];
            NSArray *options = [result objectForKey:@"options"];
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                //根据返回的信息填充Alert数据
                UDAlertController *optionsAlert = [UDAlertController alertWithTitle:title message:desc];
                [optionsAlert addCloseActionWithTitle:@"关闭" Handler:NULL];
                //遍历选项数组
                for (NSDictionary *option in options) {
                    //依次添加选项
                    [optionsAlert addAction:[UDAlertAction actionWithTitle:[option objectForKey:@"text"] handler:^(UDAlertAction * _Nonnull action) {
                        //根据点击的选项 提交到Udesk
                        [UDManager survetVoteWithAgentId:agentId withOptionId:[option objectForKey:@"id"] completion:^(id responseObject, NSError *error) {
                            
                            //评价提交成功Alert
                            [self surveyCompletion];
                            
                        }];
                        
                    }]];
                }
                //展示Alert
                [optionsAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            }
            
            
        }];
    }
}
//评价提交成功Alert
- (void)surveyCompletion {
    
    UDAlertController *completionAlert = [UDAlertController alertWithTitle:nil message:getUDLocalizedString(@"感谢您的评价")];
    [completionAlert addCloseActionWithTitle:getUDLocalizedString(@"关闭") Handler:NULL];
    
    [completionAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    
}

- (void)dealloc
{
    NSLog(@"UDCustomerViewModel销毁了");
}

@end
