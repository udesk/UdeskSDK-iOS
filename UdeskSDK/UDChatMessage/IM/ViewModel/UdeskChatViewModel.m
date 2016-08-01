//
//  UdeskChatViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/19.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskChatViewModel.h"
#import "UdeskAgentModel.h"
#import "NSTimer+UdeskSDK.h"
#import "UdeskTools.h"
#import "UdeskAlertController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "NSArray+UdeskSDK.h"
#import "UdeskHpple.h"
#import "UdeskAgentHttpData.h"
#import "UdeskReachability.h"
#import "UdeskDateFormatter.h"
#import "UdeskManager.h"

@interface UdeskChatViewModel()<UDManagerDelegate> {

    UdeskMessage *_productMessage;
    UdeskAlertController *_optionsAlert;
}

@property (nonatomic, strong,readwrite) NSMutableArray    *messageArray;//消息数据
@property (nonatomic, strong,readwrite) NSMutableArray    *failedMessageArray;//发送失败的消息
@property (nonatomic, assign          ) BOOL              netWorkChange;//网络切换
@property (nonatomic, assign          ) NSInteger         message_number;//消息数
@property (nonatomic, strong          ) NSString          *agent_id;//客服id
@property (nonatomic, strong          ) NSString          *group_id;//客服组id
@property (nonatomic, strong          ) UdeskMessage      *productMessage;
@property (nonatomic                  ) UdeskReachability *reachability;

@end

@implementation UdeskChatViewModel

- (instancetype)initWithAgentId:(NSString *)agent_id withGroupId:(NSString *)group_id
{
    self = [super init];
    if (self) {
        
        _agent_id = agent_id;
        _group_id = group_id;
        
        self.messageArray = [NSMutableArray array];
        self.failedMessageArray = [NSMutableArray array];
        
        [UdeskManager receiveUdeskDelegate:self];
        
        @udWeakify(self);
        //获取db消息
        [self requestDataBaseMessageContent];
        
        //创建用户(为了保证sdk正常使用请不要删除使用UdeskManager的方法)
        [UdeskManager createServerCustomer:^(id responseObject) {
            
            //获取客户信息(为了保证sdk正常使用请不要删除使用UdeskManager的方法)
            [UdeskManager getCustomerLoginInfo:^(NSDictionary *loginInfoDic, NSError *error) {
                
                @udStrongify(self);
                //请求客服数据(为了保证sdk正常使用请不要删除使用UdeskManager的方法)
                [self requestAgentWithAgentId:agent_id withGroupId:group_id];
            }];
            
        } failure:^(NSError *error) {
            
            NSLog(@"用户信息获取失败：%@",error);
        }];
        
        //网络监测
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kUdeskReachabilityChangedNotification object:nil];
        self.reachability  = [UdeskReachability reachabilityWithHostName:@"www.baidu.com"];
        [self.reachability startNotifier];
    }
    return self;
}

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
                [self requestAgentWithAgentId:self.agent_id withGroupId:self.group_id];
            }
            break;
        }
            
        case UDNotReachable:{
            
            @udStrongify(self);
            self.netWorkChange = YES;
            self.agentModel.message = @"网络断开连接了";
            self.agentModel.code = @2003;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self callbackAgentModel:self.agentModel];
            });
            
        }
            
        default:
            break;
    }
    
}

#pragma mark - 获取DB数据
- (void)requestDataBaseMessageContent {

    //获取db条数
    NSInteger messageContent = [UdeskManager dbMessageCount];
    
    self.message_count = messageContent;
    self.message_total_pages = messageContent;
    
    NSString *sql;
    if (self.message_total_pages<20) {
        
        sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%ld",UD_Message_DB,(long)self.message_number,(long)self.message_total_pages];
    }
    else {
        
        sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%d",UD_Message_DB,(long)self.message_number,20];
        self.message_total_pages-=20;
        self.message_number += 20;
    }
    
    //查询db数据
    NSArray *dbArray = [UdeskManager queryTabelWithSqlString:sql params:nil];
    
    for (NSDictionary *dbMessage in dbArray) {
        
        [self.messageArray insertObject:[self ud_modelWithDictionary:dbMessage] atIndex:0];
    }
    
    //更新UI
    [self updateContent];
}

