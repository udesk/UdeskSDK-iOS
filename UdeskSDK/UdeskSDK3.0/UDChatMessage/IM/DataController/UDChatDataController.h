//
//  UDChatDataController.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UDAgentModel;

@interface UDChatDataController : NSObject

/**
 *  请求客服信息
 *
 *  @param callback 客服数据
 */
- (void)requestAgentDataWithCallback:(void(^)(UDAgentModel *udAgent,NSError *error))callback;

- (void)getDatabaseHistoryMessage:(void(^)(NSMutableArray *dbMessageArray))result;

@end
