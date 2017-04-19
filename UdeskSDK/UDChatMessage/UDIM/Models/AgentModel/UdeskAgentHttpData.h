
//  UdeskAgentViewModel.h
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskAgent.h"

@interface UdeskAgentHttpData : NSObject

@property (nonatomic, strong) UdeskAgent      *agentModel;

+ (instancetype)sharedAgentHttpData;

/**
 *  获取客服Model
 *
 *  @param callback 客服model
 */
- (void)requestRandomAgent:(void(^)(UdeskAgent *agentModel,NSError *error))completion;
/**
 *  指定分配客服
 *
 *  @param agentId    客服id
 *  @param completion 完成之后回调
 */
- (void)scheduledAgentId:(NSString *)agentId
              completion:(void (^) (UdeskAgent *agentModel, NSError *error))completion;
/**
 *  指定分配客服组
 *
 *  @param agentId    客服组id
 *  @param completion 完成之后回调
 */
- (void)scheduledGroupId:(NSString *)groupId
              completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion;

@end
