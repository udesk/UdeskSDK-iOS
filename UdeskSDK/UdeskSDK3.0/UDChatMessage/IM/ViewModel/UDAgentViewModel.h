//
//  UDAgentViewModel.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UDAgentModel;

@interface UDAgentViewModel : NSObject

@property (nonatomic, strong) UDAgentModel *agentModel;

+ (instancetype)store;

- (UDAgentViewModel *)viewModelWithAgent:(UDAgentModel *)agentModel;

- (void)requestAgentModel:(void(^)(UDAgentModel *agentModel,NSError *error))callback;

@end
