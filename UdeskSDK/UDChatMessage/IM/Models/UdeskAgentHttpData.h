//
//  UdeskAgentViewModel.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UdeskAgentModel;

@interface UdeskAgentHttpData : NSObject

@property (nonatomic, strong) UdeskAgentModel *agentModel;

@property (nonatomic, assign) BOOL         stopRequest;

+ (instancetype)sharedAgentHttpData;

/**
 *  获取客服Model
 *
 *  @param callback 客服model
 */
- (void)requestRandomAgent:(void(^)(UdeskAgentModel *agentModel,NSError *error))completion;

/**
 *  指定分配客服或客服组
 *
 *  注意：需要先调用createCustomer接口
 *
 *  @param agentId    客服id（选择客服组，则客服id可不填）
 *  @param groupId    客服组id（选择客服，则客服组id可不填）
 *  @param completion 回调结果
 */
- (void)chooseAgentWithAgentId:(NSString *)agent_id
                   withGroupId:(NSString *)group_id
                    completion:(void(^)(UdeskAgentModel *agentModel,NSError *error))completion;

@end
