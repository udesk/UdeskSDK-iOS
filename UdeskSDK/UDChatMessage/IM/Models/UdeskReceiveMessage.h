//
//  UdeskReceiveChatMsg.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UdeskMessage;
@class UdeskAgentModel;

typedef void (^UDAgentDataCallBack) (UdeskAgentModel *udAgent);

@interface UdeskReceiveMessage : NSObject

+ (void)ud_modelWithDictionary:(NSDictionary *)messageDictionary
                    completion:(void(^)(UdeskMessage *message))completion
                 redirectAgent:(UDAgentDataCallBack)redirectAgent;

@end
