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

+ (void)ud_messageModelWithDictionary:(NSDictionary *)messageDictionary
                           completion:(void(^)(UDMessage *message))completion
                        redirectAgent:(UDAgentDataCallBack)redirectAgent;

@end
