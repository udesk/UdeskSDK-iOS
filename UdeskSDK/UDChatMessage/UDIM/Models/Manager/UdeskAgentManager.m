//
//  UdeskAgentManager.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/18.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskAgentManager.h"
#import "UdeskMessage+UdeskSDK.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKConfig.h"
#import "UdeskAgentUtil.h"
#import "UdeskAgent.h"
#import "UdeskManager.h"
#import "UdeskSDKAlert.h"
#import "UdeskBundleUtils.h"
#import "UdeskTicketViewController.h"

@interface UdeskAgentManager()

/** sdk设置项 */
@property (nonatomic, strong) UdeskSetting *sdkSetting;
/** 客服信息 */
@property (nonatomic, strong, readwrite) UdeskAgent *agentModel;

@end

@implementation UdeskAgentManager {
    
    /** 直接留言引导语 */
    BOOL _leaveMessageGuideFlag;
}

- (instancetype)initWithSetting:(UdeskSetting *)setting
{
    self = [super init];
    if (self) {
        _sdkSetting = setting;
    }
    return self;
}

- (void)fetchAgent:(void(^)(UdeskAgent *agentModel))completion {
    
    [self fetchAgentWithPreSessionMessage:nil completion:completion];
}

- (void)fetchAgentWithPreSessionMessage:(UdeskMessage *)preSessionMessage completion:(void(^)(UdeskAgent *agentModel))completion {
    
    NSString *agentId = [UdeskAgentManager udAgentId];
    NSString *groupId = [UdeskAgentManager udGroupId];
    NSString *menuId = [UdeskAgentManager udMenuId];
    
    //获取客服信息
    if (![UdeskSDKUtil isBlankString:menuId]) {
        //获取指定客服ID的客服信息
        [UdeskAgentUtil fetchAgentWithMenuId:menuId preSessionId:self.preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agentModel, NSError *error) {
            [self setupWithAgentModel:agentModel completion:completion];
        }];
    }
    else if (![UdeskSDKUtil isBlankString:agentId]) {
        //获取指定客服ID的客服信息
        [UdeskAgentUtil fetchAgentWithAgentId:agentId preSessionId:self.preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agentModel, NSError *error) {
            [self setupWithAgentModel:agentModel completion:completion];
        }];
    }
    else if (![UdeskSDKUtil isBlankString:groupId]) {
        //获取指定客服组ID的客服组信息
        [UdeskAgentUtil fetchAgentWithGroupId:groupId preSessionId:self.preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agentModel, NSError *error) {
            [self setupWithAgentModel:agentModel completion:completion];
        }];
    }
    else {
        //根据管理员后台配置选择客服
        [UdeskAgentUtil fetchAgentWithPreSessionId:self.preSessionId preSessionMessage:preSessionMessage completion:^(UdeskAgent *agentModel, NSError *error) {
            [self setupWithAgentModel:agentModel completion:completion];
        }];
    }
}

//配置
- (void)setupWithAgentModel:(UdeskAgent *)agentModel completion:(void(^)(UdeskAgent *agentModel))completion {
    
    self.preSessionId = nil;
    
    //这里是因为 有时nick会是null
    if ([UdeskSDKUtil isBlankString:agentModel.nick] && self.agentModel) {
        agentModel.nick = self.agentModel.nick;
    }
    
    self.agentModel = agentModel;
    
    //设置留言类型
    [self setupAgentLeaveMessageType];
    
    //客服离线
    if (agentModel.statusType != UDAgentStatusResultOnline) {
        
        //排队
        if (agentModel.statusType == UDAgentStatusResultQueue) {
            [self showQueueEvent];
        }
        else {
            [self agentOffline];
        }
    }
    else {
        //客服在线
        [self agentOnline];
    }
    
    if (self.didUpdateAgentBlock) {
        self.didUpdateAgentBlock(self.agentModel);
    }
    
    if (completion) {
        completion(self.agentModel);
    }
}

//客服离线
- (void)agentOffline {
    
    //还在会话中
    if (self.agentModel.sessionType == UDAgentSessionTypeInSession) {
        return;
    }
    
    //放弃排队
    [self quitQueue];
    
    //开启留言
    if (_sdkSetting.enableWebImFeedback.boolValue &&
        ([_sdkSetting.leaveMessageType isEqualToString:@"msg"] || [_sdkSetting.leaveMessageType isEqualToString:@"im"])) {
        [self leaveMessageWithAgentOffline];
        return;
    }
    
    [self showAlert];
}

