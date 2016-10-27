//
//  UdeskChatSend.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskChatSend.h"
#import "UdeskMessage+UdeskChatMessage.h"
#import "NSTimer+UdeskSDK.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskManager.h"
#import "UdeskTools.h"

@implementation UdeskChatSend

#pragma mark - 发送文字消息
+ (UdeskChatMessage *)sendTextMessage:(NSString *)text
                     displayTimestamp:(BOOL)displayTimestamp
                           completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion {
    
    if ([UdeskTools isBlankString:text]) {
        return nil;
    }
    
    UdeskChatMessage *chatMessage = [[UdeskChatMessage alloc] initWithText:text withDisplayTimestamp:displayTimestamp];
    
    UdeskMessage *textMessage = [[UdeskMessage alloc] initTextChatMessage:chatMessage text:text];
    
    //发送消息 callback发送状态和消息体
    [UdeskManager sendMessage:textMessage completion:^(UdeskMessage *message,BOOL sendStatus) {
        
        if (completion) {
            completion(message,sendStatus);
        }
    }];
    
    return chatMessage;
}

#pragma mark - 发送图片消息
+ (UdeskChatMessage *)sendImageMessage:(UIImage *)image
                      displayTimestamp:(BOOL)displayTimestamp
                            completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion {
    
    if (image) {
        
        UdeskChatMessage *chatMessage = [[UdeskChatMessage alloc] initWithImage:image withDisplayTimestamp:displayTimestamp];
        
        UdeskMessage *photoMessage = [[UdeskMessage alloc] initImageChatMessage:chatMessage image:image];
        //发送消息 callback发送状态和消息体
        [UdeskManager sendMessage:photoMessage completion:^(UdeskMessage *message,BOOL sendStatus) {
            
            if (completion) {
                completion(message,sendStatus);
            }
        }];
        
        return chatMessage;
    }
    else {
        return nil;
    }
}

#pragma mark - 发送语音消息
+ (UdeskChatMessage *)sendAudioMessage:(NSString *)voicePath
                         audioDuration:(NSString *)audioDuration
                      displayTimestamp:(BOOL)displayTimestamp
                            completion:(void(^)(UdeskMessage *message,BOOL sendStatus))comletion {
    
    if ([UdeskTools isBlankString:voicePath]) {
        return nil;
    }
    
    UdeskChatMessage *chatMessage = [[UdeskChatMessage alloc] initWithVoiceData:[NSData dataWithContentsOfFile:voicePath] withDisplayTimestamp:displayTimestamp];
    
    UdeskMessage *voiceMessage = [[UdeskMessage alloc] initVoiceChatMessage:chatMessage voiceData:chatMessage.voiceData];
    //发送消息 callback发送状态和消息体
    [UdeskManager sendMessage:voiceMessage completion:^(UdeskMessage *message,BOOL sendStatus) {
        
        if (comletion) {
            comletion(message,sendStatus);
        }
    }];
    
    return chatMessage;
}

#pragma mark - 重发失败的消息
+ (void)resendFailedMessage:(NSMutableArray *)resendMessageArray
                 completion:(void(^)(UdeskMessage *failedMessage,BOOL sendStatus))completion {
    
    if (resendMessageArray.count) {
     
        [NSTimer ud_scheduleTimerWithTimeInterval:6.0f repeats:YES usingBlock:^(NSTimer *timer) {
            
            if (resendMessageArray.count==0) {
                
                [timer invalidate];
                timer = nil;
            }
            else {
                
                @try {
                    
                    for (UdeskMessage *resendMessage in resendMessageArray) {
                        
                        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:resendMessage.timestamp];
                        
                        if (fabs (timeInterval) > 60) {
                            
                            if (completion) {
                                completion(resendMessage,NO);
                            }
                            
                            [resendMessageArray removeObject:resendMessage];
                            
                        } else {
                            
                            [UdeskManager sendMessage:resendMessage completion:^(UdeskMessage *message, BOOL sendStatus) {
                                
                                if (completion) {
                                    completion(message,sendStatus);
                                }
                            }];
                            
                        }
                        
                    }
                    
                } @catch (NSException *exception) {
                } @finally {
                }
                
            }
        }];
    }
    
}

@end
