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


- (void)requestAgentModel:(void(^)(UDAgentModel *agentModel,NSError *error))callback {
    
    [self requestAgentDataWithCallback:^(id responseObject, NSError *error) {
        
        NSDictionary *result = [responseObject objectForKey:@"result"];
        
        NSDictionary *agent = [result objectForKey:@"agent"];
        
        UDAgentModel *agentModel = [[UDAgentModel alloc] initWithContentsOfDic:agent];
        
        agentModel.code = [[result objectForKey:@"code"] integerValue];
        
        agentModel.message = [result objectForKey:@"message"];
        
        if (agentModel.code == 2000) {
            
            NSString *describeTieleStr = [NSString stringWithFormat:@"客服 %@ 在线",agentModel.nick];
            
            agentModel.message = describeTieleStr;
            
        }
        
        if (callback) {
            callback(agentModel,error);
        }

    }];
    
}

- (void)requestAgentDataWithCallback:(UDAgentDataCallBack)callback {
    
    UDAgentDataCallBack dataCallback = ^(id responseObject, NSError *error) {
        
        if (callback) {
            
            callback(responseObject,error);
        }
        
        NSDictionary *result = [responseObject objectForKey:@"result"];
        
        NSInteger agentCode = [[result objectForKey:@"code"] integerValue];
        
        if (agentCode == 2001 && self.stopRequest == NO) {
            
            // 客服状态码等于2001 20s轮训一次
            double delayInSeconds = 5.0f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self requestAgentDataWithCallback:callback];
                
            });
        }
        
    };
    
    [self requestAgentData:dataCallback];
    
}

- (void)requestAgentData:(UDAgentDataCallBack)callback {
    
    [UDManager getAgentInformation:^(id responseObject, NSError *error) {
        
        if (callback) {
            callback(responseObject,error);
        }
        
    }];
    
}

@end
