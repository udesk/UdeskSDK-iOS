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

@property (nonatomic, assign) BOOL         stopRequest;

/**
 *  获取客服Model
 *
 *  @param callback 客服model
 */
- (void)requestAgentModel:(void(^)(UDAgentModel *agentModel,NSError *error))callback;

@end
