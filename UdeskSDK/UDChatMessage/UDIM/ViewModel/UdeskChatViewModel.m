//
//  UdeskChatViewModel.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/19.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskChatViewModel.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKMacro.h"
#import "UdeskReachability.h"
#import "UdeskMessage+UdeskSDK.h"
#import "UdeskProductMessage.h"
#import "UdeskQueueMessage.h"
#import "UdeskSDKConfig.h"
#import "UdeskBundleUtils.h"
#import "Udesk_YYWebImage.h"
#import "UdeskCacheUtil.h"
#import "UdeskLocationModel.h"
#import "UdeskGoodsModel.h"
#import "UdeskSDKAlert.h"
#import "UdeskAgentUtil.h"
#import "UdeskMessageUtil.h"
#import "UdeskManager.h"
#import "UdeskImageUtil.h"
#import "UdeskThrottleUtil.h"

#if __has_include(<UdeskCall/UdeskCall.h>)
#import <UdeskCall/UdeskCall.h>
#import <AVFoundation/AVFoundation.h>
#import "UdeskAgoraRtcEngineManager.h"
@interface UdeskChatViewModel()<UDManagerDelegate,UdeskCallSessionManagerDelegate>
#else
@interface UdeskChatViewModel()<UDManagerDelegate>
#endif

/** 消息 */
@property (nonatomic, strong ,readwrite) NSArray       *messagesArray;
/** 失败的消息 */
@property (nonatomic, strong) NSMutableArray           *resendArray;
/** sdk后台配置 */
@property (nonatomic, strong) UdeskSetting             *sdkSetting;
/** 客服Model */
@property (nonatomic, strong) UdeskAgent               *agentModel;
/** 客户Model */
@property (nonatomic, strong) UdeskCustomer            *customerModel;
/** 网络状态检测 */
@property (nonatomic        ) UdeskReachability        *reachability;
/** 网络切换 */
@property (nonatomic, assign) BOOL                     netWorkChange;
/** 是否关闭会话 */
@property (nonatomic, assign) BOOL                     isOverConversion;
/** 黑名单提示语 */
@property (nonatomic, copy  ) NSString                 *blackedMessage;
/** 是否显示客户留言事件 */
@property (nonatomic, assign) BOOL                     leaveMsgFlag;
/** 最后一条离线消息时间 */
@property (nonatomic, copy  ) NSString                 *lastLeaveMsgDate;
/** 无消息会话ID */
@property (nonatomic, strong, readwrite) NSNumber      *preSessionId;
/** 直接留言引导语 */
@property (nonatomic, assign) BOOL                     leaveMsgGuideSendFlag;
/** 无消息对话过滤时发送的消息 */
@property (nonatomic, strong) NSMutableArray           *preSessionMessages;
/** 无消息对话过滤发送消息状态回调 */
@property (nonatomic, copy  ) void(^preSessionMessageSendStatusBlock)(UdeskMessage *message);

/** 排队事件 */
@property (nonatomic, strong) UdeskQueueMessage *queueMessage;
/** 排队消息最大 */
@property (nonatomic, copy  ) NSString          *queueMessageMaxTips;

#if __has_include(<UdeskCall/UdeskCall.h>)
/** 用户ID */
@property (nonatomic, copy            ) NSString                 *currentUserId;
/** 铃声播放 */
@property (nonatomic, strong          ) AVAudioPlayer            *audioPlayer;
#endif

@end

@implementation UdeskChatViewModel

- (instancetype)initWithSDKSetting:(UdeskSetting *)sdkSetting
{
    self = [super init];
    if (self) {
        
        _leaveMsgFlag = YES;
        _sdkSetting = sdkSetting;
        //UdeskSDK代理
        [UdeskManager receiveUdeskDelegate:self];
        //获取db消息
        [self fetchDatabaseMessage:nil];
        //注册通知
        [self registrationNotice];
        //检测网络
        [self startDetectNetwork];
        //检测sdk配置
        [self checkSDKSetting];
    }
    return self;
}

#pragma mark - 注册通知
- (void)registrationNotice {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udeskCallApplicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udeskCallApplicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
#endif
}

#pragma mark - 网络监测
- (void)startDetectNetwork {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udIMReachabilityChanged:) name:kUdeskReachabilityChangedNotification object:nil];
    self.reachability = [UdeskReachability reachabilityWithHostName:@"www.baidu.com"];
    [self.reachability startNotifier];
}

#pragma mark - 检查SDK配置
- (void)checkSDKSetting {
    
    if (!self.sdkSetting || self.sdkSetting == (id)kCFNull ||
        ![self.sdkSetting isKindOfClass:[UdeskSetting class]]) {
        [UdeskManager getServerSDKSetting:^(UdeskSetting *setting) {
            
            //根据后台配置创建用户
            self.sdkSetting = setting;
            [self createServerCustomer];
            
        } failure:^(NSError *error) {
            //根据后台配置创建用户
            [self createServerCustomer];
        }];
        return;
    }
    
    //根据后台配置创建用户
    [self createServerCustomer];
}

#pragma mark - 创建客户
- (void)createServerCustomer {
    
    @udWeakify(self);
    //创建用户(为了保证sdk正常使用请不要删除使用UdeskManager的方法)
    [UdeskManager createServerCustomerCompletion:^(UdeskCustomer *customer, NSError *error) {
        
        @udStrongify(self);
        //获取留言
        self.customerModel = customer;
        [self fetchNewAgentTickeReply];
        
        if (customer) {
            //请求客服数据(为了保证sdk正常使用请不要删除使用UdeskManager的方法)
            [self fetchServersAgent:nil];
        }
        else {
            
            //客户在黑名单
            if ([UdeskManager isBlacklisted]) {
                [self customerBlacklisted:error.userInfo[@"message"]];
            }
            NSLog(@"Udesk SDK初始化失败，请查看控制台LOG");
        }
    } preSessionEnbaleCallback:^(UdeskCustomer *customer, NSString *preSessionTitle) {
        
        @udStrongify(self);
        if (self.preSessionId || self.isOverConversion) {
            return ;
        }
        
        if (self.agentModel && self.agentModel.code != UDAgentConversationOver && self.agentModel.code != UDAgentStatusResultNotNetWork) {
            [self updateCurrentSessionAgent:self.agentModel completion:nil];
            return ;
        }
        
        self.customerModel = customer;
        if (self.delegate && [self.delegate respondsToSelector:@selector(showPreSessionWithTitle:)]) {
            [self.delegate showPreSessionWithTitle:preSessionTitle];
        }
        [self createPreSession];
        [UdeskSDKAlert hide];
    }];
}

//客户在黑名单
- (void)customerBlacklisted:(NSString *)message {
    
    _blackedMessage = message;
    //退出
    [UdeskManager setupCustomerOffline];
    
    self.agentModel.message = [UdeskSDKUtil isBlankString:message]?getUDLocalizedString(@"udesk_im_title_blocked_list"):message;
    self.agentModel.code = UDAgentStatusResultUnKnown;
    [self callbackAgentModel:self.agentModel];
    
    //显示客户黑名单提示
    [self showBlacklisted:message];
}