//加载更多DB消息
- (void)pullMoreDateBaseMessage {
    
    NSString *sql;
    if (self.message_total_pages<20) {
        
        sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%ld",UD_Message_DB,(long)self.message_number,(long)self.message_total_pages];
    }
    else {
        
        sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%d",UD_Message_DB,(long)self.message_number,20];
        self.message_total_pages-=20;
        self.message_number += 20;

    }
    
    NSArray *dbArray = [UdeskManager queryTabelWithSqlString:sql params:nil];
    for (NSDictionary *dbMoreMessage in dbArray) {
        [self.messageArray insertObject:[self ud_modelWithDictionary:dbMoreMessage] atIndex:0];
    }
    
    //更新UI
    [self updateContent];
}

#pragma mark - 根据是否有客服id和客服组id请求客服数据
- (void)requestAgentWithAgentId:(NSString *)agent_id withGroupId:(NSString *)group_id {

    @udWeakify(self);
    //获取客服信息
    if (![UdeskTools isBlankString:group_id]||![UdeskTools isBlankString:agent_id]) {
        
        //指定客服或客服组
        [[UdeskAgentHttpData sharedAgentHttpData] chooseAgentWithAgentId:agent_id withGroupId:group_id completion:^(UdeskAgentModel *agentModel, NSError *error) {
            
            @udStrongify(self);
            [self distributionAgent:agentModel];
        }];
    }
    else {
        
        //根据管理员后台配置选择客服
        [[UdeskAgentHttpData sharedAgentHttpData] requestRandomAgent:^(UdeskAgentModel *agentModel, NSError *error) {
            
            @udStrongify(self);
            [self distributionAgent:agentModel];
        }];
    }
}

//获取分配客服
- (void)distributionAgent:(UdeskAgentModel *)agentModel {

    //回调客服信息到vc显示
    [self callbackAgentModel:agentModel];
    //用户登录
    [self loginUdeskWithAgentCode:agentModel.code];
}

//回调客服信息到vc显示
- (void)callbackAgentModel:(UdeskAgentModel *)agentModel {
    
    if (self.fetchAgentDataBlock) {
        self.fetchAgentDataBlock(agentModel);
    }
    self.agentModel = agentModel;
}
//取消轮询排队时候的客服接口
- (void)cancelPollingAgent {

    [UdeskAgentHttpData sharedAgentHttpData].stopRequest = YES;
}

- (void)requestQueue {

    [UdeskAgentHttpData sharedAgentHttpData].stopRequest = NO;
}

#pragma mark - 登录Udesk
- (void)loginUdeskWithAgentCode:(NSNumber *)code {
    
    if (code.integerValue != 2000 && code.integerValue != 2001) {
        
        [self showAlertViewWithAgentCode:code];
        return;
    }
    //只有客服在线才登录
    if (code.integerValue == 2000) {
        
        [self sendProductMessage];
        //登录
        @udWeakify(self);
        [UdeskManager loginUdesk:^(BOOL status) {
            NSLog(@"登录Udesk成功");
            @udStrongify(self);
            [self sendProductMessage];
        }];
        
    }
}

#pragma mark - UDManagerDelegate
- (void)didReceiveMessages:(id )message {
    
    if ([message isKindOfClass:[UdeskMessage class]]) {
        
        UdeskMessage *newMessage = (UdeskMessage *)message;
        
        if (newMessage.messageType == UDMessageMediaTypeText) {
            newMessage.text = [UdeskTools receiveTextEmoji:newMessage.text];
        }
        if (newMessage.messageType == UDMessageMediaTypeRich) {
            newMessage = [self modelWithRich:newMessage];
        }
        
        [self.messageArray addObject:newMessage];
        [self updateContent];
    }
    else if ([message isKindOfClass:[NSDictionary class]]) {
    
        NSDictionary *newMessage = (NSDictionary *)message;
        UdeskAgentModel *agentModel = [[UdeskAgentModel alloc] initWithContentsOfDic:newMessage];
        [self callbackAgentModel:agentModel];
    }
    
}
//接收客服状态
- (void)didReceivePresence:(NSDictionary *)presence {
    
    NSString *statusType = [presence objectForKey:@"type"];
    
    NSInteger  agentCode;
    NSString  *agentMessage;
    if ([statusType isEqualToString:@"available"]) {
        
        agentCode = 2000;
        agentMessage = [NSString stringWithFormat:@"客服 %@ 在线",self.agentModel.nick];
        
    } else {
        
        agentCode = 2002;
        agentMessage = [NSString stringWithFormat:@"客服 %@ 离线了",self.agentModel.nick];
    }
    
    //与上次不同的code才抛给vc
    if (self.agentModel.code.integerValue != agentCode) {
        
        self.agentModel.code = [NSNumber numberWithInteger:agentCode];
        self.agentModel.message = agentMessage;
        [self callbackAgentModel:self.agentModel];
    }
    
}

