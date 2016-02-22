 //
//  UDAgentDataController.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDAgentDataController.h"
#import "UDManager.h"
#import "UDAgentModel.h"

@implementation UDAgentDataController

+ (instancetype)store {

    return [[self alloc] init];
}

- (void)requestAgentDataWithCallback:(UDAgentDataCallBack)callback {

    [UDManager getAgentInformation:^(id responseObject, NSError *error) {
        
        NSDictionary *result = [responseObject objectForKey:@"result"];
        
        NSDictionary *agent = [result objectForKey:@"agent"];
        
        UDAgentModel *udAgent = [[UDAgentModel alloc] initWithContentsOfDic:agent];
        
        udAgent.code = [[result objectForKey:@"code"] integerValue];
        udAgent.message = [result objectForKey:@"message"];
        
        if (callback) {
            callback(udAgent,error);
        }
        
    }];
}

//- (void)requestRedirectAgentDataWithCallback:(UDAgentDataCallBack)callback {
//
//
//}

@end