#pragma mark - 无消息会话
- (void)createPreSession {
    
    @udWeakify(self);
    [UdeskManager createPreSessionWithAgentId:[self udAgentId] groupId:[self udGroupId] completion:^(NSNumber *preSessionId,NSError *error) {
        @udStrongify(self);
        self.preSessionId = preSessionId;
    }];
}

#pragma mark - 请求客服数据
- (void)fetchServersAgent:(void(^)(UdeskAgent *agentModel))completion {
    
    //会话已关闭
    if (self.isOverConversion) {
        return;
    }
    
    //无消息过滤状态下
    if (self.preSessionId) {
        return;
    }
    
    [self requestAgentDataWithPreSessionMessage:nil completion:completion];
}

- (void)requestAgentDataWithPreSessionMessage:(UdeskMessage *)preSessionMessage completion:(void(^)(UdeskAgent *agentModel))completion {
    
    NSString *agentId = [self udAgentId];
    NSString *groupId = [self udGroupId];
    
    @udWeakify(self);
    //获取客服信息
    if (![UdeskSDKUtil isBlankString:agentId]) {
        //获取指定客服ID的客服信息
        [UdeskAgentUtil fetchAgentWithAgentId:agentId preSessionId:self.preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agentModel, NSError *error) {
            @udStrongify(self);
            [self updateCurrentSessionAgent:agentModel completion:completion];
        }];
    }
    else if (![UdeskSDKUtil isBlankString:groupId]) {
        //获取指定客服组ID的客服组信息
        [UdeskAgentUtil fetchAgentWithGroupId:groupId preSessionId:self.preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agentModel, NSError *error) {
            @udStrongify(self);
            [self updateCurrentSessionAgent:agentModel completion:completion];
        }];
    }
    else {
        
        //根据管理员后台配置选择客服
        [UdeskAgentUtil fetchAgentWithPreSessionId:self.preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agentModel, NSError *error) {
            @udStrongify(self);
            [self updateCurrentSessionAgent:agentModel completion:completion];
        }];
    }
}

//客服组ID
- (NSString *)udGroupId {
    
    NSString *groupId = [UdeskSDKConfig customConfig].groupId;
    if ([UdeskSDKUtil isBlankString:groupId]) {
        return [UdeskSDKUtil getGroupId];
    }
    else {
        return groupId;
    }
}

//客服ID
- (NSString *)udAgentId {
    return [UdeskSDKConfig customConfig].agentId;
}

//获取分配客服
- (void)updateCurrentSessionAgent:(UdeskAgent *)agentModel completion:(void(^)(UdeskAgent *agentModel))completion {
    //初始化视频(需要在获取到客服信息时配置)
#if __has_include(<UdeskCall/UdeskCall.h>)
    [self setupUdeskVideoCallWithCustomer:self.customerModel agent:agentModel];
#endif
    //清空无消息会话ID
    self.preSessionId = nil;
    //获取会话记录
    [self fetchSessionMessages:[NSString stringWithFormat:@"%ld",agentModel.imSubSessionId]];
    //回调客服信息到vc显示
    [self callbackAgentModel:agentModel];
    
    //客服离线
    if (agentModel.code != UDAgentStatusResultOnline) {
        
        //排队
        if (agentModel.code == UDAgentStatusResultQueue) {
            [self showQueueEvent];
        }
        else {
            if (!self.isNotShowAlert) {
                [self agentOffline];
            }
        }
    }
    else {
        //客服在线
        [self agentOnline];
    }
    
    if (completion) {
        completion(agentModel);
    }
}

//客服离线
- (void)agentOffline {
    
    //放弃排队
    [self quitQueue];
    
    //开启留言
    if (self.sdkSetting.enableWebImFeedback.boolValue && [self.sdkSetting.leaveMessageType isEqualToString:@"msg"]) {
        [self sendLeaveMsg];
        return;
    }
    
    [self showAgentStatusAlert];
}

//客服在线
- (void)agentOnline {
    
    //登陆成功回调
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    if (sdkConfig.actionConfig.loginSuccessBlock) {
        sdkConfig.actionConfig.loginSuccessBlock();
    }
    
    //咨询对象
    if (sdkConfig.productDictionary) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UdeskMessage *productMessage = [[UdeskMessage alloc] initWithProduct:sdkConfig.productDictionary];
            [UdeskManager sendMessage:productMessage progress:nil completion:nil];
        });
    }
    
    //移除排队事件
    [self removeQueueEvent];
    
    //隐藏弹窗
    [UdeskSDKAlert hide];
    //客服在线 关闭推送
    [UdeskManager endUdeskPush];
}

//显示排队事件
- (void)showQueueEvent {
    
    @try {
        
        NSString *string = [self.messagesArray componentsJoinedByString:@","];
        if ([string rangeOfString:@"UdeskQueueMessage"].location == NSNotFound || !self.messagesArray.count) {
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.messagesArray];
            [mArray addObject:self.queueMessage];
            self.messagesArray = mArray;
        }
        
        self.queueMessage.contentText = self.agentModel.message;
        [self updateContent];
        [UdeskSDKAlert hide];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//回调客服信息到vc显示
- (void)callbackAgentModel:(UdeskAgent *)agentModel {
    
    if ([UdeskSDKUtil isBlankString:agentModel.nick]) {
        agentModel.nick = self.agentModel.nick;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFetchAgentModel:)]) {
        [self.delegate didFetchAgentModel:agentModel];
    }
    
    self.agentModel = agentModel;
}

#pragma mark - 离线留言
- (void)fetchNewAgentTickeReply {
    
    @udWeakify(self);
    [self fetchAgentTicketReply:nil completion:^(NSArray *dataSource) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            @try {
                
                @udStrongify(self);
                if (dataSource.count) {
                    NSMutableArray *array = [NSMutableArray arrayWithArray:self.messagesArray];
                    [array addObjectsFromArray:[UdeskMessageUtil udeskMsgModelWithleaveMsg:dataSource messagesArray:self.messagesArray]];
                    self.messagesArray = array;
                }
                //更新UI
                [self updateContent];
            } @catch (NSException *exception) {
                NSLog(@"%@",exception);
            } @finally {
            }
        });
    }];
}

//上一次的留言
- (void)fetchOldAgentTickeReply:(void(^)(NSInteger count))completion {
    
    @udWeakify(self);
    [self fetchAgentTicketReply:self.lastLeaveMsgDate completion:^(NSArray *dataSource) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            @try {
                
                if (dataSource.count) {
                    
                    NSArray *moreMessageArray = [UdeskMessageUtil udeskMsgModelWithleaveMsg:dataSource messagesArray:self.messagesArray];
                    NSRange range = NSMakeRange(0, [moreMessageArray count]);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    
                    @udStrongify(self);
                    if (moreMessageArray.count) {
                        NSMutableArray *array = [NSMutableArray arrayWithArray:self.messagesArray];
                        [array insertObjects:moreMessageArray atIndexes:indexSet];
                        self.messagesArray = array;
                        //更新UI
                        [self updateContent];
                    }
                }
                if (completion) {
                    completion(dataSource.count);
                }
            } @catch (NSException *exception) {
                NSLog(@"%@",exception);
            } @finally {
            }
        });
    }];
}