//接收客服发送的满意度调查
- (void)didReceiveSurvey:(NSString *)isSurvey withAgentId:(NSString *)agentId {
    
    if (_optionsAlert==nil) {
        
        //客服发送满意度调查
        if ([isSurvey isEqualToString:@"true"]) {
            
            [UdeskManager getSurveyOptions:^(id responseObject, NSError *error) {
                //解析数据
                NSDictionary *result = [responseObject objectForKey:@"result"];
                NSString *title = [result objectForKey:@"title"];
                NSString *desc = [result objectForKey:@"desc"];
                NSArray *options = [result objectForKey:@"options"];
                
                if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                    //根据返回的信息填充Alert数据
                    _optionsAlert = [UdeskAlertController alertWithTitle:title message:desc];
                    [_optionsAlert addCloseActionWithTitle:@"关闭" Handler:^(UdeskAlertAction * _Nonnull action) {
                        _optionsAlert = nil;
                    }];
                    //遍历选项数组
                    for (NSDictionary *option in options) {
                        //依次添加选项
                        [_optionsAlert addAction:[UdeskAlertAction actionWithTitle:[option objectForKey:@"text"] handler:^(UdeskAlertAction * _Nonnull action) {
                            
                            _optionsAlert = nil;
                            //根据点击的选项 提交到Udesk
                            [UdeskManager survetVoteWithAgentId:agentId withOptionId:[option objectForKey:@"id"] completion:^(id responseObject, NSError *error) {
                                
                                //评价提交成功Alert
                                [self surveyCompletion];
                                
                            }];
                            
                        }]];
                    }
                    //展示Alert
                    [_optionsAlert showWithSender:nil controller:nil animated:YES completion:NULL];
                }
                
            }];
        }
    }
    
}
//评价提交成功Alert
- (void)surveyCompletion {
    
    UdeskAlertController *completionAlert = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"感谢您的评价")];
    [completionAlert addCloseActionWithTitle:@"关闭" Handler:NULL];
    
    [completionAlert showWithSender:nil controller:nil animated:YES completion:NULL];
}

#pragma mark - 发送文字消息
- (void)sendTextMessage:(NSString *)text
             completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion {
    
    if (_agentModel.code.integerValue != 2000) {
        
        [self showAlertViewWithAgentCode:_agentModel.code];
        
        return;
    }
    
    if ([UdeskTools isBlankString:text]) {
        UdeskAlertController *notOnline = [UdeskAlertController alertWithTitle:nil message:@"不能发送空白消息"];
        [notOnline addCloseActionWithTitle:@"确定" Handler:nil];
        [notOnline showWithSender:nil controller:nil animated:YES completion:NULL];
        
        return;
    }
    
    NSDate *date = [NSDate date];
    
    UdeskMessage *textMessage = [[UdeskMessage alloc] initWithText:text timestamp:date];
    textMessage.agentJid = _agentModel.jid;
    
    [self.messageArray addObject:textMessage];
    //通知刷新UI
    [self updateContent];
    
    //发送消息 callback发送状态和消息体
    [UdeskManager sendMessage:textMessage completion:^(UdeskMessage *message,BOOL sendStatus) {
        
        if (completion) {
            completion(message,sendStatus);
        }
        
    }];

}

