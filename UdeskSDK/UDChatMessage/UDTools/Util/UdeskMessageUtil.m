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
#import "UdeskGoodsMessage.h"
#import "NSTimer+UdeskSDK.h"
#import "UdeskManager.h"
#import "UdeskLocationModel.h"
#import "Udesk_YYWebImage.h"
#import "UdeskCacheUtil.h"
#import "UdeskImageUtil.h"
#import "UdeskQueueMessage.h"
#import "UdeskRichMessage.h"
#import "UdeskTopAskMessage.h"
#import "UdeskNewsMessage.h"
#import "UdeskLinkMessage.h"
#import "UdeskListMessage.h"
#import "UdeskTableMessage.h"
#import "UdeskProductMessage.h"
#import "UdeskProductListMessage.h"
#import "UdeskTemplateMessage.h"
#import "UdeskNewMessageTag.h"

@implementation UdeskMessageUtil

//消息model转chatMessage
+ (NSArray *)chatMessageWithMsgModel:(NSArray *)array lastMessage:(UdeskMessage *)lastMessage {
    
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
            
            
            //检查是否需要显示时间（第一条信息和超过3分钟间隔的显示时间）
            UdeskMessage *lastMessageCopy;
            if (idx+1<array.count) {
                lastMessageCopy = [array objectAtIndex:idx+1];
            }
            
            BOOL isDisplayTimestamp = [self checkWhetherMessageTimeDisplayed:previousMessage laterMessage:message];
            
            switch (message.messageType) {
                case UDMessageContentTypeText:{
                    
                    NSString *bubbleType = [self setupMessageBubble:message laterMessage:lastMessageCopy previousMessage:previousMessage];
                    message.bubbleType = bubbleType;
                    
                    UdeskTextMessage *textMessage = [[UdeskTextMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:textMessage];
                    break;
                }
                case UDMessageContentTypeRich:{
                    
                    UdeskRichMessage *richMessage = [[UdeskRichMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:richMessage];
                    break;
                }
                case UDMessageContentTypeImage:{
                    
                    //缓存收到的图片
                    [self storeImageWithMessage:message];
                    
                    UdeskImageMessage *imageMessage = [[UdeskImageMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:imageMessage];
                    break;
                }
                case UDMessageContentTypeVoice: {
                    
                    //缓存语音
                    [self storeVoiceWithMessage:message];
                    
                    UdeskVoiceMessage *voiceLayout = [[UdeskVoiceMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:voiceLayout];
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
                case UDMessageContentTypeRobotEvent:
                case UDMessageContentTypeRobotTransfer:
                case UDMessageContentTypeLeaveEvent:
                case UDMessageContentTypeSurveyEvent:{
                    UdeskEventMessage *eventMessage = [[UdeskEventMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:eventMessage];
                    break;
                }
                case UDMessageContentTypeNewMessage:{
                    UdeskNewMessageTag *newMessage = [[UdeskNewMessageTag alloc] initWithMessage:message displayTimestamp:NO];
                    [msgLayout addObject:newMessage];
                    break;
                }
                case UDMessageContentTypeRollback: {
                    
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
                case UDMessageContentTypeTopAsk: {
                    
                    UdeskTopAskMessage *topAskMessage = [[UdeskTopAskMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:topAskMessage];
                    break;
                }
                case UDMessageContentTypeNews: {
                    
                    UdeskNewsMessage *newsMessage = [[UdeskNewsMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:newsMessage];
                    break;
                }
                case UDMessageContentTypeLink: {
                    
                    UdeskLinkMessage *linkMessage = [[UdeskLinkMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:linkMessage];
                    break;
                }
                case UDMessageContentTypeTable: {
                    
                    UdeskTableMessage *tableMessage = [[UdeskTableMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:tableMessage];
                    break;
                }
                case UDMessageContentTypeList: {
                    
                    UdeskListMessage *listMessage = [[UdeskListMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:listMessage];
                    break;
                }
                case UDMessageContentTypeShowProduct:
                case UDMessageContentTypeSelectiveProduct: {
                    
                    UdeskProductListMessage *productListMessage = [[UdeskProductListMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:productListMessage];
                    break;
                }
                case UDMessageContentTypeReplyProduct: {
                    
                    UdeskProductMessage *productMessage = [[UdeskProductMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:productMessage];
                    break;
                }
                case UDMessageContentTypeTemplate: {
                    
                    UdeskTemplateMessage *templateMessage = [[UdeskTemplateMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:templateMessage];
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
        
        Udesk_YYImage *image = [[Udesk_YYImage alloc] initWithData:message.sourceData];
        if (image.animatedImageType == Udesk_YYImageTypeGIF) {
            message.image = image;
        }
        else {
            message.image = [UdeskImageUtil imageWithOriginalImage:[UdeskImageUtil fixOrientation:image]];
        }
        
        [[Udesk_YYWebImageManager sharedManager].cache setImage:message.image forKey:message.content];
    }
}

//缓存语音
+ (void)storeVoiceWithMessage:(UdeskMessage *)message {
    
    if (message.sourceData && message.messageId) {
        [[UdeskCacheUtil sharedManager] setObject:message.sourceData forKey:message.messageId];
    }
}

//检查是否需要显示时间（间隔超过3分钟就显示时间）
+ (BOOL)checkWhetherMessageTimeDisplayed:(UdeskMessage *)previousMessage laterMessage:(UdeskMessage *)laterMessage {
    
    @try {
        
        if (!previousMessage || previousMessage == (id)kCFNull) return YES;
        if (!laterMessage || laterMessage == (id)kCFNull) return YES;
        
        if (![previousMessage isKindOfClass:[UdeskMessage class]]) return YES;
        if (![laterMessage isKindOfClass:[UdeskMessage class]]) return YES;
        
        NSInteger interval=[laterMessage.timestamp timeIntervalSinceDate:previousMessage.timestamp];
        if(interval>60*3) return YES;
        
        return NO;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

+ (NSString *)setupMessageBubble:(UdeskMessage *)currentMessage laterMessage:(UdeskMessage *)laterMessage previousMessage:(UdeskMessage *)previousMessage {
    
    //没有后一个消息
    if (!laterMessage && previousMessage) {
        
        return [self setupPreviousBubble:currentMessage previousMessage:previousMessage];
    }
    
    //没有前一个消息
    if (!previousMessage && laterMessage) {
        
        return [self setupLasterBubble:currentMessage laterMessage:laterMessage];
    }
    
    //前后都有消息
    if (previousMessage && laterMessage) {
        
        NSString *lasterBubble = [self setupLasterBubble:currentMessage laterMessage:laterMessage];
        NSString *previousBubble = [self setupPreviousBubble:currentMessage previousMessage:previousMessage];
        NSString *middleBubble = [self setupMiddleBubble:currentMessage laterMessage:laterMessage previousMessage:previousMessage];
        
        if (middleBubble) {
            return middleBubble;
        }
        
        if (lasterBubble) {
            return lasterBubble;
        }
        
        if (previousBubble) {
            return previousBubble;
        }
    }
    
    return nil;
}

+ (NSString *)setupLasterBubble:(UdeskMessage *)currentMessage laterMessage:(UdeskMessage *)laterMessage {
    
    if (currentMessage.agentJid && laterMessage.agentJid && ![currentMessage.agentJid isEqualToString:laterMessage.agentJid]) {
        return nil;
    }
    
    //消息间隔小于20s
    NSInteger interval = [currentMessage.timestamp timeIntervalSinceDate:laterMessage.timestamp];
    
    BOOL curMsgType = currentMessage.messageType == UDMessageContentTypeText;
    BOOL latMsgType = laterMessage.messageType == UDMessageContentTypeText;
    
    //不是同一个发送者
    if (currentMessage.messageFrom == laterMessage.messageFrom &&
        currentMessage.messageType == laterMessage.messageType &&
        curMsgType &&
        latMsgType &&
        interval >= -20) {
        
        NSString *currentBubble = @"udChatBubbleSendingSolid02.png";
        if (currentMessage.messageFrom == UDMessageTypeReceiving) {
            currentBubble = @"udChatBubbleReceivingSolid02.png";
        }
        return currentBubble;
    }
    
    return nil;
}

+ (NSString *)setupPreviousBubble:(UdeskMessage *)currentMessage previousMessage:(UdeskMessage *)previousMessage {
    
    if (currentMessage.agentJid && previousMessage.agentJid && ![currentMessage.agentJid isEqualToString:previousMessage.agentJid]) {
        return nil;
    }
    
    //消息间隔小于20s
    NSInteger interval = [currentMessage.timestamp timeIntervalSinceDate:previousMessage.timestamp];
    
    BOOL curMsgType = currentMessage.messageType == UDMessageContentTypeText;
    BOOL preMsgType = previousMessage.messageType == UDMessageContentTypeText;
    
    //不是同一个发送者
    if (currentMessage.messageFrom == previousMessage.messageFrom &&
        currentMessage.messageType == previousMessage.messageType &&
        curMsgType &&
        preMsgType &&
        interval <= 20) {
        
        NSString *currentBubble = @"udChatBubbleSendingSolid04.png";
        if (currentMessage.messageFrom == UDMessageTypeReceiving) {
            currentBubble = @"udChatBubbleReceivingSolid04.png";
        }
        return currentBubble;
    }
    
    return nil;
}

+ (NSString *)setupMiddleBubble:(UdeskMessage *)currentMessage laterMessage:(UdeskMessage *)laterMessage previousMessage:(UdeskMessage *)previousMessage {
    
    if (currentMessage.agentJid && laterMessage.agentJid && previousMessage.agentJid) {
        if (![currentMessage.agentJid isEqualToString:laterMessage.agentJid] || ![currentMessage.agentJid isEqualToString:previousMessage.agentJid]) {
            return nil;
        }
    }
    
    //消息间隔小于20s
    NSInteger laterInterval = [currentMessage.timestamp timeIntervalSinceDate:laterMessage.timestamp];
    NSInteger previousInterval = [currentMessage.timestamp timeIntervalSinceDate:previousMessage.timestamp];
    
    BOOL curMsgType = currentMessage.messageType == UDMessageContentTypeText;
    BOOL latMsgType = laterMessage.messageType == UDMessageContentTypeText;
    BOOL preMsgType = previousMessage.messageType == UDMessageContentTypeText;
    
    //不是同一个发送者
    if (currentMessage.messageFrom == laterMessage.messageFrom &&
        currentMessage.messageType == laterMessage.messageType &&
        curMsgType &&
        latMsgType &&
        laterInterval >= -20 &&
        currentMessage.messageFrom == previousMessage.messageFrom &&
        currentMessage.messageType == previousMessage.messageType &&
        preMsgType &&
        previousInterval <= 20) {
        
        NSString *currentBubble = @"udChatBubbleSendingSolid03.png";
        if (currentMessage.messageFrom == UDMessageTypeReceiving) {
            currentBubble = @"udChatBubbleReceivingSolid03.png";
        }
        return currentBubble;
    }
    
    return nil;
}

#pragma mark - 重发失败的消息
+ (NSTimer *)resendFailedMessage:(NSMutableArray *)resendMessageArray progress:(void(^)(float percent))progress completion:(void(^)(UdeskMessage *failedMessage))completion {
    
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
                                progress(percent);
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