- (void)fetchAgentTicketReply:(NSString *)date completion:(void(^)(NSArray *dataSource))completion {
    
    @udWeakify(self);
    [UdeskManager fetchAgentTicketReply:date success:^(NSArray *dataSource,NSString *lastDate) {
        
        @udStrongify(self);
        self.lastLeaveMsgDate = lastDate;
        if (dataSource.count==20) {
            self.isShowRefresh = YES;
        }
        
        if (completion) {
            completion(dataSource);
        }
        
    } failure:^(NSError *error) {
        
        NSLog(@"%@",error);
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - 本地消息数据
- (void)fetchDatabaseMessage:(NSArray *)serverMsgList {
    
    [UdeskManager getHistoryMessagesFromDatabaseWithMessageDate:[NSDate date] messagesNumber:20 result:^(NSArray *messagesArray) {
        
        if (messagesArray.count == 20) {
            self.isShowRefresh = YES;
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            if (messagesArray.count) {
                self.messagesArray = [UdeskMessageUtil chatMessageWithMsgModel:messagesArray agentNick:self.agentModel.nick lastMessage:nil];
            }
            
            //极端情况下，读取数据库失败，把服务器上拉取的记录做一次处理
            if (serverMsgList.count > 0) {
                NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.messagesArray];
                NSArray *msgList = [UdeskMessageUtil chatMessageWithMsgModel:serverMsgList agentNick:self.agentModel.nick lastMessage:nil];
                //加一个标志，只有在异常的情况下才重新排序
                BOOL somethingWrong = NO;
                for (UdeskBaseMessage *msg in msgList) {
                    if (![self checkMessage:msg existInList:tmpArray]) {
                        [tmpArray addObject:msg];
                        //有数据不一致
                        if (!somethingWrong) {
                            somethingWrong = YES;
                        }
                    }
                }
                //重新排序
                if (tmpArray.count > 0 && somethingWrong) {
                    self.messagesArray = [tmpArray sortedArrayUsingComparator:^NSComparisonResult(UdeskBaseMessage * obj1, UdeskBaseMessage * obj2) {
                        if (obj2.message.timestamp && obj1.message.timestamp) {
                            return [obj1.message.timestamp compare:obj2.message.timestamp];
                        }
                        return NSOrderedSame;
                    }];
                }
            }
            
            //添加留言文案
            [self appendLeaveMessageGuide];
            //添加咨询对象
            [self appendProductMsg];
            //更新UI
            [self updateContent];
        });
    }];
}

//添加咨询对象
- (void)appendProductMsg {
    
    @try {
        
        //咨询对象
        if ([UdeskSDKConfig customConfig].productDictionary) {
            
            if (![self.messagesArray.firstObject isKindOfClass:[UdeskProductMessage class]]) {
                UdeskMessage *productMsg = [[UdeskMessage alloc] initWithProduct:[UdeskSDKConfig customConfig].productDictionary];
                [self addMessageToChatMessageArray:@[productMsg]];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//添加直接留言文案
- (void)appendLeaveMessageGuide {
    
    @try {
        
        if (self.agentModel.code == UDAgentStatusResultLeaveMessage &&
            [self.sdkSetting.leaveMessageType isEqualToString:@"msg"]) {
            
            if (![UdeskSDKUtil isBlankString:self.sdkSetting.leaveMessageGuide]) {
                UdeskMessage *guideMsg = [[UdeskMessage alloc] initWithRich:self.sdkSetting.leaveMessageGuide];
                [self addMessageToChatMessageArray:@[guideMsg]];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 加载更多DB消息
- (void)fetchNextPageDatebaseMessage {
    
    @udWeakify(self);
    [self fetchOldAgentTickeReply:^(NSInteger count) {
        
        if (count == 0) {
            
            @udStrongify(self);
            UdeskBaseMessage *lastMessage = self.messagesArray.firstObject;
            //根据最后列表最后一条消息的时间获取历史记录
            [UdeskManager getHistoryMessagesFromDatabaseWithMessageDate:lastMessage.message.timestamp messagesNumber:20 result:^(NSArray *messagesArray) {
                
                if (messagesArray.count) {
                    self.isShowRefresh = messagesArray.count>19 ? YES : NO;
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        
                        @try {
                            
                            if (messagesArray.count) {
                                
                                NSRange range = NSMakeRange(0, [messagesArray count]);
                                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                                
                                NSArray *moreMessageArray = [UdeskMessageUtil chatMessageWithMsgModel:messagesArray agentNick:self.agentModel.nick lastMessage:nil];
                                if (moreMessageArray.count) {
                                    NSMutableArray *array = [NSMutableArray arrayWithArray:self.messagesArray];
                                    [array insertObjects:moreMessageArray atIndexes:indexSet];
                                    self.messagesArray = array;
                                    //更新UI
                                    [self updateContent];
                                }
                            }
                        } @catch (NSException *exception) {
                            NSLog(@"%@",exception);
                        } @finally {
                        }
                    });
                }
                else {
                    //没有数据不展示下拉刷新按钮
                    self.isShowRefresh = NO;
                }
            }];
        }
    }];
}

#pragma mark - UDManagerDelegate
- (void)didReceiveMessages:(UdeskMessage *)message {
    
    @try {
        
        if (!message || message == (id)kCFNull) return ;
        if ([UdeskSDKUtil isBlankString:message.content]) return;
        
        //收到消息时当前客服状态不在线 请求客服验证
        if (self.agentModel && self.agentModel.code != UDAgentStatusResultOnline) {
            [self fetchServersAgent:nil];
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self addMessageToChatMessageArray:@[message]];
        });
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//接受到转接
- (void)didReceiveRedirect:(UdeskAgent *)agent {
    
    [self callbackAgentModel:agent];
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    [self setupUdeskVideoCallWithCustomer:self.customerModel agent:agent];
#endif
}

//接收客服状态
- (void)didReceivePresence:(NSDictionary *)presence {
    
    @try {
        
        //客服上线
        NSString *statusType = [NSString stringWithFormat:@"%@",[presence objectForKey:@"type"]];
        if ([UdeskSDKUtil isBlankString:self.agentModel.jid] && [statusType isEqualToString:@"available"]) {
            [self fetchServersAgent:nil];
            return;
        }
        
        //直接留言 不切换客服的状态
        if (self.agentModel.code == UDAgentStatusResultLeaveMessage) {
            return;
        }
        
        UDAgentStatusType agentCode = UDAgentStatusResultOffline;
        NSString *agentMessage = @"unavailable";
        NSString *agentNick = self.agentModel.nick;
        //容错处理
        if ([UdeskSDKUtil isBlankString:agentNick]) {
            agentNick = @"";
        }
        
        if([statusType isEqualToString:@"over"]) {
            
            agentCode = UDAgentConversationOver;
            agentMessage = getUDLocalizedString(@"udesk_chat_end");
            self.isOverConversion = YES;
        }
        else if ([statusType isEqualToString:@"available"]) {
            
            agentCode = UDAgentStatusResultOnline;
            agentMessage = [NSString stringWithFormat:@"%@ %@ %@",getUDLocalizedString(@"udesk_agent"),agentNick,getUDLocalizedString(@"udesk_online")];
            
        }
        else if ([statusType isEqualToString:@"unavailable"]) {
            
            agentCode = UDAgentStatusResultOffline;
            agentMessage = [NSString stringWithFormat:@"%@ %@ %@",getUDLocalizedString(@"udesk_agent"),agentNick,getUDLocalizedString(@"udesk_offline")];
        }
        
        
        //与上次不同的code才抛给vc
        if (self.agentModel.code != agentCode) {
            self.agentModel.code = agentCode;
            self.agentModel.message = agentMessage;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveAgentPresence:)]) {
                [self.delegate didReceiveAgentPresence:self.agentModel];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//接收客服发送的满意度调查
- (void)didReceiveSurveyWithAgentId:(NSString *)agentId {
    
    if ([UdeskSDKUtil isBlankString:agentId]) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveSurveyWithAgentId:)]) {
        [self.delegate didReceiveSurveyWithAgentId:agentId];
    }
}

//收到客服工单回复
- (void)didReceiveTicketReply {
    
    [self fetchNewAgentTickeReply];
}

//收到撤回消息
- (void)didReceiveRollback:(NSString *)messageId agentNick:(NSString *)agentNick {
    
    @try {
        
        for (UdeskBaseMessage *baseMessage in self.messagesArray) {
            
            if ([baseMessage.messageId isEqualToString:messageId]) {
                
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.messagesArray];
                if ([array containsObject:baseMessage]) {
                    [array removeObject:baseMessage];
                    self.messagesArray = array;
                }
                
                if ([UdeskSDKUtil isBlankString:agentNick]) {
                    agentNick = self.agentModel.nick;
                }
                UdeskMessage *message = [[UdeskMessage alloc] initWithRollback:agentNick];
                [self addMessageToChatMessageArray:@[message]];
                
                break;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//需要重新拉下消息
- (void)fetchSessionMessages:(NSString *)sessionId {
    if (!sessionId || sessionId == (id)kCFNull) return ;
    if (![sessionId isKindOfClass:[NSString class]]) return ;
    if ([sessionId isEqualToString:@"0"]) return;
    
    @udWeakify(self);
    [UdeskManager fetchServersMessageWithSessionId:sessionId completion:^(NSError *error, NSArray *msgList){
        @udStrongify(self);
        if (!error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.89 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self fetchDatabaseMessage:msgList];
            });
        }
    }];
}

//请求客服信息，创建会话
- (void)fetchAgentAgainCreateSession {
    
    //客服已经关闭会话
    if (!self.agentModel) {
        self.agentModel = [[UdeskAgent alloc] init];
    }
    self.isOverConversion = YES;
    self.agentModel.message = getUDLocalizedString(@"udesk_chat_end");
    self.agentModel.code = UDAgentConversationOver;
    [self callbackAgentModel:self.agentModel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isOverConversion = NO;
        self.sdkSetting = nil;
        [self checkSDKSetting];
    });
}

#pragma mark - 发送文字消息
- (void)sendTextMessage:(NSString *)text completion:(void(^)(UdeskMessage *message))completion {
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *textMessage = [[UdeskMessage alloc] initWithText:text];
        if (textMessage) {
            @udWeakify(self);
            [self endPreSessionWithMessage:textMessage delay:0 completion:^{
                @udStrongify(self);
                [self addMessageToChatMessageArray:@[textMessage]];
            }];
        }
        return;
    }
    
    if ([UdeskSDKUtil isBlankString:text]) {
        [UdeskSDKAlert showWithMsg:getUDLocalizedString(@"udesk_no_send_empty")];
        return;
    }
    
    //排队消息
    if (_agentModel.code == UDAgentStatusResultQueue) {
        UdeskMessage *textMessage = [[UdeskMessage alloc] initWithText:text];
        [self sendQueueMessage:textMessage progress:nil completion:completion];
        return;
    }
    
    if (_agentModel.code != UDAgentStatusResultOnline &&
        _agentModel.code != UDAgentStatusResultLeaveMessage) {
        
        [self showAgentStatusAlert];
        return;
    }
    
    //客户发送离线留言
    if (_agentModel.code == UDAgentStatusResultLeaveMessage) {
        
        //消息内容
        UdeskMessage *message = [[UdeskMessage alloc] initWithLeaveMessage:text leaveMessageFlag:_leaveMsgFlag];
        //发送离线留言
        [UdeskManager sendMessage:message progress:nil completion:completion];
        
        //显示客户留言事件
        if (_leaveMsgFlag) {
            
            UdeskMessage *leaveMessage = [[UdeskMessage alloc] initWithLeaveEventMessage:getUDLocalizedString(@"udesk_customer_leave_msg")];
            if (leaveMessage) {
                [self addMessageToChatMessageArray:@[leaveMessage]];
            }
            _leaveMsgFlag = NO;
        }
        
        //消息要在事件之后
        if (message) {
            [self addMessageToChatMessageArray:@[message]];
        }
    }
    else {
        
        UdeskMessage *textMessage = [[UdeskMessage alloc] initWithText:text];
        if (textMessage) {
            [self addMessageToChatMessageArray:@[textMessage]];
            [UdeskManager sendMessage:textMessage progress:nil completion:completion];
        }
    }
    
    //通知刷新UI
    [self updateContent];
}

#pragma mark - 发送图片消息
- (void)sendImageMessage:(UIImage *)image progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!image || image == (id)kCFNull) return ;
    if (![image isKindOfClass:[UIImage class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        [self.preSessionMessages addObject:image];
        ud_dispatch_throttle(0.5f, ^{
            UIImage *preImage = self.preSessionMessages.firstObject;
            UdeskMessage *imageMessage = [[UdeskMessage alloc] initWithImage:preImage];
            if (imageMessage) {
                @udWeakify(self);
                [[Udesk_YYWebImageManager sharedManager].cache setImage:imageMessage.image forKey:imageMessage.messageId];
                [self endPreSessionWithMessage:imageMessage delay:0.8f completion:^{
                    @udStrongify(self);
                    [self addMessageToChatMessageArray:@[imageMessage]];
                    for (int i = 1; i<self.preSessionMessages.count; i++) {
                        UIImage *otherPreImage = self.preSessionMessages[i];
                        [self sendImageMessage:otherPreImage progress:progress completion:completion];
                    }
                }];
            }
        });
        return;
    }
    
    //排队消息
    if (_agentModel.code == UDAgentStatusResultQueue) {
        UdeskMessage *imageMessage = [[UdeskMessage alloc] initWithImage:image];
        [[Udesk_YYWebImageManager sharedManager].cache setImage:imageMessage.image forKey:imageMessage.messageId];
        [self sendQueueMessage:imageMessage progress:progress completion:completion];
        return;
    }
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        [self showAgentStatusAlert];
        return;
    }
    
    UdeskMessage *imageMessage = [[UdeskMessage alloc] initWithImage:image];
    if (imageMessage) {
        //缓存图片
        [[Udesk_YYWebImageManager sharedManager].cache setImage:imageMessage.image forKey:imageMessage.messageId];
        [self addMessageToChatMessageArray:@[imageMessage]];
        [UdeskManager sendMessage:imageMessage progress:^(float percent) {
            
            if (progress) {
                progress(imageMessage.messageId,percent);
            }
            
        } completion:^(UdeskMessage *message) {
            //先移除缓存图片
            [[Udesk_YYWebImageManager sharedManager].cache removeImageForKey:imageMessage.messageId];
            [[Udesk_YYWebImageManager sharedManager].cache setImage:message.image forKey:message.content];
            if (completion) {
                completion(message);
            }
        }];
    }
}

#pragma mark - 发送GIF图片消息
- (void)sendGIFImageMessage:(NSData *)gifData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!gifData || gifData == (id)kCFNull) return ;
    if (![gifData isKindOfClass:[NSData class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        [self.preSessionMessages addObject:gifData];
        ud_dispatch_throttle(0.5f, ^{
            NSData *preGifData = self.preSessionMessages.firstObject;
            UdeskMessage *gifMessage = [self gifMessageWithData:preGifData];
            if (gifMessage) {
                @udWeakify(self);
                [self endPreSessionWithMessage:gifMessage delay:0.8f completion:^{
                    @udStrongify(self);
                    [self addMessageToChatMessageArray:@[gifMessage]];
                    for (int i = 1; i<self.preSessionMessages.count; i++) {
                        NSData *preGifData = self.preSessionMessages[i];
                        [self sendGIFImageMessage:preGifData progress:progress completion:completion];
                    }
                }];
            }
        });
        return;
    }
    
    //排队消息
    if (_agentModel.code == UDAgentStatusResultQueue) {
        UdeskMessage *gifMessage = [self gifMessageWithData:gifData];
        [self sendQueueMessage:gifMessage progress:progress completion:completion];
        return;
    }
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        [self showAgentStatusAlert];
        return;
    }
    
    UdeskMessage *gifMessage = [self gifMessageWithData:gifData];
    if (gifMessage) {
        [self addMessageToChatMessageArray:@[gifMessage]];
        [UdeskManager sendMessage:gifMessage progress:^(float percent) {
            
            if (progress) {
                progress(gifMessage.messageId,percent);
            }
            
        } completion:completion];
    }
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

#pragma mark - 发送视频消息
- (void)sendVideoMessage:(NSData *)videoData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!videoData || videoData == (id)kCFNull) return ;
    if (![videoData isKindOfClass:[NSData class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *videoMessage = [self videoMessageWithVideoData:videoData];
        if (videoMessage) {
            @udWeakify(self);
            [self endPreSessionWithMessage:videoMessage delay:0.8f completion:^{
                @udStrongify(self);
                [self addMessageToChatMessageArray:@[videoMessage]];
            }];
        }
        return;
    }
    
    //排队消息
    if (_agentModel.code == UDAgentStatusResultQueue) {
        UdeskMessage *videoMessage = [self videoMessageWithVideoData:videoData];
        [self sendQueueMessage:videoMessage progress:progress completion:completion];
        return;
    }
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        [self showAgentStatusAlert];
        return;
    }
    
    if (![[UdeskSDKUtil internetStatus] isEqualToString:@"wifi"]) {
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [UdeskSDKAlert showWithTitle:getUDLocalizedString(@"udesk_wwan_tips") message:getUDLocalizedString(@"udesk_video_send_tips") handler:^{
                [self readySendVideoMessage:videoData progress:progress completion:completion];
            }];
        });
        return;
    }
    
    [self readySendVideoMessage:videoData progress:progress completion:completion];
}