#pragma mark - 发送图片消息
- (void)sendImageMessage:(UIImage *)image
              completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion {

    if (_agentModel.code.integerValue != 2000) {
        
        [self showAlertViewWithAgentCode:_agentModel.code];
        
        return;
    }
    
    NSDate *date = [NSDate date];
    //大于1M的照片需要压缩
    NSData *data = UIImageJPEGRepresentation(image, 1);
    if (data.length/1024 > 1024) {
        image = [UdeskTools compressImageWith:image];
    }
    
    UdeskMessage *photoMessage = [[UdeskMessage alloc] initWithPhoto:image timestamp:date];
    photoMessage.agentJid = _agentModel.jid;
    
    [self.messageArray addObject:photoMessage];
    //通知刷新UI
    [self updateContent];
    
    //发送消息 callback发送状态和消息体
    [UdeskManager sendMessage:photoMessage completion:^(UdeskMessage *message,BOOL sendStatus) {
        
        if (completion) {
            completion(message,sendStatus);
        }
    }];
    
}

#pragma mark - 发送语音消息
- (void)sendAudioMessage:(NSString *)audioPath
           audioDuration:(NSString *)audioDuration
              completion:(void (^)(UdeskMessage *, BOOL sendStatus))comletion {
    
    if (_agentModel.code.integerValue != 2000) {
        
        [self showAlertViewWithAgentCode:_agentModel.code];
        
        return;
    }
        
    NSDate *date = [NSDate date];
    
    UdeskMessage *voiceMessage = [[UdeskMessage alloc] initWithVoicePath:audioPath voiceDuration:audioDuration timestamp:date];
    voiceMessage.agentJid = _agentModel.jid;
    
    [self.messageArray addObject:voiceMessage];
    //通知刷新UI
    [self updateContent];
    
    //发送消息 callback发送状态和消息体
    [UdeskManager sendMessage:voiceMessage completion:^(UdeskMessage *message,BOOL sendStatus) {
        
        if (comletion) {
            comletion(message,sendStatus);
        }
    }];
    
}

#pragma mark - Alert
//排队Alert
- (void)queueStatus {
    
    NSString *ticketButtonTitle = @"留言";
    UdeskAlertController *queueAlert = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"当前客服正繁忙，如需留言请点击按钮进入表单留言")];
    [queueAlert addCloseActionWithTitle:@"取消" Handler:NULL];
    @udWeakify(self);
    [queueAlert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle handler:^(UdeskAlertAction * _Nonnull action) {
        
        @udStrongify(self);
        [self sendOffLineTicket];
    }]];
    
    [queueAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    
}

//客服不在线Alert
- (void)agentNotOnline {
    
    NSString *title = getUDLocalizedString(@"客服不在线");
    NSString *message = getUDLocalizedString(@"您可以选择提交表单来描述您的问题，稍后我们会和您联系");
    NSString *cancelButtonTitle = @"取消";
    NSString *ticketButtonTitle = getUDLocalizedString(@"留言");
    
    UdeskAlertController *notOnlineAlert = [UdeskAlertController alertWithTitle:title message:message];
    [notOnlineAlert addCloseActionWithTitle:cancelButtonTitle Handler:NULL];
    
    @udWeakify(self);
    [notOnlineAlert addAction:[UdeskAlertAction actionWithTitle:ticketButtonTitle handler:^(UdeskAlertAction * _Nonnull action) {
        
        @udStrongify(self);
        [self sendOffLineTicket];
    }]];
    
    [notOnlineAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    
}
//回调离线表单
- (void)sendOffLineTicket {

    if (self.clickSendOffLineTicket) {
        self.clickSendOffLineTicket();
    }
}

//无网络Alert
- (void)netWorkDisconnectAlertView {
    
    UdeskAlertController *notNetworkAlert = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"网络断开连接，请先连接网络")];
    [notNetworkAlert addCloseActionWithTitle:@"确定" Handler:NULL];
    [notNetworkAlert showWithSender:nil controller:nil animated:YES completion:NULL];
}

