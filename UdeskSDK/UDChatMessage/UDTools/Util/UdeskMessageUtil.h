//
//  UdeskMessageUtil.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/16.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UdeskMessage;
@class UdeskLocationModel;

@interface UdeskMessageUtil : NSObject

//把UdeskMessage转换成UdeskChatMessage
+ (NSArray *)udeskMsgModelWithleaveMsg:(NSArray *)leaveMsgs messagesArray:(NSArray *)messagesArray;
//消息model转chatMessage
+ (NSArray *)chatMessageWithMsgModel:(NSArray *)array agentNick:(NSString *)agentNick lastMessage:(UdeskMessage *)lastMessage;

//重发失败的消息
+ (NSTimer *)resendFailedMessage:(NSMutableArray *)resendMessageArray progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *failedMessage))completion;

//地理位置消息转换
+ (UdeskLocationModel *)locationModelWithMessage:(UdeskMessage *)message;

@end