- (void)readySendVideoMessage:(NSData *)videoData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    UdeskMessage *videoMessage = [self videoMessageWithVideoData:videoData];
    if (!videoMessage) {
        return;
    }
    [self addMessageToChatMessageArray:@[videoMessage]];
    
    [UdeskManager sendMessage:videoMessage progress:^(float percent) {
        
        if (progress) {
            progress(videoMessage.messageId,percent);
        }
        
    } completion:completion];
}

- (UdeskMessage *)videoMessageWithVideoData:(NSData *)videoData {
    
    //超过发送限制
    CGFloat size = videoData.length/1024.f/1024.f;
    if (size > 31.f) {
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [UdeskSDKAlert showBigVideoPoint];
        });
        return nil;
    }
    
    UdeskMessage *videoMessage = [[UdeskMessage alloc] initWithVideo:videoData];
    //缓存视频
    [[UdeskCacheUtil sharedManager] storeVideo:videoData videoId:videoMessage.messageId];
    
    return videoMessage;
}

#pragma mark - 发送语音消息
- (void)sendVoiceMessage:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration completion:(void (^)(UdeskMessage *message))completion {
    
    if (!voicePath || voicePath == (id)kCFNull) return ;
    if (![voicePath isKindOfClass:[NSString class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *voiceMessage = [self voiceMessageWithPath:voicePath duration:voiceDuration];
        if (voiceMessage) {
            @udWeakify(self);
            [self endPreSessionWithMessage:voiceMessage delay:0 completion:^{
                @udStrongify(self);
                [self addMessageToChatMessageArray:@[voiceMessage]];
            }];
        }
        return;
    }
    
    //排队消息
    if (_agentModel.code == UDAgentStatusResultQueue) {
        UdeskMessage *voiceMessage = [self voiceMessageWithPath:voicePath duration:voiceDuration];
        [self sendQueueMessage:voiceMessage progress:nil completion:completion];
        return;
    }
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        [self showAgentStatusAlert];
        return;
    }
    
    if (![UdeskSDKUtil isBlankString:voicePath]) {
        
        UdeskMessage *voiceMessage = [self voiceMessageWithPath:voicePath duration:voiceDuration];
        if (voiceMessage) {
            [self addMessageToChatMessageArray:@[voiceMessage]];
            [UdeskManager sendMessage:voiceMessage progress:nil completion:completion];
        }
    }
}

- (UdeskMessage *)voiceMessageWithPath:(NSString *)voicePath duration:(NSString *)duration {
    
    NSData *voiceData = [NSData dataWithContentsOfFile:voicePath];
    if (!voiceData || voiceData == (id)kCFNull) return nil;
    
    UdeskMessage *voiceMessage = [[UdeskMessage alloc] initWithVoice:voiceData duration:duration];
    [[UdeskCacheUtil sharedManager] setObject:[NSData dataWithContentsOfFile:voicePath] forKey:voiceMessage.messageId];
    
    return voiceMessage;
}

#pragma mark - 发送地理位置
- (void)sendLocationMessage:(UdeskLocationModel *)model completion:(void(^)(UdeskMessage *message))completion {
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *locationMsg = [self locationMessageWithModel:model];
        if (locationMsg) {
            @udWeakify(self);
            [self endPreSessionWithMessage:locationMsg delay:0.8f completion:^{
                @udStrongify(self);
                [self addMessageToChatMessageArray:@[locationMsg]];
            }];
        }
        return;
    }
    
    //排队消息
    if (_agentModel.code == UDAgentStatusResultQueue) {
        UdeskMessage *locationMsg = [self locationMessageWithModel:model];
        [self sendQueueMessage:locationMsg progress:nil completion:completion];
        return;
    }
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        [self showAgentStatusAlert];
        return;
    }
    
    if (!model || model == (id)kCFNull) return ;
    if (![model isKindOfClass:[UdeskLocationModel class]]) return ;
    
    UdeskMessage *locationMsg = [self locationMessageWithModel:model];
    if (locationMsg) {
        [self addMessageToChatMessageArray:@[locationMsg]];
        [UdeskManager sendMessage:locationMsg progress:nil completion:completion];
    }
}

