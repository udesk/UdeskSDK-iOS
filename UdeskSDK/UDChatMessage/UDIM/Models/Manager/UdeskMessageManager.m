//
//  UdeskMessageManager.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/18.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskMessageManager.h"
#import "UdeskManager.h"
#import "UdeskMessageUtil.h"
#import "UdeskQueueMessage.h"
#import "UdeskMessage+UdeskSDK.h"
#import "UdeskSDKAlert.h"
#import "UdeskBundleUtils.h"
#import "Udesk_YYWebImage.h"
#import "UdeskImageUtil.h"
#import "UdeskCacheUtil.h"
#import "UdeskLocationModel.h"
#import "UdeskGoodsModel.h"

@interface UdeskMessageManager()

/** 消息 */
@property (nonatomic, strong ,readwrite) NSArray *messagesArray;
/** 排队事件 */
@property (nonatomic, strong) UdeskQueueMessage *queueMessage;
/** 排队消息提示 */
@property (nonatomic, copy  ) NSString *queueMessageTips;
/** 重发消息Timer */
@property (nonatomic, strong) NSTimer *chatMsgTimer;
/** 临时 */
@property (nonatomic, strong) NSMutableArray *robotTempArray;
/** 线程 */
@property (nonatomic, strong) dispatch_queue_t messagesArrayModificationQueue;

@end

@implementation UdeskMessageManager

- (instancetype)initWithSetting:(UdeskSetting *)setting
{
    self = [super init];
    if (self) {
        _sdkSetting = setting;
        self.messagesArrayModificationQueue = dispatch_queue_create("com.udesk.sdk.message.array", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - 获取消息记录
- (void)fetchMessages {
    
    [self fetchDatabaseMessage:nil];
    [self fetchServersMessages];
}

//获取服务端消息
- (void)fetchServersMessages {
    
    @udWeakify(self);
    [UdeskManager fetchServersMessage:^(NSArray *msgList,NSError *error){
        @udStrongify(self);
        if (!error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.89 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self fetchDatabaseMessage:msgList];
            });
        }
    }];
}

//获取本地消息数据
- (void)fetchDatabaseMessage:(NSArray *)serverMsgList {
    
    @udWeakify(self);
    [UdeskManager fetchDatabaseMessagesWithDate:[NSDate date] result:^(NSArray *messagesArray,BOOL hasMore) {
        @udStrongify(self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.isShowRefresh = hasMore;
            if (messagesArray.count) {
                [self updateMessagesArrayWithMessages:messagesArray];
            }
            
            //极端情况下，读取数据库失败，把服务器上拉取的记录做一次处理
            if (serverMsgList.count > 0) {
                //重新排序
                NSArray *sortedMsgArray = [self mergeMessagesFromServers:serverMsgList dbMessages:messagesArray];
                if (sortedMsgArray && sortedMsgArray.count > 0) {
                    [self updateMessagesArrayWithMessages:sortedMsgArray];
                }
            }
            
            //更新排队文案
            [self updateQueueMessageInArray];
            //更新UI
            [self updateCallbackMessages];
        });
    }];
}

//更新消息数组
- (void)updateMessagesArrayWithMessages:(NSArray *)messagesArray {
    
    //添加临时消息
    NSMutableArray *array = [NSMutableArray arrayWithArray:messagesArray];
    [array addObjectsFromArray:[self temporaryMessages]];
    self.messagesArray = [UdeskMessageUtil chatMessageWithMsgModel:array lastMessage:nil];
}

