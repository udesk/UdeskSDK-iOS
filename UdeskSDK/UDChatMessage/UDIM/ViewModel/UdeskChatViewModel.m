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
#import "UdeskMessage+UdeskSDK.h"
#import "UdeskBundleUtils.h"
#import "UdeskLocationModel.h"
#import "UdeskGoodsModel.h"
#import "UdeskSDKAlert.h"
#import "UdeskMessageUtil.h"
#import "UdeskManager.h"
#import "UdeskThrottleUtil.h"
#import "UdeskSDKConfig.h"
#import "UdeskAgentUtil.h"
//#import "Udesk_YYWebImage.h"

@interface UdeskChatViewModel()<UDManagerDelegate>

/** 消息 */
@property (nonatomic, strong ,readwrite) NSArray       *messagesArray;
/** 失败的消息 */
@property (nonatomic, strong) NSMutableArray           *resendArray;
/** sdk后台配置 */
@property (nonatomic, strong) UdeskSetting             *sdkSetting;
/** 无消息会话ID */
@property (nonatomic, strong, readwrite) NSNumber      *preSessionId;
/** 无消息对话过滤时发送的消息 */
@property (nonatomic, strong) NSMutableArray           *preSessionMessages;
/** 机器人消息个数 */
@property (nonatomic, assign) NSInteger robotMessageCount;

@property (nonatomic, assign)BOOL app_willActive;//记录一次app由后台变为活跃

@end

@implementation UdeskChatViewModel