- (UdeskMessage *)locationMessageWithModel:(UdeskLocationModel *)locationModel {
    
    UdeskMessage *locationMsg = [[UdeskMessage alloc] initWithLocation:locationModel];
    [[Udesk_YYWebImageManager sharedManager].cache setImage:locationModel.image forKey:locationMsg.messageId];
    
    return locationMsg;
}

#pragma mark - 发送商品消息
- (void)sendGoodsMessage:(UdeskGoodsModel *)model completion:(void(^)(UdeskMessage *message))completion {
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *goodsMsg = [[UdeskMessage alloc] initWithGoods:model];
        if (goodsMsg) {
            @udWeakify(self);
            [self endPreSessionWithMessage:goodsMsg delay:0.8f completion:^{
                @udStrongify(self);
                [self addMessageToChatMessageArray:@[goodsMsg]];
            }];
        }
        return;
    }
    
    //排队消息
    if (_agentModel.code == UDAgentStatusResultQueue) {
        UdeskMessage *goodsMsg = [[UdeskMessage alloc] initWithGoods:model];
        [self sendQueueMessage:goodsMsg progress:nil completion:completion];
        return;
    }
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        [self showAgentStatusAlert];
        return;
    }
    
    if (!model || model == (id)kCFNull) return ;
    if (![model isKindOfClass:[UdeskGoodsModel class]]) return ;
    
    UdeskMessage *goodsMsg = [[UdeskMessage alloc] initWithGoods:model];
    if (goodsMsg) {
        [self addMessageToChatMessageArray:@[goodsMsg]];
        [UdeskManager sendMessage:goodsMsg progress:nil completion:completion];
    }
}

