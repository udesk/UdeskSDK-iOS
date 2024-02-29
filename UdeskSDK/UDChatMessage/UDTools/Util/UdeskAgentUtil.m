//
//  UdeskAgentUtil.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/21.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAgentUtil.h"
#import "UdeskManager.h"
#import "UdeskThrottleUtil.h"

static CGFloat kUdeskAgentPollingSeconds = 25.0f;
static NSString * kUdeskAgenStatetLoop = @"kUdeskAgenInfotLoop";
static BOOL kUdeskQuitQueue;

@implementation UdeskAgentUtil

+ (BOOL)udeskQuitQueue {
    return kUdeskQuitQueue;
}

+ (void)setUdeskQuitQueue:(BOOL)udeskQuitQueue {
    kUdeskQuitQueue = udeskQuitQueue;
    if(udeskQuitQueue){
        [UdeskThrottleUtil cancelKey:kUdeskAgenStatetLoop];
    }
}

/** 获取客服Model */
+ (void)fetchAgentWithPreSessionId:(NSNumber *)preSessionId preSessionMessage:(UdeskMessage *)preSessionMessage completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion {
    
    [UdeskManager fetchRandomAgentWithPreSessionId:preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agent, NSError *error) {
        // 客服状态码等于2001 25s轮训一次
        if (agent.statusType == UDAgentStatusResultQueue) {
            [self loopGetAgent:^{
                [self fetchAgentWithPreSessionId:preSessionId preSessionMessage:nil completion:completion];
            }];
        }
        
        if (completion) {
            completion(agent,error);
        }
    }];
}

/** 指定分配客服 */
+ (void)fetchAgentWithAgentId:(NSString *)agentId
                 preSessionId:(NSNumber *)preSessionId
            preSessionMessage:(UdeskMessage *)preSessionMessage
                   completion:(void (^) (UdeskAgent *agentModel, NSError *error))completion {
    
    [UdeskManager fetchAgentWithId:agentId preSessionId:preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agent, NSError *error) {
        // 客服状态码等于2001 25s轮训一次
        if (agent.statusType == UDAgentStatusResultQueue) {
            [self loopGetAgent:^{
                [self fetchAgentWithAgentId:agentId preSessionId:preSessionId preSessionMessage:nil completion:completion];
            }];
        }
        if (completion) {
            completion(agent,error);
        }
    }];
}

/** 指定分配客服组 */
+ (void)fetchAgentWithGroupId:(NSString *)groupId
                 preSessionId:(NSNumber *)preSessionId
            preSessionMessage:(UdeskMessage *)preSessionMessage
                   completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion {
    
    [UdeskManager fetchAgentWithGroupId:groupId preSessionId:preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agent, NSError *error) {
        
        // 客服状态码等于2001 25s轮训一次
        if (agent.statusType == UDAgentStatusResultQueue) {
            [self loopGetAgent:^{
                [self fetchAgentWithGroupId:groupId preSessionId:preSessionId preSessionMessage:nil completion:completion];
            }];
        }
        
        if (completion) {
            completion(agent,error);
        }
    }];
}

/** 指定分配客服组 */
+ (void)fetchAgentWithMenuId:(NSString *)menuId
                preSessionId:(NSNumber *)preSessionId
           preSessionMessage:(UdeskMessage *)preSessionMessage
                  completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion {
    
    [UdeskManager fetchAgentWithMenuId:menuId preSessionId:preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agent, NSError *error) {
        
        if (agent.statusType == UDAgentStatusResultQueue) {
            [self loopGetAgent:^{
                [self fetchAgentWithMenuId:menuId preSessionId:preSessionId preSessionMessage:nil completion:completion];
            }];
        }
        
        if (completion) {
            completion(agent,error);
        }
    }];
}

+ (void)loopGetAgent:(dispatch_block_t)completion {
    // 客服状态码等于2001 25s轮训一次
    [UdeskThrottleUtil throttle:kUdeskAgentPollingSeconds queue:UD_THROTTLE_MAIN_QUEUE key:kUdeskAgenStatetLoop block:^{
        if (!kUdeskQuitQueue) {
            completion();
        }
    }];
}

@end