//不存在客服或客服组
- (void)notExistAgent {

    UdeskAlertController *notExistAgentAlert = [UdeskAlertController alertWithTitle:nil message:self.agentModel.message];
    [notExistAgentAlert addCloseActionWithTitle:@"确定" Handler:NULL];
    [notExistAgentAlert showWithSender:nil controller:nil animated:YES completion:NULL];

}

//未知错误
- (void)notConnected {
    
    UdeskAlertController *notExistAgentAlert = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"正在连接，请稍后...")];
    [notExistAgentAlert addCloseActionWithTitle:@"确定" Handler:NULL];
    [notExistAgentAlert showWithSender:nil controller:nil animated:YES completion:NULL];
}

- (UdeskMessage *)modelWithRich:(UdeskMessage *)message {

    NSData *htmlData = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    UdeskHpple *xpathParser = [[UdeskHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *dataPArray = [xpathParser searchWithXPathQuery:@"//p"];
    NSArray *dataAArray = [xpathParser searchWithXPathQuery:@"//a"];
    
    NSString *newText;
    for (UdeskHppleElement *happleElement in dataPArray) {
        
        if ([UdeskTools isBlankString:newText]) {
            newText = happleElement.content;
        }
        else {
            
            newText = [newText stringByAppendingString:[NSString stringWithFormat:@"\n%@",happleElement.content]];
        }
        
    }
    
    message.text = newText;
    
    NSMutableDictionary *richURLDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *richContetnArray = [NSMutableArray array];
    
    for (UdeskHppleElement *happleElement in dataAArray) {
        
        [richURLDictionary setObject:[NSString stringWithFormat:@"%@",happleElement.attributes[@"href"]] forKey:happleElement.content];
        [richContetnArray addObject:happleElement.content];
        
        message.richArray = [NSArray arrayWithArray:richContetnArray];
        
        message.richURLDictionary = [NSDictionary dictionaryWithDictionary:richURLDictionary];
        
    }
    
    return message;
}

//NSDictionary转model
- (UdeskMessage *)ud_modelWithDictionary:(NSDictionary *)dbMessage {
    
    UdeskMessage *message = [[UdeskMessage alloc] init];
    message.messageFrom = [[dbMessage objectForKey:@"direction"] integerValue];
    message.messageType = [[dbMessage objectForKey:@"mesType"] integerValue];
    message.contentId = [dbMessage objectForKey:@"msgid"];
    message.messageStatus = [[dbMessage objectForKey:@"sendflag"] integerValue];
    message.timestamp = [[UdeskDateFormatter sharedFormatter].dateFormatter dateFromString:[dbMessage objectForKey:@"replied_at"]];
    
    NSString *avatar = [dbMessage objectForKey:@"avatar"];
    if ([avatar isEqual:@0]) {
        message.agentAvatar = @"";
    }
    else {
        message.agentAvatar = [dbMessage objectForKey:@"avatar"];
    }
    
    NSString *agent_name = [dbMessage objectForKey:@"agent_name"];
    if ([agent_name isEqual:@0]) {
        message.agentName = @"";
    }
    else {
        message.agentName = [dbMessage objectForKey:@"agent_name"];
    }
    
    NSString *content = [dbMessage objectForKey:@"content"];
    
    switch (message.messageType) {
        case UDMessageMediaTypeText:
            message.text = [UdeskTools receiveTextEmoji:content];
            
            break;
        case UDMessageMediaTypePhoto:{
            
            message.width = [dbMessage objectForKey:@"width"];
            message.height = [dbMessage objectForKey:@"height"];
            message.photoUrl = [dbMessage objectForKey:@"content"];
            
        }
            break;
        case UDMessageMediaTypeVoice:
            message.voiceDuration = [dbMessage objectForKey:@"duration"];
            message.voiceUrl = [dbMessage objectForKey:@"content"];
            
            break;
        case UDMessageMediaTypeRedirect:{
            
            message.text = content;
            
            break;
        }
        case UDMessageMediaTypeRich: {
        
            NSData *htmlData = [content dataUsingEncoding:NSUTF8StringEncoding];
            UdeskHpple *xpathParser = [[UdeskHpple alloc] initWithHTMLData:htmlData];
            
            NSArray *dataPArray = [xpathParser searchWithXPathQuery:@"//p"];
            NSArray *dataAArray = [xpathParser searchWithXPathQuery:@"//a"];
            
            for (UdeskHppleElement *happleElement in dataPArray) {
                
                if ([UdeskTools isBlankString:message.text]) {
                    message.text = happleElement.content;
                }
                else {
                    
                    message.text = [NSString stringWithFormat:@"%@\n",message.text];
                    message.text = [message.text stringByAppendingString:happleElement.content];
                }
                
            }
            
            NSMutableDictionary *richURLDictionary = [NSMutableDictionary dictionary];
            NSMutableArray *richContetnArray = [NSMutableArray array];
            
            for (UdeskHppleElement *happleElement in dataAArray) {
                
                [richURLDictionary setObject:[NSString stringWithFormat:@"%@",happleElement.attributes[@"href"]] forKey:happleElement.content];
                [richContetnArray addObject:happleElement.content];
                
                message.richArray = [NSArray arrayWithArray:richContetnArray];
                
                message.richURLDictionary = [NSDictionary dictionaryWithDictionary:richURLDictionary];
                
            }
            
            break;
        }
            
        default:
            break;
    }
    
    return message;
    
}

#pragma mark - 点击功能栏弹出相应Alert
- (void)clickInputViewShowAlertView {

    [self showAlertViewWithAgentCode:self.agentModel.code];
}

//根据客服code展示alertview
- (void)showAlertViewWithAgentCode:(NSNumber *)code {
    
    if (code.integerValue == 2002) {
        
        [self agentNotOnline];
    }
    else if (code.integerValue == 2003) {
        
        [self netWorkDisconnectAlertView];
    }
    else if (code.integerValue == 2001) {
        [self queueStatus];
    }
    else if (code.integerValue == 5050||code.integerValue == 5060) {
        
        [self notExistAgent];
    }
    else {
    
        [self notConnected];
    }
    
}

#pragma mark - 更新消息内容
- (void)updateContent {

    if (self.updateMessageContentBlock) {
        self.updateMessageContentBlock();
    }
}

#pragma mark - 重发失败的消息
- (void)resendFailedMessage:(void(^)(UdeskMessage *failedMessage,BOOL sendStatus))completion {
    
    @udWeakify(self);
    [NSTimer ud_scheduleTimerWithTimeInterval:6.0f repeats:YES usingBlock:^(NSTimer *timer) {
        
        @udStrongify(self);
        if (self.failedMessageArray.count==0) {
            
            [timer invalidate];
            timer = nil;
        }
        else {
            
            //重新发送
            [self sendFailedMessage:^(UdeskMessage *failedMessage, BOOL sendStatus) {
                
                if (completion) {
                    completion(failedMessage,sendStatus);
                }
            }];
        }
    }];
    
}

- (void)sendFailedMessage:(void(^)(UdeskMessage *failedMessage,BOOL sendStatus))completion {
    
    for (UdeskMessage *resendMessage in self.failedMessageArray) {
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:resendMessage.timestamp];
        
        if (fabs (timeInterval) > 60) {
            
            if (completion) {
                completion(resendMessage,NO);
            }
            
            [self.failedMessageArray removeObject:resendMessage];
            
        } else {
            
            [UdeskManager sendMessage:resendMessage completion:^(UdeskMessage *message, BOOL sendStatus) {
                
                if (completion) {
                    completion(message,sendStatus);
                }
            }];
            
        }

    }

}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {

    return [self.messageArray count];
}

- (UdeskMessage *)objectAtIndexPath:(NSInteger)row {

    return [self.messageArray objectAtIndexCheck:row];
}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUdeskReachabilityChangedNotification object:nil];
}

- (void)saveProductMessage:(UdeskMessage *)message {

    _productMessage = message;
    //添加到数组，并刷新
    [self.messageArray addObject:message];
    [self updateContent];
}

- (void)sendProductMessage {

    if (self.productMessage) {
        self.productMessage.agentJid = self.agentModel.jid;
        [UdeskManager sendMessage:self.productMessage completion:nil];
    }
}

@end