- (instancetype)initWithSDKSetting:(UdeskSetting *)sdkSetting delegate:(id)delegate
{
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        //根据配置显示
        [self showSDKFeatureWithSetting:sdkSetting];
        //UdeskSDK代理
        [UdeskManager receiveUdeskDelegate:self];
        //检测网络
        [self.networkManager start];
        //获取消息记录
        [self.messageManager fetchMessages];
        //检测sdk配置
        if (!self.sdkSetting || self.sdkSetting == (id)kCFNull || ![self.sdkSetting isKindOfClass:[UdeskSetting class]]) {
            [self fetchSDKSetting];
        }
        
        //监听进入后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        //将要进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        //进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

#pragma mark - SDK初始化
- (void)fetchSDKSetting {
    
    [UdeskManager fetchSDKSetting:^(UdeskSetting *setting) {
        
        //设置图片请求头
        //还未经过测试，暂时注释
//        if (setting.referer) {
//            NSMutableDictionary *header = [Udesk_YYWebImageManager sharedManager].headers.mutableCopy;
//            header[@"referer"] = setting.referer;
//            [Udesk_YYWebImageManager sharedManager].headers = header;
//        }
        //根据后台配置创建用户
        [self showSDKFeatureWithSetting:setting];
        
    } failure:^(NSError *error) {
        //根据后台配置创建用户
        NSLog(@"UdeskSDK:SDK初始化失败，请检查控制台是否有其他日志输出。搜索关键字‘UdeskSDK’");
    }];
}

//根据配置展示sdk相关的模块
- (void)showSDKFeatureWithSetting:(UdeskSetting *)setting {
    if (!setting || setting == (id)kCFNull) return ;
    _sdkSetting = setting;
    
    //置空机器人消息条数
    self.robotMessageCount = 0;
    
    //用户在黑名单
    if (setting.isBlocked.boolValue) {
        [self customerInBlackList:setting.blackListNotice];
        return;
    }
    
    //正在会话/排队
    if ([setting.status isEqualToString:@"chatting"] || [setting.status isEqualToString:@"queuing"]) {
        [self requestAgentDataWithPreSessionMessage:nil completion:nil];
    }
    //无消息对话过滤
    else if ([setting.status isEqualToString:@"pre_session"]) {
        [self preSessionWithTitle:setting.preSessionTitle preSessionId:setting.preSessionId];
    }
    //按设置好的走 机器人->无消息对话过滤->人工
    else {
        //开通机器人
        if (setting.enableRobot.boolValue && !setting.inSession.boolValue) {
            [UdeskManager initRobot:^(NSString *robotName) {
                [self udeskRobotSessionWithName:robotName];
            }];
            return;
        }
        //无消息对话过滤
        if (setting.showPreSession.boolValue && !setting.inSession.boolValue) {
            [self preSessionWithTitle:setting.preSessionTitle preSessionId:setting.preSessionId];
            return;
        }
        [self fetchServersAgent:nil];
    }
}

#pragma mark - 请求客服数据
- (void)fetchServersAgent:(void(^)(UdeskAgent *agentModel))completion {
    
    //机器人
    if (self.messageManager.isRobotSession) {
        return;
    }
    
    //无消息过滤状态下
    if (self.preSessionId) {
        return;
    }
    
    [self requestAgentDataWithPreSessionMessage:nil completion:completion];
}

- (void)requestAgentDataWithPreSessionMessage:(UdeskMessage *)preSessionMessage completion:(void(^)(UdeskAgent *agentModel))completion {
    
    [self.agentManager fetchAgentWithPreSessionMessage:preSessionMessage completion:^(UdeskAgent *agentModel) {
        
        //清空无消息会话ID
        self.preSessionId = nil;
        self.messageManager.isRobotSession = NO;
        //配置视频通话
        [self configUdeskCallWithAgent:agentModel];
        
        if (completion) {
            completion(agentModel);
        }
    }];
}

#pragma mark - UDManagerDelegate
- (void)didReceiveMessages:(UdeskMessage *)message {
        
    if (!message || message == (id)kCFNull) return ;
    if ([UdeskSDKUtil isBlankString:message.content] && message.showTransfer) {
        message.content = getUDLocalizedString(@"udesk_showTransfer_place_tip");
    }
    if ([UdeskSDKUtil isBlankString:message.content]) return;
    
    //收到消息时当前客服状态不在线 请求客服验证
    if (self.agentManager.agentModel && self.agentManager.agentModel.statusType != UDAgentStatusResultOnline && message.sendType != UDMessageSendTypeRobot) {
        [self fetchServersAgent:nil];
    }
    
    //撤回消息
    if (message.messageType == UDMessageContentTypeRollback) {
        [self.messageManager receiveRollbackWithMessage:message];
    }
    
    [self.messageManager addMessageToArray:@[message]];
}

//接受到转接
- (void)didReceiveRedirect:(UdeskAgent *)agent {
    
    //处理转接
    [self.agentManager receiveRedirect:agent];
    //配置视频通话
    [self configUdeskCallWithAgent:agent];
}

//接收客服状态
- (void)didReceivePresence:(NSDictionary *)presence {
    
    //处理客服状态
    if (!self.preSessionId && !self.messageManager.isRobotSession) {
        [self.agentManager receivePresence:presence];
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

//需要重新拉下消息
- (void)didReceiveRequestServersMessages {
    
    [self.messageManager fetchServersMessages];
}

//请求配置信息
- (void)didReceiveRequestServersSetting {
    
    [self.agentManager sessionClosed];
    [self.messageManager sessionClosed];
    [self fetchSDKSetting];
}

//请求客服信息
- (void)didReceiveRequestServersAgent:(UdeskMessage *)message {
    
    //无消息对话过滤/机器人会话
    if (self.preSessionId || self.messageManager.isRobotSession) {
        return;
    }
    
    if (self.agentManager.agentModel.leaveMessageType == UDAgentLeaveMessageTypeBoard) {
        [self.agentManager fetchAgent:^(UdeskAgent *agentModel) {
            [UdeskManager sendMessage:message progress:nil completion:nil];
        }];
    }
}

//用户在黑名单中
- (void)customerInBlackList:(NSString *)blackListNotice {
    
    NSString *tips = [UdeskSDKUtil isBlankString:blackListNotice]?getUDLocalizedString(@"udesk_im_title_blocked_list"):blackListNotice;
    if (self.delegate && [self.delegate respondsToSelector:@selector(customerOnTheBlacklist:)]) {
        [self.delegate customerOnTheBlacklist:tips];
    }
}

//无消息对话过滤
- (void)preSessionWithTitle:(NSString *)preSessionTitle preSessionId:(NSNumber *)preSessionId {
    
    if (self.agentManager.agentModel && self.agentManager.agentModel.sessionType != UDAgentSessionTypeHasOver) {
        return ;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showPreSessionWithTitle:)]) {
        [self.delegate showPreSessionWithTitle:preSessionTitle];
    }
    
    self.messageManager.isRobotSession = NO;
    self.agentManager.preSessionId = preSessionId;
    self.preSessionId = preSessionId;
    
    if (!preSessionId) {
        
        @udWeakify(self);
        [UdeskManager createPreSessionWithAgentId:[UdeskAgentManager udAgentId] groupId:[UdeskAgentManager udGroupId] completion:^(NSNumber *preSessionId,NSError *error) {
            @udStrongify(self);
            self.agentManager.preSessionId = preSessionId;
            self.preSessionId = preSessionId;
        }];
    }
    [UdeskSDKAlert hide];
}

//机器人会话
- (void)udeskRobotSessionWithName:(NSString *)robotName {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showRobotSessionWithName:)]) {
        [self.delegate showRobotSessionWithName:robotName];
    }
    self.messageManager.isRobotSession = YES;
    [UdeskSDKAlert hide];
}

