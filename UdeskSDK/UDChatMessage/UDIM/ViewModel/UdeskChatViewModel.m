//
//  UdeskChatViewModel.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/19.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskChatViewModel.h"
#import "UdeskTools.h"
#import "UdeskFoundationMacro.h"
#import "NSArray+UdeskSDK.h"
#import "UdeskAgentHttpData.h"
#import "UdeskReachability.h"
#import "UdeskManager.h"
#import "UdeskMessage+UdeskChatMessage.h"
#import "UdeskChatAlertController.h"
#import "UdeskProductMessage.h"
#import "UdeskSDKConfig.h"
#import "UdeskAgentSurvey.h"
#import "UdeskUtils.h"
#import "UdeskStructMessage.h"
#import "UdeskEventMessage.h"
#import "UdeskDateFormatter.h"
#import "UdeskTextMessage.h"
#import "UdeskImageMessage.h"
#import "UdeskVideoMessage.h"
#import "UdeskVoiceMessage.h"
#import "Udesk_YYWebImage.h"
#import "UdeskCaheHelper.h"
#import "UdeskAlertController.h"
#import "UdeskResendManager.h"

@interface UdeskChatViewModel()<UDManagerDelegate,UdeskChatAlertDelegate>

/** 消息 */
@property (nonatomic, strong,readwrite) NSMutableArray           *messageArray;
/** 失败的消息 */
@property (nonatomic, strong,readwrite) NSMutableArray           *resendArray;
/** sdk后台配置 */
@property (nonatomic, strong          ) UdeskSetting             *sdkSetting;
/** 客服Model */
@property (nonatomic, strong          ) UdeskAgent               *agentModel;
/** 聊天弹窗 */
@property (nonatomic, strong          ) UdeskChatAlertController *chatAlert;
/** 网络状态检测 */
@property (nonatomic                  ) UdeskReachability        *reachability;
/** 网络切换 */
@property (nonatomic, assign          ) BOOL                     netWorkChange;
/** 黑名单提示语 */
@property (nonatomic, copy            ) NSString                 *blackedMessage;
/** 是否显示客户留言事件 */
@property (nonatomic, assign          ) BOOL                     leaveMsgFlag;
/** 最后一条离线消息时间 */
@property (nonatomic, copy            ) NSString                 *lastLeaveMsgDate;

@end

@implementation UdeskChatViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.messageArray = [NSMutableArray array];
        //聊天提示框
        self.chatAlert = [[UdeskChatAlertController alloc] init];
        self.chatAlert.delegate = self;
        //第一次发送默认展示客户留言事件
        self.leaveMsgFlag = YES;
        //UdeskSDK代理
        [UdeskManager receiveUdeskDelegate:self];
        //获取db消息
        [self requestDataBaseMessageContent];
        //网络监测
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kUdeskReachabilityChangedNotification object:nil];
        self.reachability  = [UdeskReachability reachabilityWithHostName:@"www.baidu.com"];
        [self.reachability startNotifier];
    }
    return self;
}

- (void)initCustomerWithSDKSetting:(UdeskSetting *)setting {
    
    if (!setting) {
        [UdeskManager getServerSDKSetting:^(UdeskSetting *setting) {
            
            //根据后台配置创建用户
            [self createCustomerWithSDKSetting:setting];
            
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
            //根据后台配置创建用户
            [self createCustomerWithSDKSetting:setting];
        }];
        return;
    }
    
    //根据后台配置创建用户
    [self createCustomerWithSDKSetting:setting];
}

//根据是否设置按后台配置
- (void)createCustomerWithSDKSetting:(UdeskSetting *)setting {
    
    self.sdkSetting = setting;
    //在工作时间
    if (setting.isWorktime.boolValue) {
        [self createServerCustomer];
    }
    //不在工作时间
    else {
        UdeskAgent *agentModel = [[UdeskAgent alloc] init];
        agentModel.code = UDAgentStatusResultOffline;
        //回调客服信息到vc显示
        [self callbackAgentModel:agentModel];
        //显示不在工作时间alert
        [self showAlertNotWorkTime];
    }
}