//发送排队消息
- (void)sendQueueMessage:(UdeskMessage *)message progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!message || message == (id)kCFNull) return ;
    
    if (![UdeskSDKUtil isBlankString:self.queueMessageMaxTips]) {
        [UdeskSDKAlert showWithMsg:self.queueMessageMaxTips];
        return;
    }
    
    @udWeakify(self);
    [UdeskManager sendQueueMessage:message progress:^(float percent) {
     
        if (progress) {
            progress(message.messageId,percent);
        }
        
    } completion:^(UdeskMessage *message, NSString *resultMsg) {
        @udStrongify(self);
        if (completion) {
            completion(message);
        }
        if (![UdeskSDKUtil isBlankString:resultMsg]) {
            self.queueMessageMaxTips = resultMsg;
            [UdeskSDKAlert showWithMsg:resultMsg];
        }
    }];
    
    [self addMessageToChatMessageArray:@[message]];
}

//结束无消息对话过滤
- (void)endPreSessionWithMessage:(UdeskMessage *)message delay:(CGFloat)delay completion:(void(^)(void))completion {
    
    //这里延迟的原因是发送图片和视频会先离开chat页面发送时才重新进入，这里处理了那个时间差。
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [UdeskSDKAlert showWithMsg:getUDLocalizedString(@"udesk_connecting_agent")];
        [self requestAgentDataWithPreSessionMessage:message completion:^(UdeskAgent *agentModel) {
            message.messageStatus = UDMessageSendStatusSuccess;
            if (completion) {
                completion();
            }
        }];
    });
}

//添加消息到数组
- (void)addMessageToChatMessageArray:(NSArray *)messageArray {
    
    if (!messageArray || messageArray == (id)kCFNull) return ;
    if (![messageArray isKindOfClass:[NSArray class]]) return;
    
    @try {
        
        NSArray *array = [UdeskMessageUtil chatMessageWithMsgModel:messageArray agentNick:self.agentModel.nick lastMessage:[self getLastMessage]];
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.messagesArray];
        if (array) {
            [mArray addObjectsFromArray:array];
        }
        self.messagesArray = mArray;
        [self updateContent];
        
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

#pragma mark - 点击功能栏弹出相应Alert
- (void)clickInputViewShowAlertView {
    
    if (self.agentModel.code == UDAgentConversationOver) {
        //新会话
        self.isOverConversion = NO;
        [self showAgentStatusAlert];
        self.sdkSetting = nil;
        [self checkSDKSetting];
        return;
    }
    
    if ([UdeskManager isBlacklisted]) {
        //黑名单用户
        [self showBlacklisted:self.blackedMessage];
    }
    else {
        [self showAgentStatusAlert];
    }
}

//黑名单
- (void)showBlacklisted:(NSString *)message {
    
    [UdeskSDKAlert showBlacklisted:message handler:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectBlacklistedAlertViewOkButton)]) {
            [self.delegate didSelectBlacklistedAlertViewOkButton];
        }
    }];
}

//根据客服code展示alertview
- (void)showAgentStatusAlert {
    
    if (self.sdkSetting) {
        NSString *no_reply_hint = self.sdkSetting.noReplyHint;
        if(self.agentModel.code == UDAgentStatusResultQueue) {
            no_reply_hint = self.agentModel.message;
        }
        
        //开启留言
        if (self.sdkSetting.enableWebImFeedback.boolValue) {
            if (self.agentModel.code == UDAgentStatusResultOffline) {
                //表单留言文案
                if ([UdeskSDKUtil isBlankString:self.sdkSetting.leaveMessageGuide]) {
                    no_reply_hint = getUDLocalizedString(@"udesk_alert_view_leave_msg");
                }
                else {
                    no_reply_hint = self.sdkSetting.leaveMessageGuide;
                }
            }
            
            [UdeskSDKAlert showWithAgentCode:self.agentModel.code message:no_reply_hint enableFeedback:YES leaveMsgHandler:^{
                [self clickLeaveMsgAlertButtonAction];
            }];
            return;
        }
        
        //关闭留言
        if (self.agentModel.code == UDAgentStatusResultOffline) {
            if ([UdeskSDKUtil isBlankString:no_reply_hint]) {
                no_reply_hint = getUDLocalizedString(@"udesk_alert_view_no_reply_hint");
            }
        }
        
        [UdeskSDKAlert showWithAgentCode:self.agentModel.code message:no_reply_hint enableFeedback:NO leaveMsgHandler:^{
            [self clickLeaveMsgAlertButtonAction];
        }];
        return;
    }
    
    [UdeskSDKAlert showWithAgentCode:self.agentModel.code message:self.agentModel.message enableFeedback:YES leaveMsgHandler:^{
        [self clickLeaveMsgAlertButtonAction];
    }];
}

