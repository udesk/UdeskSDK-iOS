//
//  UDReceiveChatMsg.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UDMessage;
@class UDAgentModel;

typedef void (^UDAgentDataCallBack) (UDAgentModel *udAgent);

@interface UDReceiveMessage : NSObject

@property (nonatomic, copy) UDAgentDataCallBack udAgentBlock;

+ (instancetype)store;

- (void)resolveChatMsg:(NSDictionary *)messageDic callbackMsg:(void(^)(UDMessage *message))block;

@end
