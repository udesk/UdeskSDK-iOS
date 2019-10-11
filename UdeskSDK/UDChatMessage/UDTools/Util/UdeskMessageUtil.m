//
//  UdeskMessageUtil.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/16.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskMessageUtil.h"
#import "UdeskTextMessage.h"
#import "UdeskEventMessage.h"
#import "UdeskImageMessage.h"
#import "UdeskVoiceMessage.h"
#import "UdeskVideoMessage.h"
#import "UdeskStructMessage.h"
#import "UdeskLocationMessage.h"
#import "UdeskVideoCallMessage.h"
#import "UdeskProductMessage.h"
#import "UdeskGoodsMessage.h"
#import "UdeskSDKUtil.h"
#import "UdeskBundleUtils.h"
#import "NSTimer+UdeskSDK.h"
#import "UdeskManager.h"
#import "UdeskLocationModel.h"
#import "UdeskBaseMessage.h"
#import "Udesk_YYWebImage.h"
#import "UdeskCacheUtil.h"
#import "UdeskQueueMessage.h"

@implementation UdeskMessageUtil

//把UdeskMessage转换成UdeskChatMessage
+ (NSArray *)udeskMsgModelWithleaveMsg:(NSArray *)leaveMsgs messagesArray:(NSArray *)messagesArray {
    
    @try {
        
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        NSArray *array = [messagesArray valueForKey:@"messageId"];
        
        for (UdeskMessage *message in leaveMsgs) {
            
            if (![array containsObject:message.messageId]) {
                
                if (message.messageType == UDMessageContentTypeText||
                    message.messageType == UDMessageContentTypeLeaveMsg) {
                    
                    UdeskTextMessage *textMessage = [[UdeskTextMessage alloc] initWithMessage:message displayTimestamp:NO];
                    if (textMessage) {
                        [messages addObject:textMessage];
                    }
                }
                else if (message.messageType == UDMessageContentTypeLeaveEvent) {
                    
                    UdeskEventMessage *eventMessage = [[UdeskEventMessage alloc] initWithMessage:message displayTimestamp:YES];
                    if (eventMessage) {
                        [messages addObject:eventMessage];
                    }
                }
            }
        }
        
        //如果只有一个事件消息 则不需要显示
        if (messages.count==1 && [messages.firstObject isKindOfClass:[UdeskEventMessage class]]) {
            [messages removeAllObjects];
        }
        
        return messages;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//消息model转chatMessage
+ (NSArray *)chatMessageWithMsgModel:(NSArray *)array agentNick:(NSString *)agentNick lastMessage:(UdeskMessage *)lastMessage {
    
    NSMutableArray *msgLayout = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(UdeskMessage *message, NSUInteger idx, BOOL * _Nonnull stop) {
        
        @try {
            
            //检查是否需要显示时间（第一条信息和超过3分钟间隔的显示时间）
            UdeskMessage *previousMessage;
            if (idx>0) {
                previousMessage = [array objectAtIndex:idx-1];
            }
            
            if (!previousMessage && lastMessage) {
                previousMessage = lastMessage;
            }
            
            BOOL isDisplayTimestamp = [self checkWhetherMessageTimeDisplayed:previousMessage laterMessage:message];
            
            switch (message.messageType) {
                case UDMessageContentTypeRich:
                case UDMessageContentTypeLeaveMsg:
                case UDMessageContentTypeText:{
                    
                    UdeskTextMessage *textMessage = [[UdeskTextMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:textMessage];
                    break;
                }
                case UDMessageContentTypeImage:{
                    
                    UdeskImageMessage *imageMessage = [[UdeskImageMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:imageMessage];
                    //缓存收到的图片
                    [self storeImageWithMessage:message];
                    break;
                }
                case UDMessageContentTypeVoice: {
                    
                    UdeskVoiceMessage *voiceLayout = [[UdeskVoiceMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:voiceLayout];
                    //缓存收到的语音
                    [self storeVoiceWithMessage:message];
                    break;
                }
                case UDMessageContentTypeVideo: {
                    
                    UdeskVideoMessage *videoMessage = [[UdeskVideoMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:videoMessage];
                    break;
                }
                case UDMessageContentTypeStruct: {
                    
                    UdeskStructMessage *strucrtMessage = [[UdeskStructMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:strucrtMessage];
                    break;
                }
                case UDMessageContentTypeRedirect:
                case UDMessageContentTypeLeaveEvent:{
                    
                    UdeskEventMessage *eventMessage = [[UdeskEventMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:eventMessage];
                    break;
                }
                case UDMessageContentTypeRollback: {
                    
                    NSString *agentNick = message.content;
                    if ([UdeskSDKUtil isBlankString:agentNick]) {
                        agentNick = agentNick;
                    }
                    NSString *rollbackText = [NSString stringWithFormat:@"%@%@%@",getUDLocalizedString(@"udesk_agent"),agentNick,getUDLocalizedString(@"udesk_rollback")];
                    message.content = rollbackText;
                    UdeskEventMessage *eventMessage = [[UdeskEventMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:eventMessage];
                    break;
                }
                case UDMessageContentTypeLocation: {
                    
                    UdeskLocationMessage *locationMessage = [[UdeskLocationMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:locationMessage];
                    break;
                }
                case UDMessageContentTypeVideoCall: {
                    
                    UdeskVideoCallMessage *videoCallMessage = [[UdeskVideoCallMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:videoCallMessage];
                    break;
                }
                case UDMessageContentTypeProduct: {
                    
                    UdeskProductMessage *productMessage = [[UdeskProductMessage alloc] initWithMessage:message displayTimestamp:YES];
                    [msgLayout addObject:productMessage];
                    break;
                }
                case UDMessageContentTypeGoods: {
                    
                    UdeskGoodsMessage *goodsMessage = [[UdeskGoodsMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:goodsMessage];
                    break;
                }
                case UDMessageContentTypeQueueEvent: {
                    
                    UdeskQueueMessage *queueMessage = [[UdeskQueueMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:queueMessage];
                    break;
                }
                    
                default:
                    break;
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }];
    
    return msgLayout;
}

//缓存图片
+ (void)storeImageWithMessage:(UdeskMessage *)message {
    
    if (message.messageFrom == UDMessageTypeReceiving) {
        if (message.imageData) {
            Udesk_YYImage *gifImage = [[Udesk_YYImage alloc] initWithData:message.imageData];
            message.image = gifImage;
            [[Udesk_YYWebImageManager sharedManager].cache setImage:gifImage forKey:message.content];
        }
        else {
            [[Udesk_YYWebImageManager sharedManager].cache setImage:message.image forKey:message.content];
        }
    }
}

//缓存语音
+ (void)storeVoiceWithMessage:(UdeskMessage *)message {
    
    if (message.messageFrom == UDMessageTypeReceiving) {
        [[UdeskCacheUtil sharedManager] setObject:message.voiceData forKey:message.messageId];
    }
}

//检查是否需要显示时间（间隔超过3分钟就显示时间）
+ (BOOL)checkWhetherMessageTimeDisplayed:(UdeskMessage *)previousMessage laterMessage:(UdeskMessage *)laterMessage {
    
    @try {
        
        if (!previousMessage || previousMessage == (id)kCFNull) return YES;
        if (!laterMessage || laterMessage == (id)kCFNull) return YES;
        
        if (![previousMessage isKindOfClass:[UdeskMessage class]]) return YES;
        if (![laterMessage isKindOfClass:[UdeskMessage class]]) return YES;
        
        if (laterMessage.messageType == UDMessageContentTypeLeaveEvent ||
            laterMessage.messageType == UDMessageContentTypeRedirect ||
            laterMessage.messageType == UDMessageContentTypeStruct ||
            laterMessage.messageType == UDMessageContentTypeRollback) {
            return YES;
        }
        
        NSInteger interval=[laterMessage.timestamp timeIntervalSinceDate:previousMessage.timestamp];
        if(interval>60*3) return YES;
        
        return NO;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 重发失败的消息
+ (NSTimer *)resendFailedMessage:(NSMutableArray *)resendMessageArray progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *failedMessage))completion {
    
    NSTimer *timer = [NSTimer udScheduleTimerWithTimeInterval:6.0f repeats:YES usingBlock:^(NSTimer *timer) {
        
        @try {
            if (resendMessageArray.count==0) {
                
                [timer invalidate];
                timer = nil;
            }
            else {
                
                for (UdeskMessage *resendMessage in resendMessageArray) {
                    
                    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:resendMessage.timestamp];
                    
                    if (fabs (timeInterval) > 60) {
                        
                        resendMessage.messageStatus = UDMessageSendStatusFailed;
                        if (completion) {
                            completion(resendMessage);
                        }
                        
                        [resendMessageArray removeObject:resendMessage];
                        
                    } else {
                        
                        [UdeskManager sendMessage:resendMessage progress:^(float percent) {
                            
                            if ([resendMessageArray containsObject:resendMessage]) {
                                [resendMessageArray removeObject:resendMessage];
                            }
                            
                            if (progress) {
                                progress(resendMessage.messageId,percent);
                            }
                            
                        } completion:completion];
                    }
                }
            }
        } @catch (NSException *exception) {
        } @finally {
        }
    }];
    
    return timer;
}

#pragma mark - location
+ (UdeskLocationModel *)locationModelWithMessage:(UdeskMessage *)message {
    
    @try {
        
        UdeskLocationModel *location = [[UdeskLocationModel alloc] init];
        if ([UdeskSDKUtil isBlankString:message.content]) {
            return location;
        }
        
        NSArray *array = [message.content componentsSeparatedByString:@";"];
        if (array.count < 4) {
            return location;
        }
        
        double latitude = [array[0] doubleValue];
        double longitude = [array[1] doubleValue];
        location.longitude = longitude;
        location.latitude = latitude;
        location.image = message.image;
        location.zoomLevel = [array[2] integerValue];
        location.name = array[3];
        
        return location;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
