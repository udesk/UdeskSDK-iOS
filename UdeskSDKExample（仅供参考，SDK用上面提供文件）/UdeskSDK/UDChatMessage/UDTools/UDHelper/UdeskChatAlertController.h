//
//  UdeskChatAlertController.h
//  UdeskSDK
//
//  Created by xuchen on 16/8/17.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UdeskChatAlertDelegate <NSObject>

- (void)didSelectSendTicket;

- (void)didSelectBlacklistedAlertViewOkButton;

@end

@interface UdeskChatAlertController : NSObject

@property (nonatomic, weak) id <UdeskChatAlertDelegate> delegate;
//排队Alert
- (void)showQueueStatusAlert;
//客服不在线Alert
- (void)showAgentNotOnlineAlert;
//无网络Alert
- (void)showNetWorkDisconnectAlert;
//不存在客服或客服组
- (void)showNotExistAgentAlert:(NSString *)message;
//黑名单
- (void)showIsBlacklistedAlert;
//未知错误
- (void)showNotConnectedAlert;
//根据客服code弹出提示窗
- (void)showChatAlertViewWithCode:(NSInteger)code;
//评价提交成功Alert
- (void)surveyCompletion;

@end
