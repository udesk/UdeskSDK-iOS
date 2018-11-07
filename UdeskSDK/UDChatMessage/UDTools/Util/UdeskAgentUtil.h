//
//  UdeskAgentUtil.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/21.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UdeskAgent;
@class UdeskMessage;

@interface UdeskAgentUtil : NSObject

/** 获取客服Model */
+ (void)fetchAgentWithPreSessionId:(NSNumber *)preSessionId
                 preSessionMessage:(UdeskMessage *)preSessionMessage
                        completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion;

/** 指定分配客服 */
+ (void)fetchAgentWithAgentId:(NSString *)agentId
                 preSessionId:(NSNumber *)preSessionId
            preSessionMessage:(UdeskMessage *)preSessionMessage
                   completion:(void (^) (UdeskAgent *agentModel, NSError *error))completion;

/** 指定分配客服组 */
+ (void)fetchAgentWithGroupId:(NSString *)groupId
                 preSessionId:(NSNumber *)preSessionId
            preSessionMessage:(UdeskMessage *)preSessionMessage
                   completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion;


@end
