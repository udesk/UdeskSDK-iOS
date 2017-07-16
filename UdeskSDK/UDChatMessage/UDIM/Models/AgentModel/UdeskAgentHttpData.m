//
//  UdeskAgentViewModel.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskAgentHttpData.h"
#import "UdeskManager.h"

typedef void (^UDAgentDataCallBack) (id responseObject, NSError *error);

@implementation UdeskAgentHttpData

static double agentHttpDelayInSeconds = 25.0f;

+ (instancetype)sharedAgentHttpData {
    
    static UdeskAgentHttpData *_agentHttpData = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _agentHttpData = [[self alloc ] init];
    });
    
    return _agentHttpData;
}

//请求客服信息
- (void)requestRandomAgent:(void(^)(UdeskAgent *agentModel,NSError *error))completion {
    
    [UdeskManager requestRandomAgent:^(UdeskAgent *agent, NSError *error) {
        
        if (agent.code == UDAgentStatusResultQueue) {
            
            // 客服状态码等于2001 20s轮训一次
            double delayInSeconds = agentHttpDelayInSeconds;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self requestRandomAgent:completion];
            });
        }
        
        if (completion) {
            completion(agent,error);
        }
    }];
    
}

- (void)scheduledAgentId:(NSString *)agentId
              completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion{

    [UdeskManager scheduledAgentId:agentId completion:^(UdeskAgent *agent, NSError *error) {
        
        if (agent.code == UDAgentStatusResultQueue) {
            
            // 客服状态码等于2001 20s轮训一次
            double delayInSeconds = agentHttpDelayInSeconds;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self scheduledAgentId:agentId completion:completion];
            });
        }
        
        if (completion) {
            completion(agent,error);
        }
    }];
}

- (void)scheduledGroupId:(NSString *)groupId
              completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion{
    
    [UdeskManager scheduledGroupId:groupId completion:^(UdeskAgent *agent, NSError *error) {
        
        if (agent.code == UDAgentStatusResultQueue) {
            
            // 客服状态码等于2001 20s轮训一次
            double delayInSeconds = agentHttpDelayInSeconds;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self scheduledGroupId:groupId completion:completion];
            });
        }
        
        if (completion) {
            completion(agent,error);
        }

    }];
}


@end