//合并消息
- (NSArray *)mergeMessagesFromServers:(NSArray *)serversMessages dbMessages:(NSArray *)dbMessages {
    if (!serversMessages || serversMessages == (id)kCFNull || !serversMessages.count) return nil;
    if (!dbMessages || dbMessages == (id)kCFNull || !dbMessages.count) return nil;
    if (![serversMessages.firstObject isKindOfClass:[UdeskMessage class]]) return nil;
    if (![dbMessages.firstObject isKindOfClass:[UdeskMessage class]]) return nil;
    
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:dbMessages];
    BOOL somethingWrong = NO;
    for (UdeskMessage *msg in serversMessages) {
        if (![self checkMessage:msg existInList:tmpArray]) {
            [tmpArray addObject:msg];
            //有数据不一致
            if (!somethingWrong) {
                somethingWrong = YES;
            }
        }
    }
    //重新排序
    NSArray *sortedMsgArray;
    if (tmpArray.count > 0 && somethingWrong) {
        sortedMsgArray = [tmpArray sortedArrayUsingComparator:^NSComparisonResult(UdeskMessage * obj1, UdeskMessage * obj2) {
            if (obj2.timestamp && obj1.timestamp) {
                return [obj1.timestamp compare:obj2.timestamp];
            }
            return NSOrderedSame;
        }];
    }
    
    return sortedMsgArray;
}

//加载更多DB消息
- (void)fetchNextPageMessages {
    
    UdeskBaseMessage *lastMessage = self.messagesArray.firstObject;
    
    @udWeakify(self);
    [UdeskManager fetchServersMessage:^(NSArray *msgList, NSError *error) {
        @udStrongify(self);
        [self fetchNextPageDatebaseMessage:lastMessage.message.timestamp];
    }];
    
    [self fetchNextPageDatebaseMessage:lastMessage.message.timestamp];
}

- (void)fetchNextPageDatebaseMessage:(NSDate *)date {
    
    @udWeakify(self);
    [UdeskManager fetchDatabaseMessagesWithDate:date result:^(NSArray *messagesArray,BOOL hasMore) {
        @udStrongify(self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.isShowRefresh = hasMore;
            if (messagesArray.count) {
                
                NSArray *moreMessagesArray = [self mergeMessagesFromServers:messagesArray dbMessages:[self.messagesArray valueForKey:@"message"]];
                if (moreMessagesArray) {
                    self.messagesArray = [UdeskMessageUtil chatMessageWithMsgModel:moreMessagesArray lastMessage:nil];
                }
            }
            [self updateCallbackMoreMessages];
        });
    }];
}

//添加临时消息
- (NSArray *)temporaryMessages {
    
    NSMutableArray *array = [NSMutableArray array];
    
    //机器人
    if (self.isRobotSession && self.robotTempArray.count) {
        [array addObjectsFromArray:self.robotTempArray];
    }
    
    //留言文案
    UdeskMessage *leaveGuideMsg = [self leaveGuideMessage];
    if (leaveGuideMsg) {
        [array addObject:leaveGuideMsg];
    }
    
    return array;
}

//添加直接留言文案
- (void)addLeaveGuideMessageToArray {
    
    UdeskMessage *message = [self leaveGuideMessage];
    if (message) {
        [self addMessageToArray:@[message]];
    }
}

//留言文案消息
- (UdeskMessage *)leaveGuideMessage {
    
    //会话未创建
    if (self.agentModel.sessionType == UDAgentSessionTypeNotCreate && self.agentModel.statusType == UDAgentStatusResultOffline) {
        //直接留言/对话留言
        if (self.agentModel.leaveMessageType == UDAgentLeaveMessageTypeLeave || self.agentModel.leaveMessageType == UDAgentLeaveMessageTypeBoard) {
            if (![UdeskSDKUtil isBlankString:self.sdkSetting.leaveMessageGuide]) {
                UdeskMessage *guideMsg = [[UdeskMessage alloc] initWithRich:self.sdkSetting.leaveMessageGuide];
                return guideMsg;
            }
        }
    }
    
    return nil;
}

//添加排队消息
- (void)updateQueueMessageInArray {
    
    if (![UdeskSDKUtil isBlankString:self.queueMessageTips]) {
        
        NSString *string = [self.messagesArray componentsJoinedByString:@","];
        if ([string rangeOfString:@"UdeskQueueMessage"].location == NSNotFound || !self.messagesArray.count) {
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.messagesArray];
            [mArray addObject:self.queueMessage];
            self.messagesArray = mArray;
        }
        
        self.queueMessage.contentText = self.queueMessageTips;
    }
}