//排队消息已到最大值
- (void)queueMessageHasMaxed:(NSString *)alertText {
    
    [UdeskSDKAlert showWithMessage:alertText handler:nil];
}

//自动转人工
- (void)didReceiveAutoTransferAgentServer {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveAutoTransferAgentServer)]) {
        [self.delegate didReceiveAutoTransferAgentServer];
    }
}

#pragma mark - 客服
- (UdeskAgentManager *)agentManager {
    if (!_agentManager) {
        _agentManager = [[UdeskAgentManager alloc] initWithSetting:self.sdkSetting];
        @udWeakify(self);
        //更新客服信息
        _agentManager.didUpdateAgentBlock = ^(UdeskAgent *agent) {
            @udStrongify(self);
            [self updateAgent:agent];
        };
        //更新客服状态
        _agentManager.didUpdateAgentPresenceBlock = ^(UdeskAgent *agent) {
            @udStrongify(self);
            [self updateAgentPresence:agent];
        };
        //更新排队信息
        _agentManager.didUpdateQueueMessageBlock = ^(NSString *contentText) {
            @udStrongify(self);
            [self updateQueueMessage:contentText];
        };
        //移除排队信息
        _agentManager.didRemoveQueueMessageBlock = ^{
            @udStrongify(self);
            [self removeQueueMessage];
        };
        //添加直接留言引导语
        _agentManager.didAddLeaveMessageGuideBlock = ^{
            @udStrongify(self);
            [self addLeaveMessageGuide];
        };
    }
    return _agentManager;
}

//更新客服信息
- (void)updateAgent:(UdeskAgent *)agent {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateAgentModel:)]) {
        [self.delegate didUpdateAgentModel:agent];
    }
    
    self.messageManager.agentModel = agent;
}

//更新客服状态
- (void)updateAgentPresence:(UdeskAgent *)agent {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateAgentPresence:)]) {
        [self.delegate didUpdateAgentPresence:agent];
    }
    
    //会话已关闭
    if (agent.statusType == UDAgentSessionTypeHasOver) {
        [self.messageManager sessionClosed];
    }
}

//显示排队事件
- (void)updateQueueMessage:(NSString *)contentText {

    [self.messageManager updateQueueMessageWithContent:contentText];
}

//移除排队事件
- (void)removeQueueMessage {
    
    [self.messageManager removeQueueInArray];
}

//添加直接留言文案
- (void)addLeaveMessageGuide {
    
    [self.messageManager addLeaveGuideMessageToArray];
}

//点击留言
- (void)leaveMessageTapAction {
    
    [self.agentManager leaveMessageTapAction];
}

//显示提示框
- (void)showSDKAlert {
    
    //会话已关闭
    if (self.agentManager.agentModel.sessionType == UDAgentSessionTypeHasOver) {
        [self fetchSDKSetting];
    }
    else {
        
        //表单留言提示
        if (self.agentManager.agentModel.leaveMessageType == UDAgentLeaveMessageTypeForm) {
            [self.agentManager showAlert];
        }
    }
}

