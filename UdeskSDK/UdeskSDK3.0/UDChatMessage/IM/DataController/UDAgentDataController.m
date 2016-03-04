 //
//  UDAgentDataController.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDAgentDataController.h"
#import "UDManager.h"

@implementation UDAgentDataController

+ (instancetype)store {

    return [[self alloc] init];
}

- (void)requestAgentDataWithCallback:(UDAgentDataCallBack)callback {
    
    UDAgentDataCallBack dataCallback = ^(id responseObject, NSError *error) {
        
        if (callback) {
            
            callback(responseObject,error);
        }
        
        NSDictionary *result = [responseObject objectForKey:@"result"];

        NSInteger agentCode = [[result objectForKey:@"code"] integerValue];
        
        if (agentCode == 2001) {
            
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

//- (void)requestAgentData:(UDAgentDataCallBack)callback {
//    
//    [UDManager getAgentInformation:^(id responseObject, NSError *error) {
//        
//        NSDictionary *result = [responseObject objectForKey:@"result"];
//        
//        NSDictionary *agent = [result objectForKey:@"agent"];
//        
//        UDAgentModel *udAgent = [[UDAgentModel alloc] initWithContentsOfDic:agent];
//        
//        udAgent.code = [[result objectForKey:@"code"] integerValue];
//        udAgent.message = [result objectForKey:@"message"];
//        
//        if (callback) {
//            callback(udAgent,error);
//        }
//        
//    }];
//    
//}

@end
