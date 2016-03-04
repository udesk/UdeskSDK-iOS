//
//  UDCustomerViewModel.h
//  UdeskSDK
//
//  Created by xuchen on 16/3/4.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDAgentModel.h"
#import "UDManager.h"

@protocol UDCustomerDelegate <NSObject>

@optional

/**
 *  接受客服状态
 *
 *  @param presence 客服状态
 */
- (void)receiveAgentPresence:(NSString *)presence;
/**
 *  接受客服消息
 *
 *  @param presence 客服消息
 */
- (void)receiveAgentMessage:(UDMessage *)message;
/**
 *  通知VC客户被转接
 *
 *  @param agentMsg 转接客服信息
 */
- (void)notificationRedirect:(UDAgentModel *)agentModel;

@end

@interface UDCustomerViewModel : NSObject<UDManagerDelegate>

+ (instancetype)store;

- (void)requestCustomerDataAndLoginUdesk:(id<UDCustomerDelegate>)delegate;

@property (nonatomic, weak)id <UDCustomerDelegate>delegate;

@end