//转人工
- (void)transferToAgentServer {
    
    //正在会话
    if (self.agentManager.agentModel.sessionType == UDAgentSessionTypeInSession) {
        [self updateAgent:self.agentManager.agentModel];
        return;
    }
    
    UdeskMessage *transferEvent = [[UdeskMessage alloc] initWithRobotTransferMessage:getUDLocalizedString(@"udesk_redirect")];
    [self.messageManager addMessageToArray:@[transferEvent]];
    
    if (self.sdkSetting.showPreSession.boolValue) {
        [self preSessionWithTitle:self.sdkSetting.preSessionTitle preSessionId:self.sdkSetting.preSessionId];
        return;
    }
    
    [self requestAgentDataWithPreSessionMessage:nil completion:nil];
}

#pragma mark - 消息
- (UdeskMessageManager *)messageManager {
    if (!_messageManager) {
        _messageManager = [[UdeskMessageManager alloc] initWithSetting:self.sdkSetting];
        @udWeakify(self);
        _messageManager.didUpdateMessagesBlock = ^(NSArray *messages) {
            @udStrongify(self);
            [self reloadChatWithMessages:messages];
        };
        _messageManager.didUpdateMoreMessagesBlock = ^(NSArray *messages) {
            @udStrongify(self);
            [self reloadChatWithMoreMessages:messages];
        };
        _messageManager.didUpdateMessageAtIndexPathBlock = ^(NSIndexPath *indexPath) {
            @udStrongify(self);
            [self reloadChatAtIndexPath:indexPath];
        };
        
        _messageManager.updateAgentInfo = ^(UdeskMessage *message) {
            @udStrongify(self);
            [self updateAgentServerWithMessage:message];
        };
    }
    return _messageManager;
}

//刷新
- (void)reloadChatWithMessages:(NSArray *)messages {
    
    self.isShowRefresh = self.messageManager.isShowRefresh;
    self.messagesArray = [messages copy];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadChatTableView)]) {
        [self.delegate reloadChatTableView];
    }
}

- (void)reloadChatWithMoreMessages:(NSArray *)messages {
    
    self.isShowRefresh = self.messageManager.isShowRefresh;
    self.messagesArray = [messages copy];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadMoreMessageChatTableView)]) {
        [self.delegate reloadMoreMessageChatTableView];
    }
}

- (void)reloadChatAtIndexPath:(NSIndexPath *)indexPath {
 
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateCellModelWithIndexPath:)]) {
        [self.delegate didUpdateCellModelWithIndexPath:indexPath];
    }
}

- (void)updateAgentServerWithMessage:(UdeskMessage *)message {
    
    [self fetchServersAgent:^(UdeskAgent *agentModel) {
        
        if (agentModel.statusType == UDAgentStatusResultOnline) {
            [self sendTextMessage:message.content completion:nil];
        }
    }];
}

//获取下一页数据
- (void)fetchNextPageMessages {
    
    [self.messageManager fetchNextPageMessages];
}

//发送消息
- (void)sendRobotMessage:(UdeskMessage *)message completion:(void(^)(UdeskMessage *message))completion {
    
    if (!message || message == (id)kCFNull) return ;
    if (![message isKindOfClass:[UdeskMessage class]]) return ;
    
    self.robotMessageCount ++;
    if (self.robotMessageCount == self.sdkSetting.showRobotTimes.integerValue) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(showTransferButton)]) {
            [self.delegate showTransferButton];
        }
    }
    [self.messageManager sendRobotMessage:message completion:completion];
}