//点击留言
- (void)clickLeaveMsgAlertButtonAction {
    
    if (self.sdkSetting) {
        //表单
        if ([self.sdkSetting.leaveMessageType isEqualToString:@"form"]) {
            [self sendForm];
        }
        //直接留言
        else if ([self.sdkSetting.leaveMessageType isEqualToString:@"msg"]) {
            [self sendLeaveMsg];
        }
        
        //放弃排队
        [self quitQueue];
        return;
    }
    
    //发送表单
    [self sendForm];
    [self quitQueue];
}

//放弃排队
- (void)quitQueue {
    
    //放弃排队
    [UdeskManager quitQueueWithType:[[UdeskSDKConfig customConfig] quitQueueString]];
}

//发送表单
- (void)sendForm {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSendTicket)]) {
        [self.delegate didSelectSendTicket];
    }
}

//直接留言
- (void)sendLeaveMsg {
    
    //移除排队事件
    [self removeQueueEvent];
    
    self.agentModel.code = UDAgentStatusResultLeaveMessage;
    self.agentModel.message = getUDLocalizedString(@"udesk_leave_msg");
    //回调客服信息到vc显示
    [self callbackAgentModel:self.agentModel];
    
    if (!self.leaveMsgGuideSendFlag) {
        [self appendLeaveMessageGuide];
        self.leaveMsgGuideSendFlag = YES;
    }
    //隐藏弹窗
    [UdeskSDKAlert hide];
}

//移除排队事件
- (void)removeQueueEvent {
    
    @try {
        
        //滞空排队最大
        self.queueMessageMaxTips = nil;
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
            self.messagesArray = array;
            [self updateContent];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 更新消息内容
- (void)updateContent {
    
    //数据去重
    [self filterDuplicateMessages];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadChatTableView)]) {
        [self.delegate reloadChatTableView];
    }
}

#pragma mark - 重发失败的消息
- (void)autoResendFailedMessageWithProgress:(void(^)(NSString *messageId,float percent))progress
                                 completion:(void(^)(UdeskMessage *failedMessage))completion {
    
    if (!self.resendArray || self.resendArray == (id)kCFNull || self.resendArray.count == 0) return ;
    [UdeskMessageUtil resendFailedMessage:self.resendArray progress:progress completion:completion];
}

- (void)resendMessageWithMessage:(UdeskMessage *)resendMessage
                        progress:(void(^)(float percent))progress
                      completion:(void(^)(UdeskMessage *message))completion {
    
    if (self.preSessionId) {
        [self endPreSessionWithMessage:resendMessage delay:0.8f completion:^{
            if (completion) {
                completion(resendMessage);
            }
        }];
        return;
    }
    
    if (self.agentModel.code == UDAgentStatusResultQueue) {
        [UdeskManager sendQueueMessage:resendMessage progress:progress completion:^(UdeskMessage *message,NSString *resultMsg) {
            
            if (![UdeskSDKUtil isBlankString:resultMsg]) {
                [UdeskSDKAlert showWithMsg:resultMsg];
            }
            
            if (completion) {
                completion(message);
            }
        }];
    }
    else if (self.agentModel.code != UDAgentStatusResultOnline &&
             self.agentModel.code != UDAgentStatusResultLeaveMessage) {
        [self showAgentStatusAlert];
        if (completion) {
            completion(resendMessage);
        }
    }
    else {
        
        //重发
        [UdeskManager sendMessage:resendMessage progress:progress completion:completion];
    }
}

//添加失败的消息
- (void)addResendMessageToArray:(UdeskMessage *)message {
    if (!message || message == (id)kCFNull) return ;
    if (![message isKindOfClass:[UdeskMessage class]]) return ;
    
    [self.resendArray addObject:message];
}
//删除失败的消息
- (void)removeResendMessageInArray:(UdeskMessage *)message {
    if (!message || message == (id)kCFNull) return ;
    if (![message isKindOfClass:[UdeskMessage class]]) return ;
    
    if ([self.resendArray containsObject:message]) {
        [self.resendArray removeObject:message];
    }
}

//去重
- (void)filterDuplicateMessages {
    
    @try {
        
        NSMutableArray *empty = [NSMutableArray array];
        for (UdeskBaseMessage *message in self.messagesArray) {
            if (message && ![self checkMessage:message existInList:empty]) {
                [empty addObject:message];
            }
        }
        
        self.messagesArray = [empty copy];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (BOOL)checkMessage:(UdeskBaseMessage *)msg existInList:(NSArray *)array {
    for (UdeskBaseMessage *tmp in array) {
        if ([tmp.message.messageId isEqualToString:msg.message.messageId]) {
            return YES;
        }
    }
    return  NO;
}

#pragma mark - lazy
- (NSMutableArray *)resendArray {
    
    if (!_resendArray) {
        _resendArray = [NSMutableArray array];
    }
    return _resendArray;
}

- (NSMutableArray *)preSessionMessages {
    
    if (!_preSessionMessages) {
        _preSessionMessages = [NSMutableArray array];
    }
    return _preSessionMessages;
}

- (UdeskQueueMessage *)queueMessage {
    if (!_queueMessage) {
        _queueMessage = [[UdeskQueueMessage alloc] initWithMessage:[[UdeskMessage alloc] initWithQueue:self.agentModel.message showLeaveMsgBtn:self.sdkSetting.enableWebImFeedback.boolValue] displayTimestamp:YES];
    }
    return _queueMessage;
}

//网络状态检测
- (void)udIMReachabilityChanged:(NSNotification *)note {
    
    NSDictionary *userInfo = note.userInfo;
    NSNumber *status = userInfo[kUdeskReachabilityNotificationStatusItem];
    if (!status || status == (id)kCFNull) return ;
    
    @udWeakify(self)
    switch (status.integerValue) {
        case UDReachableViaWiFi:
        case UDReachableViaWWAN:{
            
            @udStrongify(self);
            if (self.netWorkChange) {
                self.netWorkChange = NO;
                self.isOverConversion = NO;
                //重新请求数据
                self.preSessionId = nil;
                self.sdkSetting = nil;
                [self checkSDKSetting];
            }
            break;
        }
            
        case UDNotReachable:{
            
            @udStrongify(self);
            self.netWorkChange = YES;
            if (!self.agentModel) {
                self.agentModel = [[UdeskAgent alloc] init];
            }
            self.agentModel.message = getUDLocalizedString(@"udesk_network_interrupt");
            self.agentModel.code = UDAgentStatusResultNotNetWork;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self callbackAgentModel:self.agentModel];
            });
        }
            
        default:
            break;
    }
}