- (void)showAlertNotWorkTime {
    
    @try {
        
        if (self.sdkSetting) {
            
            if (self.sdkSetting.enableWebImFeedback.boolValue) {
                NSString *no_reply_hint = getUDLocalizedString(@"udesk_alert_view_leave_msg");
                [self.chatAlert showAgentNotOnlineAlertWithMessage:no_reply_hint enableWebImFeedback:YES];
            }
            else {
                
                NSString *no_reply_hint = self.sdkSetting.noReplyHint;
                if ([UdeskTools isBlankString:no_reply_hint]) {
                    no_reply_hint = getUDLocalizedString(@"udesk_alert_view_no_reply_hint");
                }
                [self.chatAlert showAgentNotOnlineAlertWithMessage:no_reply_hint enableWebImFeedback:NO];
            }
        }
        else {
            [self.chatAlert showAgentNotOnlineAlert];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//创建用户
- (void)createServerCustomer {
    
    @udWeakify(self);
    //创建用户(为了保证sdk正常使用请不要删除使用UdeskManager的方法)
    [UdeskManager createServerCustomerCompletion:^(BOOL success, NSError *error) {
        
        @udStrongify(self);
        //获取留言
        [self fetchNewAgentTickeReply];
        
        if (success) {
            //请求客服数据(为了保证sdk正常使用请不要删除使用UdeskManager的方法)
            [self requestAgentData];
        }
        else {
            
            //客户在黑名单
            if ([UdeskManager isBlacklisted]) {
                [self customerBlacklisted:error.userInfo[@"message"]];
                return ;
            }
            NSLog(@"Udesk SDK初始化失败，请查看控制台LOG");
        }
    }];
}

//客户在黑名单
- (void)customerBlacklisted:(NSString *)message {
    
    _blackedMessage = message;
    //退出
    [UdeskManager setupCustomerOffline];
    
    UdeskAgent *agentModel = [[UdeskAgent alloc] init];
    agentModel.message = [UdeskTools isBlankString:message]?getUDLocalizedString(@"udesk_im_title_blocked_list"):message;
    agentModel.code = UDAgentStatusResultUnKnown;
    
    [self callbackAgentModel:agentModel];
    //显示客户黑名单提示
    [self.chatAlert showIsBlacklistedAlert:message];
}

//网络状态检测
- (void)reachabilityChanged:(NSNotification *)note
{
    
    UdeskReachability *curReach = [note object];
    UDNetworkStatus internetStatus = [curReach currentReachabilityStatus];
    
    @udWeakify(self)
    switch (internetStatus) {
        case UDReachableViaWiFi:
        case UDReachableViaWWAN:{
            
            @udStrongify(self);
            if (self.netWorkChange) {
                self.netWorkChange = NO;
                //请求客服数据
                [self requestAgentData];
            }
            break;
        }
            
        case UDNotReachable:{
            
            @udStrongify(self);
            self.netWorkChange = YES;
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

#pragma mark - 根据是否有客服id和客服组id请求客服数据
- (void)requestAgentData {
    
    NSString *agentId = [UdeskSDKConfig sharedConfig].scheduledAgentId;
    NSString *groupId = [UdeskSDKConfig sharedConfig].scheduledGroupId;
    
    @udWeakify(self);
    //获取客服信息
    if (![UdeskTools isBlankString:agentId]) {
        //获取指定客服ID的客服信息
        [[UdeskAgentHttpData sharedAgentHttpData] scheduledAgentId:agentId completion:^(UdeskAgent *agentModel, NSError *error) {
            @udStrongify(self);
            [self distributionAgent:agentModel];
        }];
    }
    else if (![UdeskTools isBlankString:groupId]) {
        //获取指定客服组ID的客服组信息
        [[UdeskAgentHttpData sharedAgentHttpData] scheduledGroupId:groupId completion:^(UdeskAgent *agentModel, NSError *error) {
            @udStrongify(self);
            [self distributionAgent:agentModel];
        }];
    }
    else {
        
        //根据管理员后台配置选择客服
        [[UdeskAgentHttpData sharedAgentHttpData] requestRandomAgent:^(UdeskAgent *agentModel, NSError *error) {
            @udStrongify(self);
            [self distributionAgent:agentModel];
        }];
    }
    
}

//获取分配客服
- (void)distributionAgent:(UdeskAgent *)agentModel {
    
    //回调客服信息到vc显示
    [self callbackAgentModel:agentModel];
    
    if (agentModel.code != UDAgentStatusResultOnline) {
        
        if (self.isNotShowAlert) {
            return;
        }
        [self showAlertViewWithAgent];
        return;
    }
    //只有客服在线才发送消息
    if (agentModel.code == UDAgentStatusResultOnline) {
        
        if ([UdeskSDKConfig sharedConfig].productDictionary) {
            UdeskMessage *productMessage = [[UdeskMessage alloc] initWithProductMessage:[UdeskSDKConfig sharedConfig].productDictionary];
            [UdeskManager sendMessage:productMessage completion:nil];
        }
        
        //隐藏弹窗
        [self.chatAlert hideAlert];
    }
}

//回调客服信息到vc显示
- (void)callbackAgentModel:(UdeskAgent *)agentModel {
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didFetchAgentModel:)]) {
            [self.delegate didFetchAgentModel:agentModel];
        }
    }
    self.agentModel = agentModel;
}
#pragma mark - UdeskChatAlertDelegate
//点击了发送表单
- (void)didSelectSendTicket {
    
    @try {
        
        if (self.sdkSetting) {
            //直接留言
            if ([self.sdkSetting.leaveMessageType isEqualToString:@"msg"]) {
                
                UdeskAgent *agentModel = [[UdeskAgent alloc] init];
                agentModel.code = UDAgentStatusResultLeaveMessage;
                agentModel.message = getUDLocalizedString(@"udesk_leave_msg");
                //回调客服信息到vc显示
                [self callbackAgentModel:agentModel];
                //更新输入框
                if (self.updateInputBarBlock) {
                    self.updateInputBarBlock();
                }
            }
            //发送表单
            else if ([self.sdkSetting.leaveMessageType isEqualToString:@"form"]) {
                [self sendForm];
            }
            
            //放弃排队
            [self quitQueue];
            return;
        }
        
        //发送表单
        [self sendForm];
        [self quitQueue];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//放弃排队
- (void)quitQueue {
    
    //取消所有网络请求
    [UdeskManager cancelAllOperations];
    //强制放弃排队
    [UdeskManager quitQueueWithType:UdeskForceQuit];
}

//发送表单
- (void)sendForm {
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didSelectSendTicket)]) {
            [self.delegate didSelectSendTicket];
        }
    }
}