//收到撤回消息
- (void)receiveRollbackWithMessage:(UdeskMessage *)message {
    
    @try {
        
        for (UdeskBaseMessage *baseMessage in self.messagesArray) {
            
            if ([baseMessage.messageId isEqualToString:message.messageId]) {
                
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.messagesArray];
                if ([array containsObject:baseMessage]) {
                    [array removeObject:baseMessage];
                    self.messagesArray = array;
                }
                break;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//更新排队事件
- (void)updateQueueMessageWithContent:(NSString *)contentText {
    
    self.queueMessageTips = contentText;
    [self updateQueueMessageInArray];
    
    [self updateCallbackMessages];
}

//移除排队事件
- (void)removeQueueInArray {
    
    @try {
        
        //移除排队事件
        NSString *string = [self.messagesArray componentsJoinedByString:@","];
        if ([string rangeOfString:@"UdeskQueueMessage"].location != NSNotFound) {
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.messagesArray];
            for (UdeskBaseMessage *baseMsg in self.messagesArray) {
                if (baseMsg.message.messageType == UDMessageContentTypeQueueEvent) {
                    [array removeObject:baseMsg];
                    break;
                }
            }
            self.queueMessageTips = nil;
            self.messagesArray = array;
            [self updateCallbackMessages];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//排队消息
- (UdeskQueueMessage *)queueMessage {
    if (!_queueMessage) {
        _queueMessage = [[UdeskQueueMessage alloc] initWithMessage:[[UdeskMessage alloc] initWithQueue:self.queueMessageTips showLeaveMsgBtn:self.sdkSetting.enableWebImFeedback.boolValue] displayTimestamp:YES];
    }
    return _queueMessage;
}

//添加消息到数组
- (void)addMessageToArray:(NSArray *)messageArray {
    
    if (!messageArray || messageArray == (id)kCFNull) return ;
    if (![messageArray isKindOfClass:[NSArray class]]) return;
    
    dispatch_barrier_async(self.messagesArrayModificationQueue, ^{
       
        @try {
            UdeskMessage *lastMessage = [self getLastMessage];
            
            //这里把最后一个消息元素和新的消息元素一起传过去为了检查气泡形状是否需要修改
            NSMutableArray *msgsArray = [NSMutableArray array];
            if (lastMessage) {
                [msgsArray addObject:lastMessage];
            }
            [msgsArray addObjectsFromArray:messageArray];
            NSArray *array = [UdeskMessageUtil chatMessageWithMsgModel:msgsArray lastMessage:[self getSecondLastMessage]];
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.messagesArray];
            if (array) {
                //返回的数组包括了最后一个元素，所以这里要删除下
                [mArray removeLastObject];
                [mArray addObjectsFromArray:array];
            }
            self.messagesArray = mArray;
            [self updateCallbackMessages];
            [self checkTempStore:messageArray];
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    });
}

//检查需要暂时存储到内存的消息
- (void)checkTempStore:(NSArray *)messageArray {
    
    @try {
     
        for (UdeskMessage *message in messageArray) {
            if (![self.robotTempArray containsObject:message] && message.tempStore) {
                [self.robotTempArray addObject:message];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//获取最后一个消息对象
- (UdeskMessage *)getLastMessage {
    
    @try {
        
        UdeskMessage *lastMessage;
        if (self.messagesArray.count && [self.messagesArray.lastObject isKindOfClass:[UdeskBaseMessage class]]) {
            UdeskBaseMessage *baseMessage = (UdeskBaseMessage *)self.messagesArray.lastObject;
            lastMessage = baseMessage.message;
        }
        
        return lastMessage;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (UdeskMessage *)getSecondLastMessage {
    
    @try {
        
        UdeskMessage *secondLastMessage;
        if (self.messagesArray.count > 1) {
            UdeskBaseMessage *baseMessage = (UdeskBaseMessage *)[self.messagesArray objectAtIndex:self.messagesArray.count-2];
            secondLastMessage = baseMessage.message;
        }
        
        return secondLastMessage;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//去重
- (void)filterRepeatMessages {
    
    @try {
        
        NSMutableArray *empty = [NSMutableArray array];
        for (UdeskBaseMessage *baseMessage in self.messagesArray) {
            if (baseMessage && ![self checkMessage:baseMessage.message existInList:empty]) {
                [empty addObject:baseMessage];
            }
        }
        
        self.messagesArray = [empty copy];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//检查消息
- (BOOL)checkMessage:(UdeskMessage *)msg existInList:(NSArray *)array {
    for (UdeskMessage *tmp in array) {
        if ([tmp.messageId isEqualToString:msg.messageId]) {
            return YES;
        }
    }
    return  NO;
}

#pragma mark - 发送消息
- (void)sendRobotMessage:(UdeskMessage *)message completion:(void(^)(UdeskMessage *message))completion {
    
    if (!message || message == (id)kCFNull) return ;
    if (![message isKindOfClass:[UdeskMessage class]]) return ;
    
    [self addMessageToArray:@[message]];
    [UdeskManager sendMessage:message progress:nil completion:completion];
}

//发送文本消息
- (void)sendTextMessage:(NSString *)text completion:(void(^)(UdeskMessage *message))completion {
    if (!text || text == (id)kCFNull) return ;
    
    UdeskMessage *textMessage = [[UdeskMessage alloc] initWithText:text];
    textMessage.agentJid = self.agentModel.jid;
    //机器人会话
    if (self.isRobotSession) {
        textMessage.sendType = UDMessageSendTypeRobot;
    }
    
    //排队消息
    if (self.agentModel.statusType == UDAgentStatusResultQueue) {
        textMessage.sendType = UDMessageSendTypeQueue;
    }
    
    //会话未创建&客服离线
    if (self.agentModel.sessionType == UDAgentSessionTypeNotCreate && self.agentModel.statusType == UDAgentStatusResultOffline) {
         
        //客户发送离线留言
        if (self.agentModel.leaveMessageType == UDAgentLeaveMessageTypeLeave) {
            textMessage.sendType = UDMessageSendTypeLeave;
        }
        
        //客户发送对话留言
        if (self.agentModel.leaveMessageType == UDAgentLeaveMessageTypeBoard) {
            textMessage.sendType = UDMessageSendTypeBoard;
            //检查消息时间
            BOOL result = [self checkBoardMessageSendTime:textMessage];
            if (result) return;
        }
    }

    if (!textMessage || textMessage == (id)kCFNull) return ;
    [self addMessageToArray:@[textMessage]];
    [UdeskManager sendMessage:textMessage progress:nil completion:completion];
}

//发送图片消息
- (void)sendImageMessage:(UIImage *)image progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!image || image == (id)kCFNull) return ;
    if (![image isKindOfClass:[UIImage class]]) return ;
    
    UdeskMessage *imageMessage = [[UdeskMessage alloc] initWithImage:image];
    //排队消息
    if (self.agentModel.statusType == UDAgentStatusResultQueue) {
        imageMessage.sendType = UDMessageSendTypeQueue;
    }
    
    if (!imageMessage || imageMessage == (id)kCFNull) return ;
    //缓存图片
    [[Udesk_YYWebImageManager sharedManager].cache setImage:imageMessage.image forKey:imageMessage.messageId];
    
    [self addMessageToArray:@[imageMessage]];
    [UdeskManager sendMessage:imageMessage progress:^(float percent) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(imageMessage.messageId,percent);
            }
        });
        
    } completion:^(UdeskMessage *message) {
        //先移除缓存图片
        [[Udesk_YYWebImageManager sharedManager].cache removeImageForKey:imageMessage.messageId];
        [[Udesk_YYWebImageManager sharedManager].cache setImage:message.image forKey:message.content];
        if (completion) {
            completion(message);
        }
    }];
}

//发送GIF图片消息
- (void)sendGIFImageMessage:(NSData *)gifData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!gifData || gifData == (id)kCFNull) return ;
    if (![gifData isKindOfClass:[NSData class]]) return ;
    
    UdeskMessage *gifMessage = [self gifMessageWithData:gifData];
    //排队消息
    if (self.agentModel.statusType == UDAgentStatusResultQueue) {
        gifMessage.sendType = UDMessageSendTypeQueue;
    }
    
    if (!gifMessage || gifMessage == (id)kCFNull) return ;
    [self addMessageToArray:@[gifMessage]];
    [UdeskManager sendMessage:gifMessage progress:^(float percent) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(gifMessage.messageId,percent);
            }
        });
        
    } completion:completion];
}

- (UdeskMessage *)gifMessageWithData:(NSData *)gifData {
    
    Udesk_YYImage *image = [[Udesk_YYImage alloc] initWithData:gifData];
    UdeskMessage *gifMessage = [[UdeskMessage alloc] initWithGIF:gifData];
    gifMessage.image = image;
    CGSize size = [UdeskImageUtil udImageSize:image];
    gifMessage.width = size.width;
    gifMessage.height = size.height;
    
    //缓存图片
    [[Udesk_YYWebImageManager sharedManager].cache setImage:image forKey:gifMessage.messageId];
    
    return gifMessage;
}

//发送视频消息
- (void)sendVideoMessage:(NSData *)videoData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!videoData || videoData == (id)kCFNull) return ;
    if (![videoData isKindOfClass:[NSData class]]) return ;
    
    if (![[UdeskSDKUtil networkStatus] isEqualToString:@"wifi"]) {
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [UdeskSDKAlert showWithTitle:getUDLocalizedString(@"udesk_wwan_tips") message:getUDLocalizedString(@"udesk_video_send_tips") handler:^{
                [self confirmSendVideoMessage:videoData progress:progress completion:completion];
            }];
        });
        return;
    }
    
    [self confirmSendVideoMessage:videoData progress:progress completion:completion];
}