//发送文字消息
- (void)sendTextMessage:(NSString *)text completion:(void(^)(UdeskMessage *message))completion {
    
    //检查是否是空消息
    if ([UdeskSDKUtil isBlankString:text]) {
        [UdeskSDKAlert showWithMessage:getUDLocalizedString(@"udesk_no_send_empty") handler:nil];
        return;
    }
    
    //机器人消息
    if (self.messageManager.isRobotSession) {
        UdeskMessage *robotMessage = [[UdeskMessage alloc] initWithText:text];
        robotMessage.sendType = UDMessageSendTypeRobot;
        [self sendRobotMessage:robotMessage completion:completion];
        return;
    }
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *textMessage = [[UdeskMessage alloc] initWithText:text];
        [self endPreSessionWithMessage:textMessage progress:nil completion:completion];
        return;
    }
    
    //会话未创建&客服离线&(表单留言|未开启留言)
    if (self.agentManager.agentModel.sessionType == UDAgentSessionTypeNotCreate &&
        self.agentManager.agentModel.statusType == UDAgentStatusResultOffline &&
        (self.agentManager.agentModel.leaveMessageType == UDAgentLeaveMessageTypeForm ||
         self.agentManager.agentModel.leaveMessageType == UDAgentLeaveMessageTypeClose)) {
        [self.agentManager showAlert];
        return;
    }
    
    [self.messageManager sendTextMessage:text completion:completion];
}

//发送图片消息
- (void)sendImageMessage:(UIImage *)image progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!image || image == (id)kCFNull) return ;
    if (![image isKindOfClass:[UIImage class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *imageMessage = [[UdeskMessage alloc] initWithImage:image];
        [self endPreSessionWithMessage:imageMessage progress:progress completion:completion];
        return;
    }
    
    [self.messageManager sendImageMessage:image progress:progress completion:completion];
}

//发送GIF图片消息
- (void)sendGIFImageMessage:(NSData *)gifData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!gifData || gifData == (id)kCFNull) return ;
    if (![gifData isKindOfClass:[NSData class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *gifMessage = [self.messageManager gifMessageWithData:gifData];
        [self endPreSessionWithMessage:gifMessage progress:progress completion:completion];
        return;
    }
    
    [self.messageManager sendGIFImageMessage:gifData progress:progress completion:completion];
}

//发送视频消息
- (void)sendVideoMessage:(NSData *)videoData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!videoData || videoData == (id)kCFNull) return ;
    if (![videoData isKindOfClass:[NSData class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *videoMessage = [self.messageManager videoMessageWithVideoData:videoData];
        [self endPreSessionWithMessage:videoMessage progress:progress completion:completion];
        return;
    }
    
    [self.messageManager sendVideoMessage:videoData progress:progress completion:completion];
}

//发送语音消息
- (void)sendVoiceMessage:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration completion:(void (^)(UdeskMessage *message))completion {
    
    if (!voicePath || voicePath == (id)kCFNull) return ;
    if (![voicePath isKindOfClass:[NSString class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *voiceMessage = [self.messageManager voiceMessageWithPath:voicePath duration:voiceDuration];
        [self endPreSessionWithMessage:voiceMessage progress:nil completion:completion];
        return;
    }
    
    [self.messageManager sendVoiceMessage:voicePath voiceDuration:voiceDuration completion:completion];
}

//发送地理位置
- (void)sendLocationMessage:(UdeskLocationModel *)model completion:(void(^)(UdeskMessage *message))completion {
    
    if (!model || model == (id)kCFNull) return ;
    if (![model isKindOfClass:[UdeskLocationModel class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *locationMsg = [self.messageManager locationMessageWithModel:model];
        [self endPreSessionWithMessage:locationMsg progress:nil completion:completion];
        return;
    }
    
    [self.messageManager sendLocationMessage:model completion:completion];
}

//发送商品消息
- (void)sendGoodsMessage:(UdeskGoodsModel *)model completion:(void(^)(UdeskMessage *message))completion {
    
    if (!model || model == (id)kCFNull) return ;
    if (![model isKindOfClass:[UdeskGoodsModel class]]) return ;
    
    //无消息过滤
    if (self.preSessionId) {
        UdeskMessage *goodsMsg = [[UdeskMessage alloc] initWithGoods:model];
        [self endPreSessionWithMessage:goodsMsg progress:nil completion:completion];
        return;
    }
    
    [self.messageManager sendGoodsMessage:model completion:completion];
}

//发送事件消息
- (void)sendChatEventMessage:(NSString *)text completion:(void(^)(UdeskMessage *message))completion {
    if (!text || text == (id)kCFNull) return ;
    if ([UdeskSDKUtil isBlankString:text]) return;
    
    UdeskMessage *message = [[UdeskMessage alloc] initWithChatEvent:text];
    [self.messageManager addMessageToArray:@[message]];
}

//结束无消息对话过滤
- (void)endPreSessionWithMessage:(UdeskMessage *)message progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion {
    
    if (!message || message == (id)kCFNull) return ;
    if (![message isKindOfClass:[UdeskMessage class]]) return ;
     
    [self.preSessionMessages addObject:message];
    ud_dispatch_throttle(0.5f, ^{
        
        UdeskMessage *firstPreMessage = self.preSessionMessages.firstObject;
        if (!firstPreMessage || firstPreMessage == (id)kCFNull) return ;
        //这里延迟的原因是发送图片和视频会先离开chat页面发送时才重新进入，这里处理了那个时间差。
        CGFloat delay = firstPreMessage.messageType != UDMessageContentTypeText ? 0.8f : 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //更新标题
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateChatTitleWithText:)]) {
                [self.delegate updateChatTitleWithText:getUDLocalizedString(@"udesk_connecting")];
            }
            
            @udWeakify(self);
            [self requestAgentDataWithPreSessionMessage:firstPreMessage completion:^(UdeskAgent *agentModel) {
                @udStrongify(self);
                //客服离线，发送留言
                if (agentModel.statusType == UDAgentStatusResultOffline) {
                    if (agentModel.leaveMessageType == UDAgentLeaveMessageTypeLeave||
                        agentModel.leaveMessageType == UDAgentLeaveMessageTypeBoard) {
                       
                        if (message.messageType == UDMessageContentTypeText) {
                            [self.messageManager sendTextMessage:message.content completion:completion];
                        }
                    }
                    else if (agentModel.leaveMessageType == UDAgentLeaveMessageTypeForm) {
                        message.messageStatus = UDMessageSendStatusFailed;
                        if (completion) completion(message);
                    }
                    return;
                }
                
                if (self.preSessionMessages.count) {
                    message.messageStatus = UDMessageSendStatusSuccess;
                    [self.messageManager addMessageToArray:@[firstPreMessage]];
                    if (completion) completion(message);
                    
                    //检查是否还有未发出去的（图片多张一起发的情况）
                    for (int i = 1; i<self.preSessionMessages.count; i++) {
                        UdeskMessage *preSessionMsg = self.preSessionMessages[i];
                        [UdeskManager sendMessage:preSessionMsg progress:^(float percent) {
                            if (progress) {
                                progress(preSessionMsg.messageId,percent);
                            }
                        } completion:completion];
                        [self.messageManager addMessageToArray:@[preSessionMsg]];
                    }
                    
                    [self.preSessionMessages removeAllObjects];
                }
            }];
        });
    });
}