#pragma mark - 视频
//进入后台
- (void)udeskCallApplicationEnterBackground {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    [[UdeskCallSessionManager sharedManager] disConnect];
#endif
}

//进入前台
- (void)udeskCallApplicationBecomeActive {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    [[UdeskCallSessionManager sharedManager] connect];
#endif
}

//初始化视频manager
- (void)setupUdeskVideoCallWithCustomer:(UdeskCustomer *)customer
                                  agent:(UdeskAgent *)agent {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    @try {
        
        //没有开启视频功能
        if (!self.sdkSetting.vCall.boolValue || !self.sdkSetting.sdkVCall.boolValue) {
            [[UdeskCallSessionManager sharedManager] disConnect];
            return;
        }
        
        self.currentUserId = customer.customerJID;
        UdeskCallUserProfile *userProfile = [[UdeskCallUserProfile alloc] initWithAppId:self.sdkSetting.vcAppId
                                                                              subdomain:[UdeskManager domain]
                                                                           bizSessionId:agent.imSubSessionId];
        userProfile.agoraAppId = self.sdkSetting.agoraAppId;
        userProfile.serverURL = self.sdkSetting.serverURL;
        userProfile.vCallTokenURL = self.sdkSetting.vCallTokenURL;
        userProfile.userId = customer.customerJID;
        userProfile.toUserId = agent.jid;
        userProfile.resId = customer.customerJID;
        userProfile.toResId = agent.jid;
        
        [[UdeskCallSessionManager sharedManager] setUserProfile:userProfile];
        [[UdeskCallSessionManager sharedManager] removeDelegate:self];
        [[UdeskCallSessionManager sharedManager] addDelegate:self];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
#endif
}

#pragma mark - @protocol UdeskSocketDelegate
#if __has_include(<UdeskCall/UdeskCall.h>)
//未登录
- (void)remoteUserDidNotLogedIn:(NSString *)userId {
    
    [self setNotAnsweredAndDeclineVideoCallMessage:userId content:getUDLocalizedString(@"udesk_video_call_agent_not_logged_in")];
}

//挂断
- (void)remoteUserDidHangup:(NSString *)userId {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    [self setVideoCallMessage:userId content:[NSString stringWithFormat:@"%@ %@",getUDLocalizedString(@"udesk_video_call_duration"),[UdeskAgoraRtcEngineManager shared].durationLabel.text]];
    //停止播放
    [self stopPlayVideoCallRing];
#endif
}
//邀请
- (void)remoteUserDidInvite:(NSString *)userId {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveInviteWithAgentModel:)]) {
        [self.delegate didReceiveInviteWithAgentModel:self.agentModel];
    }
    
    //开始播放
    [self startPlayRing:getUDBundlePath(@"udeskCall.mp3")];
#endif
}

//拒绝
- (void)remoteUserDidDecline:(NSString *)userId {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    NSString *content = getUDLocalizedString(@"udesk_video_call_agent_decline");
    if ([userId isEqualToString:self.currentUserId]) {
        content = getUDLocalizedString(@"udesk_video_call_customer_decline");
    }
    
    [self setNotAnsweredAndDeclineVideoCallMessage:userId content:content];
    //停止播放
    [self stopPlayVideoCallRing];
#endif
}

//取消
- (void)remoteUserDidCancel:(NSString *)userId {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    NSString *content = getUDLocalizedString(@"udesk_video_call_agent_cancel");
    if (![userId isEqualToString:self.currentUserId]) {
        content = getUDLocalizedString(@"udesk_video_call_customer_cancel");
    }
    [self setVideoCallMessage:userId content:content];
    
    //停止播放
    [self stopPlayVideoCallRing];
#endif
}

//忙线
- (void)remoteUserDidLineBusy:(NSString *)userId {
    
    [self setNotAnsweredAndDeclineVideoCallMessage:userId content:getUDLocalizedString(@"udesk_video_call_agent_busy")];
    
    //停止播放
    [self stopPlayVideoCallRing];
}

//无应答
- (void)remoteUserDidNotAnswered:(NSString *)userId {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    NSString *content = getUDLocalizedString(@"udesk_video_call_agent_not_answered");
    if ([userId isEqualToString:self.currentUserId]) {
        content = getUDLocalizedString(@"udesk_video_call_customer_cancel");
    }
    
    [self setNotAnsweredAndDeclineVideoCallMessage:userId content:content];
    //停止播放
    [self stopPlayVideoCallRing];
#endif
}

//加入
- (void)userJoinChannel:(NSString *)userId channelToken:(NSString *)channelToken channelId:(NSString *)channelId agoraUid:(NSUInteger)agoraUid {
    
    //停止播放
    [self stopPlayVideoCallRing];
}

- (void)setNotAnsweredAndDeclineVideoCallMessage:(NSString *)userId content:(NSString *)content {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    UdeskMessage *message = [[UdeskMessage alloc] initWithVideoCall:content];
    message.agentJid = self.agentModel.jid;
    message.imSubSessionId = [NSString stringWithFormat:@"%ld",self.agentModel.imSubSessionId];
    if ([userId isEqualToString:self.currentUserId]) {
        message.messageFrom = UDMessageTypeReceiving;
    }
    
    [self addMessageToChatMessageArray:@[message]];
    [UdeskManager sendMessage:message progress:nil completion:nil];
#endif
}

//设置视频消息
- (void)setVideoCallMessage:(NSString *)userId content:(NSString *)content {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    UdeskMessage *message = [[UdeskMessage alloc] initWithVideoCall:content];
    message.agentJid = self.agentModel.jid;
    message.imSubSessionId = [NSString stringWithFormat:@"%ld",self.agentModel.imSubSessionId];
    if (![userId isEqualToString:self.currentUserId]) {
        message.messageFrom = UDMessageTypeReceiving;
    }
    
    [self addMessageToChatMessageArray:@[message]];
    [UdeskManager sendMessage:message progress:nil completion:nil];
#endif
}

- (void)startPlayRing:(NSString *)ringPath {
#if __has_include(<UdeskCall/UdeskCall.h>)
    if (ringPath) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况按静音或者锁屏键会静音
        [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
        [audioSession setActive:YES error:nil];
        
        if (self.audioPlayer) {
            [self stopPlayVideoCallRing];
        }
        
        NSURL *url = [NSURL URLWithString:ringPath];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (!error) {
            self.audioPlayer.numberOfLoops = -1;
            self.audioPlayer.volume = 1.0;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    }
#endif
}

- (void)stopPlayVideoCallRing {
#if __has_include(<UdeskCall/UdeskCall.h>)
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        //设置铃声停止后恢复其他app的声音
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    }
#endif
}
#endif

- (void)dealloc
{
    NSLog(@"UdeskSDK：%@释放了",[self class]);
#if __has_include(<UdeskCall/UdeskCall.h>)
    [[UdeskCallSessionManager sharedManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUdeskReachabilityChangedNotification object:nil];
}

@end
