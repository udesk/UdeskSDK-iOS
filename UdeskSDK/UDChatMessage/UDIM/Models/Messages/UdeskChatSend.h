//
//  UdeskChatSend.h
//  UdeskSDK
//
//  Created by xuchen on 16/8/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class UdeskMessage;
@class UdeskChatMessage;

@interface UdeskChatSend : NSObject

/**
 *  发送文本消息
 *
 *  @param text       文本
 *  @param completion 发送状态&发送消息体
 */
+ (UdeskChatMessage *)sendTextMessage:(NSString *)text
                     displayTimestamp:(BOOL)displayTimestamp
                           completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion;

/**
 *  发送图片消息
 *
 *  @param image      图片
 *  @param completion 发送状态&发送消息体
 */
+ (UdeskChatMessage *)sendImageMessage:(UIImage *)image
                      displayTimestamp:(BOOL)displayTimestamp
                            completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion;

/**
 *  发送语音消息
 *
 *  @param audioPath     语音文件地址
 *  @param audioDuration 语音时长
 *  @param comletion     发送状态&发送消息体
 */
+ (UdeskChatMessage *)sendAudioMessage:(NSString *)audioPath
                         audioDuration:(NSString *)audioDuration
                      displayTimestamp:(BOOL)displayTimestamp
                            completion:(void(^)(UdeskMessage *message,BOOL sendStatus))comletion;

/**
 *  重发消息
 *
 *  @param failedMessageArray 失败消息的数组
 *  @param completion         完成回调
 */
+ (void)resendFailedMessage:(NSMutableArray *)resendMessageArray
                 completion:(void(^)(UdeskMessage *failedMessage,BOOL sendStatus))completion;

@end