//客服在线
- (void)agentOnline {
    
    //登陆成功回调
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    if (sdkConfig.actionConfig.loginSuccessBlock) {
        sdkConfig.actionConfig.loginSuccessBlock();
    }
    
    //咨询对象
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (sdkConfig.productDictionary) {
            UdeskMessage *productMessage = [[UdeskMessage alloc] initWithProduct:sdkConfig.productDictionary];
            [UdeskManager sendMessage:productMessage progress:nil completion:nil];
        }
    });
    
    //移除排队事件
    [self removeQueueEvent];
}

//设置留言类型
- (void)setupAgentLeaveMessageType {
    
    if ([self.sdkSetting.leaveMessageType isEqualToString:@"msg"]) {
        self.agentModel.leaveMessageType = UDAgentLeaveMessageTypeLeave;
    }
    else if ([self.sdkSetting.leaveMessageType isEqualToString:@"im"]) {
        self.agentModel.leaveMessageType = UDAgentLeaveMessageTypeBoard;
    }
    else if ([self.sdkSetting.leaveMessageType isEqualToString:@"form"]) {
        self.agentModel.leaveMessageType = UDAgentLeaveMessageTypeForm;
    }
    
    //留言关闭
    if (!self.sdkSetting.enableWebImFeedback.boolValue) {
        self.agentModel.leaveMessageType = UDAgentLeaveMessageTypeClose;
    }
}

//显示排队事件
- (void)showQueueEvent {
    
    if (self.didUpdateQueueMessageBlock) {
        self.didUpdateQueueMessageBlock(self.agentModel.message);
    }
    
    [UdeskSDKAlert hide];
}

//移除排队事件
- (void)removeQueueEvent {
    
    if (self.didRemoveQueueMessageBlock) {
        self.didRemoveQueueMessageBlock();
    }
}

//放弃排队
- (void)quitQueue {
    
    [UdeskAgentUtil setUdeskQuitQueue:YES];
    [UdeskManager cancelAllOperations];
    [UdeskManager quitQueueWithType:[UdeskSDKConfig customConfig].quitQueueMode];
}

//直接留言/工作台留言
- (void)leaveMessageWithAgentOffline {
 
    //移除排队事件
    [self removeQueueEvent];
    
    self.agentModel.statusType = UDAgentStatusResultOffline;
    self.agentModel.message = getUDLocalizedString(@"udesk_leave_msg");
    
    if (self.didUpdateAgentBlock) {
        self.didUpdateAgentBlock(self.agentModel);
    }
    
    if (!_leaveMessageGuideFlag) {
        if (self.didAddLeaveMessageGuideBlock) {
            self.didAddLeaveMessageGuideBlock();
        }
        _leaveMessageGuideFlag = YES;
    }
}

//根据客服code展示alertview
- (void)showAlert {
    
    //网络断开链接
    if (self.networkDisconnect) {
        [UdeskSDKAlert showWithMessage:getUDLocalizedString(@"udesk_network_disconnect") handler:nil];
        return;
    }
    
    if (self.sdkSetting) {
        NSString *noReplyhint = self.sdkSetting.noReplyHint;
        if(self.agentModel.statusType == UDAgentStatusResultQueue) {
            noReplyhint = self.agentModel.message;
        }
        
        //开启留言
        if (self.sdkSetting.enableWebImFeedback.boolValue) {
            if (self.agentModel.statusType == UDAgentStatusResultOffline) {
                //表单留言文案
                if ([UdeskSDKUtil isBlankString:self.sdkSetting.leaveMessageGuide]) {
                    noReplyhint = getUDLocalizedString(@"udesk_alert_view_leave_msg");
                }
                else {
                    noReplyhint = self.sdkSetting.leaveMessageGuide;
                }
            }
            
            [UdeskSDKAlert showWithAgentCode:self.agentModel.statusType message:noReplyhint enableFeedback:YES leaveMsgHandler:^{
                [self leaveMessageTapAction];
            }];
            return;
        }
        
        //关闭留言
        if (self.agentModel.statusType == UDAgentStatusResultOffline) {
            if ([UdeskSDKUtil isBlankString:noReplyhint]) {
                noReplyhint = getUDLocalizedString(@"udesk_alert_view_no_reply_hint");
            }
        }
        
        [UdeskSDKAlert showWithAgentCode:self.agentModel.statusType message:noReplyhint enableFeedback:NO leaveMsgHandler:^{
            [self leaveMessageTapAction];
        }];
        return;
    }
    
    [UdeskSDKAlert showWithAgentCode:self.agentModel.statusType message:self.agentModel.message enableFeedback:YES leaveMsgHandler:^{
        [self leaveMessageTapAction];
    }];
}

