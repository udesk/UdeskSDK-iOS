//
//  UDAgentDataController.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UDAgentDataCallBack) (id responseObject, NSError *error);

@interface UDAgentDataController : NSObject

+ (instancetype)store;

/**
 *  请求客服信息
 *
 *  @param callback 客服数据
 */

- (void)requestAgentDataWithCallback:(UDAgentDataCallBack)callback;

@end