//重发失败的消息
- (void)autoResendFailedMessageWithProgress:(void(^)(float percent))progress
                                 completion:(void(^)(UdeskMessage *failedMessage))completion {
    
    if (!self.resendArray || self.resendArray == (id)kCFNull || self.resendArray.count == 0) return ;
    [UdeskMessageUtil resendFailedMessage:self.resendArray progress:progress completion:completion];
}

- (void)resendMessageWithMessage:(UdeskMessage *)resendMessage
                        progress:(void(^)(float percent))progress
                      completion:(void(^)(UdeskMessage *message))completion {
    
    //无消息对话过滤
    if (self.preSessionId) {
        [self endPreSessionWithMessage:resendMessage progress:^(NSString *key, float percent) {
            if (progress) {
                progress(percent);
            }
        } completion:completion];
        return;
    }
    
    //机器人
    if (self.messageManager.isRobotSession) {
        resendMessage.sendType = UDMessageSendTypeRobot;
        [UdeskManager sendMessage:resendMessage progress:progress completion:completion];
        return;
    }
    
    //人工
    if (self.agentManager.agentModel.statusType == UDAgentStatusResultOffline) {
        
        [self requestAgentDataWithPreSessionMessage:nil completion:^(UdeskAgent *agentModel) {
            if (agentModel.statusType == UDAgentStatusResultOnline) {
                [UdeskManager sendMessage:resendMessage progress:progress completion:completion];
            }
            else {
                
                //客服离线会话还未结束 发送离线消息
                if (self.agentManager.agentModel.sessionType == UDAgentSessionTypeInSession) {
                    [UdeskManager sendMessage:resendMessage progress:progress completion:completion];
                }
                //客服离线会话未创建 发送留言
                else if (self.agentManager.agentModel.sessionType == UDAgentSessionTypeNotCreate) {
                 
                    if (self.agentManager.agentModel.leaveMessageType == UDAgentLeaveMessageTypeForm ||
                        self.agentManager.agentModel.leaveMessageType == UDAgentLeaveMessageTypeClose) {
                        resendMessage.messageStatus = UDMessageSendStatusFailed;
                        if (completion) completion(resendMessage);
                        return ;
                    }
                    else if (self.agentManager.agentModel.leaveMessageType == UDAgentLeaveMessageTypeBoard) {
                        resendMessage.sendType = UDMessageSendTypeBoard;
                    }
                    else if (self.agentManager.agentModel.leaveMessageType == UDAgentLeaveMessageTypeLeave) {
                        resendMessage.sendType = UDMessageSendTypeLeave;
                    }
                    [UdeskManager sendMessage:resendMessage progress:progress completion:completion];
                }
            }
        }];
    }
    else {
        
        if (self.agentManager.agentModel.statusType == UDAgentStatusResultOnline) {
            resendMessage.sendType = UDMessageSendTypeNormal;
        }
        else if (self.agentManager.agentModel.statusType == UDAgentStatusResultQueue) {
            resendMessage.sendType = UDMessageSendTypeQueue;
        }
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

//lazy
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

#pragma mark - 网络
- (UdeskNetworkManager *)networkManager {
    if (!_networkManager) {
        _networkManager = [[UdeskNetworkManager alloc] init];
        @udWeakify(self);
        _networkManager.connectBlock = ^{
            @udStrongify(self);
            self.agentManager.networkDisconnect = NO;
            [self fetchSDKSetting];
        };
        _networkManager.disconnectBlock = ^{
            @udStrongify(self);
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveNetworkDisconnect)]) {
                [self.delegate didReceiveNetworkDisconnect];
            }
            self.agentManager.networkDisconnect = YES;
        };
    }
    return _networkManager;
}

