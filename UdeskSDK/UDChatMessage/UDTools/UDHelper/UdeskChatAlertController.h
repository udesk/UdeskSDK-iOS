//
//  UdeskChatAlertController.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/17.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UdeskChatAlertDelegate <NSObject>

- (void)didSelectSendTicket;

- (void)didSelectBlacklistedAlertViewOkButton;

@end

@interface UdeskChatAlertController : NSObject

@property (nonatomic, weak) id <UdeskChatAlertDelegate> delegate;

//排队Alert
- (void)showQueueStatusAlertWithMessage:(NSString *)message
                    enableWebImFeedback:(BOOL)enableWebImFeedback;
//客服不在线Alert
- (void)showAgentNotOnlineAlert;
//客服不在线Alert
- (void)showAgentNotOnlineAlertWithMessage:(NSString *)message
                       enableWebImFeedback:(BOOL)enableWebImFeedback;
//无网络Alert
- (void)showNetWorkDisconnectAlert;
//不存在客服或客服组
- (void)showNotExistAgentAlert:(NSString *)message;
//黑名单
- (void)showIsBlacklistedAlert:(NSString *)message;
//未知错误
- (void)showNotConnectedAlert;
//根据客服code弹出提示窗
- (void)showChatAlertViewWithCode:(NSInteger)code
                       andMessage:(NSString *)message
              enableWebImFeedback:(BOOL)enableWebImFeedback;

//评价提交成功Alert
- (void)surveyCompletion;

- (void)showBigVideoPoint;

- (void)showAlertWithMessage:(NSString *)message;

- (void)hideAlert;

@end
