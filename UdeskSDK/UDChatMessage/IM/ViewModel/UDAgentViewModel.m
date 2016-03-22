//
//  UDAgentViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDAgentViewModel.h"
#import "UDAgentModel.h"
#import "NSTimer+UDMessage.h"
#import "UDManager.h"

typedef void (^UDAgentDataCallBack) (id responseObject, NSError *error);

@interface UDAgentViewModel()

@end

@implementation UDAgentViewModel

//请求客服信息
- (void)requestAgentModel:(void(^)(UDAgentModel *agentModel,NSError *error))completion {
    
    [self requestAgentDataWithCallback:^(id responseObject, NSError *error) {
        
       UDAgentModel *agentModel = [self resolvingAgentData:responseObject];
        
        if (completion) {
            completion(agentModel,error);
        }

    }];
    
}
//请求客服信息block
- (void)requestAgentDataWithCallback:(UDAgentDataCallBack)completion {
    
    UDAgentDataCallBack dataCallback = ^(id responseObject, NSError *error) {
        
        if (completion) {
            
            completion(responseObject,error);
        }
        
        NSDictionary *result = [responseObject objectForKey:@"result"];
        
        NSInteger agentCode = [[result objectForKey:@"code"] integerValue];
        
        if (agentCode == 2001 && self.stopRequest == NO) {
            
            // 客服状态码等于2001 20s轮训一次
            double delayInSeconds = 5.0f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self requestAgentDataWithCallback:completion];
                
            });
        }
        
    };
    
    [self requestAgentData:dataCallback];
    
}

- (void)requestAgentData:(UDAgentDataCallBack)completion {
    
    [UDManager getAgentInformation:^(id responseObject, NSError *error) {
        
        if (completion) {
            completion(responseObject,error);
        }
        
    }];
    
}

//指定分配客服或客服组
- (void)assignAgentOrGroup:(NSString *)agentId
                   groupID:(NSString *)groupId
                completion:(void(^)(UDAgentModel *agentModel,NSError *error))completion {

    [self requestAgentDataWithAgentId:agentId groupId:groupId completion:^(id responseObject, NSError *error) {
        
        UDAgentModel *agentModel = [self resolvingAgentData:responseObject];
        
        if (completion) {
            completion(agentModel,error);
        }
        
    }];

}
//请求指定客服信息
- (void)requestAgentDataWithAgentId:(NSString *)agentId
                            groupId:(NSString *)groupId
                         completion:(UDAgentDataCallBack)completion {
    
    UDAgentDataCallBack dataCallback = ^(id responseObject, NSError *error) {
        
        if (completion) {
            
            completion(responseObject,error);
        }
        
        NSDictionary *result = [responseObject objectForKey:@"result"];
        
        NSInteger agentCode = [[result objectForKey:@"code"] integerValue];
        
        if (agentCode == 2001 && self.stopRequest == NO) {
            
            // 客服状态码等于2001 20s轮训一次
            double delayInSeconds = 5.0f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self requestAgentDataWithAgentId:agentId groupId:groupId completion:completion];
                
            });
        }
        
    };
    
    [self requestOnlyAgentDataWithAgentId:agentId groupId:groupId completion:dataCallback];
    
}

//请求指定客服信息
- (void)requestOnlyAgentDataWithAgentId:(NSString *)agentId
                                groupId:(NSString *)groupId
                             completion:(UDAgentDataCallBack)completion{
    
    [UDManager assignAgentOrGroup:agentId groupID:groupId completion:^(id responseObject, NSError *error) {
        
        if (completion) {
            completion(responseObject,error);
        }
        
    }];
}

//解析客服信息
- (UDAgentModel *)resolvingAgentData:(NSDictionary *)responseObject {

    UDAgentModel *agentModel;

    if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
        
        NSDictionary *result = [responseObject objectForKey:@"result"];
        
        NSDictionary *agent = [result objectForKey:@"agent"];
        
        agentModel = [[UDAgentModel alloc] initWithContentsOfDic:agent];
        
        agentModel.code = [[result objectForKey:@"code"] integerValue];
        
        agentModel.message = [result objectForKey:@"message"];
        
        if (agentModel.code == 2000) {
            
            NSString *describeTieleStr = [NSString stringWithFormat:@"客服 %@ 在线",agentModel.nick];
            
            agentModel.message = describeTieleStr;
            
        }
        
    }
    else {
    
        agentModel = [[UDAgentModel alloc] initWithContentsOfDic:responseObject];
        agentModel.code = [[responseObject objectForKey:@"code"] integerValue];
    }
    
    return agentModel;
}

@end