- (void)confirmSendVideoMessage:(NSData *)videoData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    UdeskMessage *videoMessage = [self videoMessageWithVideoData:videoData];
    //排队消息
    if (self.agentModel.statusType == UDAgentStatusResultQueue) {
        videoMessage.sendType = UDMessageSendTypeQueue;
    }
    
    if (!videoMessage || videoMessage == (id)kCFNull) return ;
    [self addMessageToArray:@[videoMessage]];
    
    [UdeskManager sendMessage:videoMessage progress:^(float percent) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(videoMessage.messageId,percent);
            }
        });
        
    } completion:completion];
}

- (UdeskMessage *)videoMessageWithVideoData:(NSData *)videoData {
    
    //超过发送限制
    CGFloat size = videoData.length/1024.f/1024.f;
    if (size > 31.f) {
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [UdeskSDKAlert showWithMessage:getUDLocalizedString(@"udesk_video_big_tips") handler:nil];
        });
        return nil;
    }
    
    UdeskMessage *videoMessage = [[UdeskMessage alloc] initWithVideo:videoData];
    //缓存视频
    [[UdeskCacheUtil sharedManager] storeVideo:videoData videoId:videoMessage.messageId];
    
    return videoMessage;
}

//发送语音消息
- (void)sendVoiceMessage:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration completion:(void (^)(UdeskMessage *message))completion {
    
    if (!voicePath || voicePath == (id)kCFNull) return ;
    if (![voicePath isKindOfClass:[NSString class]]) return ;
    if ([UdeskSDKUtil isBlankString:voicePath]) return ;
    
    UdeskMessage *voiceMessage = [self voiceMessageWithPath:voicePath duration:voiceDuration];
    //排队消息
    if (self.agentModel.statusType == UDAgentStatusResultQueue) {
        voiceMessage.sendType = UDMessageSendTypeQueue;
    }
    
    if (!voiceMessage || voiceMessage == (id)kCFNull) return ;
    [self addMessageToArray:@[voiceMessage]];
    [UdeskManager sendMessage:voiceMessage progress:nil completion:completion];
}

