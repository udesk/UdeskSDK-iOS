//
//  UdeskAgentViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskAgentHttpData.h"
#import "UdeskAgentModel.h"
#import "NSTimer+UdeskSDK.h"
#import "UDManager.h"

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
- (void)requestRandomAgent:(void(^)(UdeskAgentModel *agentModel,NSError *error))completion {
    
    [UDManager requestRandomAgent:^(id responseObject, NSError *error) {
        
        NSDictionary *result = [responseObject objectForKey:@"result"];
        
        NSInteger agentCode = [[result objectForKey:@"code"] integerValue];
        
        if (agentCode == 2001 && self.stopRequest == NO) {
            
            // 客服状态码等于2001 20s轮训一次
            double delayInSeconds = agentHttpDelayInSeconds;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self requestRandomAgent:completion];
            });
        }
        
        UdeskAgentModel *agentModel = [self resolvingAgentData:responseObject];
        
        if (completion) {
            completion(agentModel,error);
        }
        
    }];
    
}

//指定分配客服或客服组
- (void)chooseAgentWithAgentId:(NSString *)agent_id
                   withGroupId:(NSString *)group_id
                    completion:(void(^)(UdeskAgentModel *agentModel,NSError *error))completion; {
    
    [UDManager assignAgentOrGroup:agent_id groupID:group_id completion:^(id responseObject, NSError *error) {
        
        NSDictionary *result = [responseObject objectForKey:@"result"];
        
        NSInteger agentCode = [[result objectForKey:@"code"] integerValue];
        
        if (agentCode == 2001 && self.stopRequest == NO) {
            
            // 客服状态码等于2001 20s轮训一次
            double delayInSeconds = agentHttpDelayInSeconds;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self chooseAgentWithAgentId:agent_id withGroupId:group_id completion:completion];
            });
        }
        
        UdeskAgentModel *agentModel = [self resolvingAgentData:responseObject];
        
        if (completion) {
            completion(agentModel,error);
        }

    }];

}

//解析客服信息
- (UdeskAgentModel *)resolvingAgentData:(NSDictionary *)responseObject {

    UdeskAgentModel *agentModel;

    if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
        
        NSDictionary *result = [responseObject objectForKey:@"result"];
        
        NSDictionary *agent = [result objectForKey:@"agent"];
        
        agentModel = [[UdeskAgentModel alloc] initWithContentsOfDic:agent];
        
        agentModel.code = [[result objectForKey:@"code"] integerValue];
        
        agentModel.message = [result objectForKey:@"message"];
        
        if (agentModel.code == 2000) {
            
            NSString *describeTieleStr = [NSString stringWithFormat:@"客服 %@ 在线",agentModel.nick];
            
            agentModel.message = describeTieleStr;   
        }
        
    }
    else {
    
        agentModel = [[UdeskAgentModel alloc] initWithContentsOfDic:responseObject];
        agentModel.code = [[responseObject objectForKey:@"code"] integerValue];
    }
    
    return agentModel;
}

@end
