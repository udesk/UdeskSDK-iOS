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
 *  获取DB数据
 *
 *  @param result db消息数组
 */
- (void)getDatabaseHistoryMessage:(void(^)(NSArray *dbMessageArray))result;

@end
