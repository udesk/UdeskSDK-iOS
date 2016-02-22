//
//  UDAgentViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDAgentViewModel.h"
#import "UDAgentModel.h"

@implementation UDAgentViewModel

+ (instancetype)store {

    return [[self alloc] init];
}

- (UDAgentViewModel *)viewModelWithAgent:(UDAgentModel *)agentModel {

    NSInteger code = agentModel.code;
    
    if (code == 2000) {
        
        NSString *describeTieleStr = [NSString stringWithFormat:@"客服 %@ 在线",agentModel.nick];
        
        agentModel.message = describeTieleStr;
        
    }

    self.agentModel = agentModel;
    
    
    return self;
}

@end