- (UdeskMessage *)voiceMessageWithPath:(NSString *)voicePath duration:(NSString *)duration {
    
    NSData *voiceData = [NSData dataWithContentsOfFile:voicePath];
    if (!voiceData || voiceData == (id)kCFNull) return nil;
    
    UdeskMessage *voiceMessage = [[UdeskMessage alloc] initWithVoice:voiceData duration:duration];
    [[UdeskCacheUtil sharedManager] setObject:voiceData forKey:voiceMessage.messageId];
    
    return voiceMessage;
}

//发送地理位置
- (void)sendLocationMessage:(UdeskLocationModel *)model completion:(void(^)(UdeskMessage *message))completion {
    
    if (!model || model == (id)kCFNull) return ;
    if (![model isKindOfClass:[UdeskLocationModel class]]) return ;
    
    UdeskMessage *locationMessage = [self locationMessageWithModel:model];
    //排队消息
    if (self.agentModel.statusType == UDAgentStatusResultQueue) {
        locationMessage.sendType = UDMessageSendTypeQueue;
    }
    
    if (!locationMessage || locationMessage == (id)kCFNull) return ;
    [self addMessageToArray:@[locationMessage]];
    [UdeskManager sendMessage:locationMessage progress:nil completion:completion];
}

- (UdeskMessage *)locationMessageWithModel:(UdeskLocationModel *)locationModel {
    
    UdeskMessage *locationMsg = [[UdeskMessage alloc] initWithLocation:locationModel];
    [[Udesk_YYWebImageManager sharedManager].cache setImage:locationModel.image forKey:locationMsg.messageId];
    
    return locationMsg;
}

