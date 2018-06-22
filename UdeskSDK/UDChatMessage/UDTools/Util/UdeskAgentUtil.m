//
//  UdeskAgentUtil.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/21.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAgentUtil.h"
#import "UdeskManager.h"

static CGFloat kUdeskAgentPollingSeconds = 25.0f;

@implementation UdeskAgentUtil

/** 获取客服Model */
+ (void)fetchAgentWithPreSessionId:(NSNumber *)preSessionId completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion {
    
    [UdeskManager requestRandomAgentWithPreSessionId:preSessionId completion:^(UdeskAgent *agent, NSError *error) {
        
        if (agent.code == UDAgentStatusResultQueue) {
            
            // 客服状态码等于2001 25s轮训一次
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kUdeskAgentPollingSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self fetchAgentWithPreSessionId:preSessionId completion:completion];
            });
        }
        
        if (completion) {
            completion(agent,error);
        }
    }];
}

/** 指定分配客服 */
+ (void)fetchAgentWithAgentId:(NSString *)agentId
                 preSessionId:(NSNumber *)preSessionId
                   completion:(void (^) (UdeskAgent *agentModel, NSError *error))completion {
    
    [UdeskManager scheduledAgentId:agentId preSessionId:preSessionId completion:^(UdeskAgent *agent, NSError *error) {
        
        if (agent.code == UDAgentStatusResultQueue) {
            
            // 客服状态码等于2001 25s轮训一次
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kUdeskAgentPollingSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self fetchAgentWithAgentId:agentId preSessionId:preSessionId completion:completion];
            });
        }
        
        if (completion) {
            completion(agent,error);
        }
    }];
}

/** 指定分配客服组 */
+ (void)fetchAgentWithGroupId:(NSString *)groupId
                 preSessionId:(NSNumber *)preSessionId
                   completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion {
    
    [UdeskManager scheduledGroupId:groupId preSessionId:preSessionId completion:^(UdeskAgent *agent, NSError *error) {
        
        if (agent.code == UDAgentStatusResultQueue) {
            
            // 客服状态码等于2001 25s轮训一次
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kUdeskAgentPollingSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self fetchAgentWithGroupId:groupId preSessionId:preSessionId completion:completion];
            });
        }
        
        if (completion) {
            completion(agent,error);
        }
    }];
}

@end