//点击了黑名单确定
- (void)didSelectBlacklistedAlertViewOkButton {
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didSelectBlacklistedAlertViewOkButton)]) {
            [self.delegate didSelectBlacklistedAlertViewOkButton];
        }
    }
}

- (void)fetchNewAgentTickeReply {
    
    //获取留言
    @udWeakify(self);
    [self fetchAgentTicketReply:nil
                     completion:^(NSArray *dataSource) {
                         
                         dispatch_async(dispatch_get_global_queue(0, 0), ^{
                             
                             @try {
                                 
                                 @udStrongify(self);
                                 if (dataSource.count) {
                                     NSMutableArray *array = [NSMutableArray arrayWithArray:self.messageArray];
                                     [array addObjectsFromArray:[self leaveMessageWithUdeskMessages:dataSource]];
                                     self.messageArray = array;
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

- (void)fetchOldAgentTickeReply:(void(^)(NSInteger count))completion {
    
    //获取留言
    @udWeakify(self);
    [self fetchAgentTicketReply:self.lastLeaveMsgDate
                     completion:^(NSArray *dataSource) {
                         
                         dispatch_async(dispatch_get_global_queue(0, 0), ^{
                             
                             @try {
                                 
                                 if (dataSource.count) {
                                     
                                     NSArray *moreMessageArray = [self leaveMessageWithUdeskMessages:dataSource];
                                     NSRange range = NSMakeRange(0, [moreMessageArray count]);
                                     NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                                     
                                     @udStrongify(self);
                                     if (moreMessageArray.count) {
                                         [self.messageArray insertObjects:moreMessageArray atIndexes:indexSet];
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

- (void)fetchAgentTicketReply:(NSString *)date
                   completion:(void(^)(NSArray *dataSource))completion {
    
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

#pragma mark - 获取DB数据
- (void)requestDataBaseMessageContent {
    
    [UdeskManager getHistoryMessagesFromDatabaseWithMessageDate:[NSDate date] messagesNumber:20 result:^(NSArray *messagesArray) {
        
        if (messagesArray.count==20) {
            self.isShowRefresh = YES;
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            @try {
                
                if (messagesArray.count) {
                    self.messageArray = [NSMutableArray arrayWithArray:[self chatMessageLayoutWithModel:messagesArray]];
                }
                
                //咨询对象
                if ([UdeskSDKConfig sharedConfig].productDictionary) {
                    
                    UdeskMessage *productMsg = [[UdeskMessage alloc] initWithProductMessage:[UdeskSDKConfig sharedConfig].productDictionary];
                    UdeskProductMessage *productMessage = [[UdeskProductMessage alloc] initWithMessage:productMsg displayTimestamp:YES];
                    if (productMessage) {
                        [self.messageArray addObject:productMessage];
                    }
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

#pragma mark - 加载更多DB消息
- (void)pullMoreDateBaseMessage {
    
    @udWeakify(self);
    [self fetchOldAgentTickeReply:^(NSInteger count) {
        
        if (count == 0) {
            
            @udStrongify(self);
            UdeskBaseMessage *lastMessage = self.messageArray.firstObject;
            //根据最后列表最后一条消息的时间获取历史记录
            [UdeskManager getHistoryMessagesFromDatabaseWithMessageDate:lastMessage.message.timestamp messagesNumber:20 result:^(NSArray *messagesArray) {
                
                if (messagesArray.count) {
                    if (messagesArray.count>19) {
                        self.isShowRefresh = YES;
                    }
                    else {
                        self.isShowRefresh = NO;
                    }
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        
                        @try {
                            
                            if (messagesArray.count) {
                                
                                NSRange range = NSMakeRange(0, [messagesArray count]);
                                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                                
                                NSArray *moreMessageArray = [self chatMessageLayoutWithModel:messagesArray];
                                if (moreMessageArray.count) {
                                    [self.messageArray insertObjects:moreMessageArray atIndexes:indexSet];
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

//把UdeskMessage转换成UdeskChatMessage
- (NSArray *)leaveMessageWithUdeskMessages:(NSArray *)messagesArray {
    
    @try {
        
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        NSArray *array = [self.messageArray valueForKey:@"messageId"];
        
        for (UdeskMessage *message in messagesArray) {
            
            if (![array containsObject:message.messageId]) {
                
                if (message.messageType == UDMessageContentTypeText) {
                    
                    UdeskTextMessage *textMessage = [[UdeskTextMessage alloc] initWithMessage:message displayTimestamp:NO];
                    if (textMessage) {
                        [messages addObject:textMessage];
                    }
                }
                else if (message.messageType == UDMessageContentTypeLeave) {
                    
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

//消息model转layout
- (NSArray *)chatMessageLayoutWithModel:(NSArray *)array {
    
    NSMutableArray *msgLayout = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(UdeskMessage *message, NSUInteger idx, BOOL * _Nonnull stop) {
        
        @try {
            
            //检查是否需要显示时间（第一条信息和超过3分钟间隔的显示时间）
            UdeskMessage *previousMessage;
            if (idx>0) {
                previousMessage = [array objectAtIndex:idx-1];
            }
            BOOL isDisplayTimestamp = [self checkWhetherMessageTimeDisplayed:previousMessage laterMessage:message atIndex:idx];
            
            switch (message.messageType) {
                case UDMessageContentTypeRich:
                case UDMessageContentTypeText:{
                    
                    UdeskTextMessage *textMessage = [[UdeskTextMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:textMessage];
                    break;
                }
                case UDMessageContentTypeImage:{
                    
                    UdeskImageMessage *imageMessage = [[UdeskImageMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:imageMessage];
                    break;
                }
                case UDMessageContentTypeVoice: {
                    
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
                case UDMessageContentTypeLeave:{
                    
                    UdeskEventMessage *eventMessage = [[UdeskEventMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:eventMessage];
                    break;
                }
                case UDMessageContentTypeRollback: {
                    
                    NSString *agentNick = message.content;
                    if ([UdeskTools isBlankString:agentNick]) {
                        agentNick = self.agentModel.nick;
                    }
                    NSString *rollbackText = [NSString stringWithFormat:@"%@%@%@",getUDLocalizedString(@"udesk_agent"),agentNick,getUDLocalizedString(@"udesk_rollback")];
                    message.content = rollbackText;
                    UdeskEventMessage *eventMessage = [[UdeskEventMessage alloc] initWithMessage:message displayTimestamp:isDisplayTimestamp];
                    [msgLayout addObject:eventMessage];
                }
                    break;
                    
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

//检查是否需要显示时间（间隔超过3分钟就显示时间）
- (BOOL)checkWhetherMessageTimeDisplayed:(UdeskMessage *)previousMessage laterMessage:(UdeskMessage *)laterMessage atIndex:(NSUInteger)index {
    
    @try {
        
        if (index == 0) return YES;
        
        if (!previousMessage || previousMessage == (id)kCFNull) return YES;
        if (!laterMessage || laterMessage == (id)kCFNull) return YES;
        
        if (laterMessage.messageType == UDMessageContentTypeLeave ||
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

#pragma mark - UDManagerDelegate
- (void)didReceiveMessages:(UdeskMessage *)message {
    
    @try {
        
        if (!message || message == (id)kCFNull) return ;
        if ([UdeskTools isBlankString:message.content]) return;
        
        NSArray *array = [self chatMessageLayoutWithModel:@[message]];
        if (array) {
            [self.messageArray addObjectsFromArray:array];
        }
        
        [self updateContent];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//接受到转接
- (void)didReceiveRedirect:(UdeskAgent *)agent {
    
    [self callbackAgentModel:agent];
}

//接收客服状态
- (void)didReceivePresence:(NSDictionary *)presence {
    
    @try {
        
        NSString *statusType = [NSString stringWithFormat:@"%@",[presence objectForKey:@"type"]];
        UDAgentStatusType agentCode = UDAgentStatusResultOffline;
        NSString *agentMessage = @"unavailable";
        if([statusType isEqualToString:@"over"]) {
            
            agentCode = UDAgentConversationOver;
            agentMessage = getUDLocalizedString(@"udesk_chat_end");
        }
        else if ([statusType isEqualToString:@"available"]) {
            
            agentCode = UDAgentStatusResultOnline;
            agentMessage = [NSString stringWithFormat:@"%@ %@ %@",getUDLocalizedString(@"udesk_agent"),self.agentModel.nick,getUDLocalizedString(@"udesk_online")];
            
        }
        else if ([statusType isEqualToString:@"unavailable"]) {
            
            agentCode = UDAgentStatusResultOffline;
            agentMessage = [NSString stringWithFormat:@"%@ %@ %@",getUDLocalizedString(@"udesk_agent"),self.agentModel.nick,getUDLocalizedString(@"udesk_offline")];
        }
        
        
        //与上次不同的code才抛给vc
        if (self.agentModel.code != agentCode) {
            self.agentModel.code = agentCode;
            self.agentModel.message = agentMessage;
            
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(didReceiveAgentPresence:)]) {
                    [self.delegate didReceiveAgentPresence:self.agentModel];
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//接收客服发送的满意度调查
- (void)didReceiveSurveyWithAgentId:(NSString *)agentId {
    
    if ([UdeskTools isBlankString:agentId]) {
        return;
    }
    @udWeakify(self);
    [[UdeskAgentSurvey sharedManager] showAgentSurveyAlertViewWithAgentId:agentId isShowErrorAlert:YES completion:^(BOOL result, NSError *error){
        
        @udStrongify(self);
        if (result) {
            //评价提交成功Alert
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(didSurveyCompletion:)]) {
                    [self.delegate didSurveyCompletion:getUDLocalizedString(@"udesk_top_view_thanks_evaluation")];
                }
            }
        }
    }];
}

//收到客服工单回复
- (void)didReceiveTicketReply {
    
    [self fetchNewAgentTickeReply];
}

- (void)didReceiveRollback:(NSString *)messageId agentNick:(NSString *)agentNick {
    
    @try {
        
        for (UdeskBaseMessage *baseMessage in self.messageArray) {
            
            if ([baseMessage.messageId isEqualToString:messageId]) {
                
                [self.messageArray removeObject:baseMessage];
                
                if ([UdeskTools isBlankString:agentNick]) {
                    agentNick = self.agentModel.nick;
                }
                UdeskMessage *message = [[UdeskMessage alloc] initRollbackChatMessage:agentNick];
                [self addMessageToChatMessageArray:@[message]];
                
                break;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 发送文字消息
- (void)sendTextMessage:(NSString *)text
             completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion {
    
    if (_agentModel.code != UDAgentStatusResultOnline &&
        _agentModel.code != UDAgentStatusResultLeaveMessage) {
        
        [self showAlertViewWithAgent];
        return;
    }
    
    if ([UdeskTools isBlankString:text]) {
        [self.chatAlert showAlertWithMessage:getUDLocalizedString(@"udesk_no_send_empty")];
        return;
    }
    
    //客户发送离线留言
    if (_agentModel.code == UDAgentStatusResultLeaveMessage) {
        
        //消息内容
        UdeskMessage *message = [[UdeskMessage alloc] initTextChatMessage:text];
        [UdeskManager sendLeaveMessage:message isShowEvent:_leaveMsgFlag completion:^(NSError *error, BOOL sendStatus) {
            if (completion) {
                completion(message,sendStatus);
            }
        }];
        
        //显示客户留言事件
        if (_leaveMsgFlag) {
            
            UdeskMessage *leaveMessage = [[UdeskMessage alloc] initLeaveChatMessage:getUDLocalizedString(@"udesk_customer_leave_msg")];
            if (leaveMessage) {
                [self addMessageToChatMessageArray:@[leaveMessage]];
            }
            _leaveMsgFlag = NO;
        }
        
        //消息要在事件之后
        if (message) {
            UdeskTextMessage *textMessage = [[UdeskTextMessage alloc] initWithMessage:message displayTimestamp:NO];
            if (textMessage) {
                [self.messageArray addObject:textMessage];
            }
            [self updateContent];
        }
    }
    else {
        
        UdeskMessage *textMessage = [[UdeskMessage alloc] initTextChatMessage:text];
        if (textMessage) {
            [self addMessageToChatMessageArray:@[textMessage]];
            [UdeskManager sendMessage:textMessage completion:completion];
        }
    }
    
    //通知刷新UI
    [self updateContent];
}

#pragma mark - 发送图片消息
- (void)sendImageMessage:(UIImage *)image
              completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion {
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        [self showAlertViewWithAgent];
        return;
    }
    
    if (image) {
        
        UdeskMessage *imageMessage = [[UdeskMessage alloc] initImageChatMessage:image];
        if (imageMessage) {
            //缓存图片
            [[Udesk_YYWebImageManager sharedManager].cache setImage:image forKey:imageMessage.messageId];
            [self addMessageToChatMessageArray:@[imageMessage]];
            [UdeskManager sendMessage:imageMessage completion:completion];
        }
    }
}

- (void)sendGIFImageMessage:(NSData *)gifData
                 completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion {
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        [self showAlertViewWithAgent];
        return;
    }
    
    if (gifData) {
        
        Udesk_YYImage *image = [[Udesk_YYImage alloc] initWithData:gifData];
        
        UdeskMessage *gifMessage = [[UdeskMessage alloc] initGIFImageChatMessage:gifData];
        if (gifMessage) {
            gifMessage.image = image;
            CGSize size = [UdeskTools neededSizeForPhoto:image];
            gifMessage.width = size.width;
            gifMessage.height = size.height;
            
            //缓存图片
            [[Udesk_YYWebImageManager sharedManager].cache setImage:image forKey:gifMessage.messageId];
            
            [self addMessageToChatMessageArray:@[gifMessage]];
            [UdeskManager sendMessage:gifMessage completion:completion];
        }
    }
}

/**
 *  发送视频消息
 *
 *  @param videoData    视频信息
 *  @param completion 发送状态&发送消息体
 */
- (void)sendVideoMessage:(NSData *)videoData
               videoName:(NSString *)videoName
                progress:(void(^)(NSString *messageId,float percent))progress
              completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion {
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        [self showAlertViewWithAgent];
        return;
    }
    
    //超过发送限制
    CGFloat size = videoData.length/1024.f/1024.f;
    if (size > 31.f) {
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [self.chatAlert showBigVideoPoint];
        });
        return;
    }
    
    if (![[UdeskTools internetStatus] isEqualToString:@"wifi"]) {
        
        UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:getUDLocalizedString(@"udesk_wwan_tips") message:getUDLocalizedString(@"udesk_video_send_tips") preferredStyle:UDAlertControllerStyleAlert];
        [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_cancel") style:UDAlertActionStyleDefault handler:nil]];
        [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
            
            [self readySendVideoMessage:videoData videoName:videoName progress:progress completion:completion];
        }]];
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [[UdeskTools currentViewController] presentViewController:alert animated:YES completion:nil];
        });
        
        return;
    }
    
    [self readySendVideoMessage:videoData videoName:videoName progress:progress completion:completion];
}

- (void)readySendVideoMessage:(NSData *)videoData
                    videoName:(NSString *)videoName
                     progress:(void(^)(NSString *messageId,float percent))progress
                   completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion {
    
    if (videoData) {
        
        UdeskMessage *videoMessage = [[UdeskMessage alloc] initVideoChatMessage:videoData videoName:videoName];
        
        //缓存视频
        [[UdeskCaheHelper sharedManager] storeVideo:videoData videoId:videoMessage.messageId];
        [self addMessageToChatMessageArray:@[videoMessage]];
        
        [UdeskManager sendVideoMessage:videoMessage videoName:videoName progress:^(NSString *key, float percent) {
            
            if (progress) {
                progress(videoMessage.messageId,percent);
            }
            
        } cancellationSignal:^BOOL{
            return NO;
        } completion:completion];
    }
}

#pragma mark - 发送语音消息
- (void)sendAudioMessage:(NSString *)voicePath
           audioDuration:(NSString *)audioDuration
              completion:(void (^)(UdeskMessage *message, BOOL sendStatus))completion {
    
    if (_agentModel.code != UDAgentStatusResultOnline) {
        
        [self showAlertViewWithAgent];
        return;
    }
    
    if (![UdeskTools isBlankString:voicePath]) {
        
        UdeskMessage *voiceMessage = [[UdeskMessage alloc] initVoiceChatMessage:[NSData dataWithContentsOfFile:voicePath] duration:audioDuration];
        [[UdeskCaheHelper sharedManager] setObject:[NSData dataWithContentsOfFile:voicePath] forKey:voiceMessage.messageId];
        [self addMessageToChatMessageArray:@[voiceMessage]];
        [UdeskManager sendMessage:voiceMessage completion:completion];
    }
}

//添加消息到数组
- (void)addMessageToChatMessageArray:(NSArray *)messageArray {
    
    @try {
        
        NSArray *array = [self chatMessageLayoutWithModel:messageArray];
        [self.messageArray addObjectsFromArray:array];
        [self updateContent];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 点击功能栏弹出相应Alert
- (void)clickInputViewShowAlertView {
    
    if (self.agentModel.code == UDAgentConversationOver) {
        [self createServerCustomer];
    }
    
    if ([UdeskManager isBlacklisted]) {
        //黑名单用户
        [self.chatAlert showIsBlacklistedAlert:self.blackedMessage];
    }
    else {
        
        [self showAlertViewWithAgent];
    }
}

//根据客服code展示alertview
- (void)showAlertViewWithAgent {
    
    @try {
        
        if (self.sdkSetting) {
            
            NSString *no_reply_hint = self.sdkSetting.noReplyHint;
            if(self.agentModel.code == UDAgentStatusResultQueue) {
                no_reply_hint = self.agentModel.message;
            }
            
            //开启留言
            if (self.sdkSetting.enableWebImFeedback.boolValue) {
                
                if (self.agentModel.code == UDAgentStatusResultOffline) {
                    no_reply_hint = getUDLocalizedString(@"udesk_alert_view_leave_msg");
                }
                
                [self.chatAlert showChatAlertViewWithCode:self.agentModel.code andMessage:no_reply_hint enableWebImFeedback:YES];
                return;
            }
            
            //关闭留言
            if (self.agentModel.code == UDAgentStatusResultOffline) {
                if ([UdeskTools isBlankString:no_reply_hint]) {
                    no_reply_hint = getUDLocalizedString(@"udesk_alert_view_no_reply_hint");
                }
            }
            
            [self.chatAlert showChatAlertViewWithCode:self.agentModel.code andMessage:no_reply_hint enableWebImFeedback:NO];
            
            return;
        }
        
        [self.chatAlert showChatAlertViewWithCode:self.agentModel.code andMessage:self.agentModel.message enableWebImFeedback:YES];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}


#pragma mark - 更新消息内容
- (void)updateContent {
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(reloadChatTableView)]) {
            [self.delegate reloadChatTableView];
        }
    }
}

#pragma mark - 重发失败的消息
- (void)resendFailedMessage:(void(^)(UdeskMessage *failedMessage,BOOL sendStatus))completion {
    
    [UdeskResendManager resendFailedMessage:self.resendArray completion:completion];
}

//失败的消息数组
- (NSMutableArray *)resendArray {
    
    if (!_resendArray) {
        _resendArray = [NSMutableArray array];
    }
    return _resendArray;
}
//添加失败的消息
- (void)addResendMessageToArray:(UdeskMessage *)message {
    
    if (message) {
        [self.resendArray addObject:message];
    }
}
//删除失败的消息
- (void)removeResendMessageInArray:(UdeskMessage *)message {
    
    @try {
        
        if (message) {
            [self.resendArray removeObject:message];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (NSInteger)numberOfItems {
    
    return [self.messageArray count];
}

- (id)objectAtIndexPath:(NSInteger)row {
    
    return [self.messageArray objectAtIndexCheck:row];
}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUdeskReachabilityChangedNotification object:nil];
}

@end
