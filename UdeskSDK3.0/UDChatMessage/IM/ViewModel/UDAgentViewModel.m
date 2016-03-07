//
//  UDAgentViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDAgentViewModel.h"
#import "UDAgentModel.h"
#import "UDAgentDataController.h"

@implementation UDAgentViewModel

+ (instancetype)store {

    return [[self alloc] init];
}


- (void)requestAgentModel:(void(^)(UDAgentModel *agentModel,NSError *error))callback {
    
    [UDAgentDataController.store requestAgentDataWithCallback:^(id responseObject, NSError *error) {
        
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

@end