//发送商品消息
- (void)sendGoodsMessage:(UdeskGoodsModel *)model completion:(void(^)(UdeskMessage *message))completion {
    
    if (!model || model == (id)kCFNull) return ;
    if (![model isKindOfClass:[UdeskGoodsModel class]]) return ;
    
    UdeskMessage *goodsMessage = [[UdeskMessage alloc] initWithGoods:model];
    //排队消息
    if (self.agentModel.statusType == UDAgentStatusResultQueue) {
        goodsMessage.sendType = UDMessageSendTypeQueue;
    }
    
    if (!goodsMessage || goodsMessage == (id)kCFNull) return ;
    [self addMessageToArray:@[goodsMessage]];
    [UdeskManager sendMessage:goodsMessage progress:nil completion:completion];
}

#pragma mark - 回调更新
- (void)updateCallbackMessages {
    
    //过滤
    [self filterRepeatMessages];
    
    if (self.didUpdateMessagesBlock) {
        self.didUpdateMessagesBlock(self.messagesArray);
    }
}

- (void)updateCallbackMoreMessages {
    
    //过滤
    [self filterRepeatMessages];
    
    if (self.didUpdateMoreMessagesBlock) {
        self.didUpdateMoreMessagesBlock(self.messagesArray);
    }
}

//检查工作台留言消息时间
- (BOOL)checkBoardMessageSendTime:(UdeskMessage *)message {
    
    UdeskBaseMessage *baseMessage = self.messagesArray.lastObject;
    if (baseMessage.message.sendType == UDMessageSendTypeBoard) {
        
        //检查与上条消息是否超过两分钟
        NSInteger timeInterval = [message.timestamp timeIntervalSinceDate:baseMessage.message.timestamp];
        if (timeInterval > (60 * 2)) {
        
            if (self.updateAgentInfo) {
                self.updateAgentInfo(message);
            }
            return YES;
        }
    }
    
    return NO;
}

//会话已关闭
- (void)sessionClosed {
    [self.robotTempArray removeAllObjects];
}

- (NSMutableArray *)robotTempArray {
    if (!_robotTempArray) {
        _robotTempArray = [NSMutableArray array];
    }
    return _robotTempArray;
}

@end
