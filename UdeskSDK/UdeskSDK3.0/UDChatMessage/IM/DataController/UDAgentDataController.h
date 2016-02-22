//
//  UDAgentDataController.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UDAgentModel;

typedef void (^UDAgentDataCallBack) (UDAgentModel *udAgent,NSError *error);

@interface UDAgentDataController : NSObject

+ (instancetype)store;

/**
 *  请求客服信息
 *
 *  @param callback 客服数据
 */

- (void)requestAgentDataWithCallback:(UDAgentDataCallBack)callback;

/**
 *  请求转接客服信息
 *
 *  @param callback 客服数据
 */
- (void)requestRedirectAgentDataWithCallback:(UDAgentDataCallBack)callback;

@end