#pragma mark - 视频通话
- (UdeskCallManager *)callManager {
    if (!_callManager) {
        _callManager = [[UdeskCallManager alloc] initWithSetting:self.sdkSetting];
        @udWeakify(self);
        _callManager.didSendMessageBlock = ^(UdeskMessage *message) {
            @udStrongify(self);
            [self.messageManager addMessageToArray:@[message]];
        };
    }
    return _callManager;
}

//配置视频通话
- (void)configUdeskCallWithAgent:(UdeskAgent *)agentModel {
    if(![UdeskSDKConfig customConfig].isInitUdeskCall){
        return;
    }
#if __has_include(<UdeskCall/UdeskCall.h>)
    [self.callManager configUdeskCallWithCustomerJID:[UdeskManager customerJID] agentModel:agentModel];
#endif
}

//开始视频通话
- (void)startUdeskVideoCall {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    [self.callManager startUdeskVideoCall];
#endif
}

- (void)appDidEnterBackground:(NSNotification *)ntf {
    //放弃排队
    if (self.agentManager.agentModel.statusType == UDAgentStatusResultQueue) {   
        [UdeskAgentUtil setUdeskQuitQueue:YES];
        [UdeskManager quitQueueWithType:[UdeskSDKConfig customConfig].quitQueueMode];
    }
}

- (void)appWillEnterForeground:(NSNotification *)ntf {
    self.app_willActive = YES;
}

- (void)appDidBecomeActive:(NSNotification *)ntf {
    if(self.app_willActive){
        //前后台切换时刷新排队状态
        if (self.agentManager.agentModel.statusType == UDAgentStatusResultQueue) {
            [UdeskAgentUtil setUdeskQuitQueue:NO];
            [self requestAgentDataWithPreSessionMessage:nil completion:nil];
        }
        self.app_willActive = NO;
    }
}

- (void)dealloc
{
    NSLog(@"UdeskSDK：%@释放了",[self class]);
}

@end