//点击留言
- (void)leaveMessageTapAction {
    
    if (self.sdkSetting) {
        //表单
        if ([self.sdkSetting.leaveMessageType isEqualToString:@"form"]) {
            [self showForm];
        }
        //直接留言
        else if ([self.sdkSetting.leaveMessageType isEqualToString:@"msg"] ||
                 [self.sdkSetting.leaveMessageType isEqualToString:@"im"]) {
            [self leaveMessageWithAgentOffline];
            [self quitQueue];
        }
        return;
    }
    
    //发送表单
    [self showForm];
    [self quitQueue];
}

- (void)showForm {
    
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    //如果用户实现了自定义留言界面
    if (sdkConfig.actionConfig.leaveMessageClickBlock) {
        sdkConfig.actionConfig.leaveMessageClickBlock([UdeskSDKUtil currentViewController]);
        return;
    }
    
    UdeskTicketViewController *offLineTicket = [[UdeskTicketViewController alloc] initWithSDKConfig:sdkConfig setting:self.sdkSetting];
    offLineTicket.modalPresentationStyle = UIModalPresentationFullScreen;
    [[UdeskSDKUtil currentViewController] presentViewController:offLineTicket animated:YES completion:nil];
}

//收到转接
- (void)receiveRedirect:(UdeskAgent *)agent {
    
    //这里是因为 有时nick会是null
    if ([UdeskSDKUtil isBlankString:agent.nick] && self.agentModel) {
        agent.nick = self.agentModel.nick;
    }
    
    self.agentModel = agent;
    
    if (self.didUpdateAgentBlock) {
        self.didUpdateAgentBlock(self.agentModel);
    }
}

//收到状态
- (void)receivePresence:(NSDictionary *)presence {
    
    @try {
        
        //客服上线
        NSString *statusType = [NSString stringWithFormat:@"%@",[presence objectForKey:@"type"]];
        if ([UdeskSDKUtil isBlankString:self.agentModel.jid] && [statusType isEqualToString:@"available"]) {
            [self fetchAgent:nil];
            return;
        }
        
        UDAgentSessionType agentSession = self.agentModel.sessionType;
        UDAgentStatusType agentStatus = self.agentModel.statusType;
        NSString *agentMessage = @"unavailable";
        NSString *agentNick = self.agentModel.nick;
        //容错处理
        if ([UdeskSDKUtil isBlankString:agentNick]) {
            agentNick = @"";
        }
        
        if([statusType isEqualToString:@"over"]) {
            
            agentSession = UDAgentSessionTypeHasOver;
            agentStatus = UDAgentStatusResultOffline;
            agentMessage = getUDLocalizedString(@"udesk_chat_end");
        }
        else if ([statusType isEqualToString:@"available"]) {
            
            agentSession = UDAgentSessionTypeInSession;
            agentStatus = UDAgentStatusResultOnline;
            agentMessage = [NSString stringWithFormat:@"%@ %@ %@",getUDLocalizedString(@"udesk_agent"),agentNick,getUDLocalizedString(@"udesk_online")];
        }
        else if ([statusType isEqualToString:@"unavailable"]) {
            
            agentSession = UDAgentSessionTypeInSession;
            agentStatus = UDAgentStatusResultOffline;
            agentMessage = [NSString stringWithFormat:@"%@ %@ %@",getUDLocalizedString(@"udesk_agent"),agentNick,getUDLocalizedString(@"udesk_offline")];
        }
        
        //与上次不同的code才抛给vc
        if (self.agentModel.statusType != agentStatus) {
            self.agentModel.statusType = agentStatus;
            self.agentModel.sessionType = agentSession;
            self.agentModel.message = agentMessage;
            
            if (self.didUpdateAgentPresenceBlock) {
                self.didUpdateAgentPresenceBlock(self.agentModel);
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//会话已关闭
- (void)sessionClosed {
    
    self.agentModel.message = getUDLocalizedString(@"udesk_chat_end");
    self.agentModel.sessionType = UDAgentSessionTypeHasOver;
    self.agentModel.statusType = UDAgentStatusResultOffline;

    if (self.didUpdateAgentBlock) {
        self.didUpdateAgentBlock(self.agentModel);
    }
}

//客服组ID
+ (NSString *)udGroupId {
    
    NSString *groupId = [UdeskSDKConfig customConfig].groupId;
    if ([UdeskSDKUtil isBlankString:groupId]) {
        return [UdeskSDKUtil getGroupId];
    }
    else {
        return groupId;
    }
}

//客服ID
+ (NSString *)udAgentId {
    return [UdeskSDKConfig customConfig].agentId;
}

//导航栏客服组ID
+ (NSString *)udMenuId {
    NSString *menuId = [UdeskSDKConfig customConfig].menuId;
    if ([UdeskSDKUtil isBlankString:menuId]) {
        return [UdeskSDKUtil getMenuId];
    }
    else {
        return menuId;
    }
}

@end
