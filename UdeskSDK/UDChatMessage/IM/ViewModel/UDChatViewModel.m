//
//  UDChatViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/19.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDChatViewModel.h"
#import "UDReceiveMessage.h"
#import "UDAgentModel.h"
#import "NSTimer+UDMessage.h"
#import "UDTools.h"
#import "UDAlertController.h"
#import "UDCache.h"
#import "UDFoundationMacro.h"
#import "UdeskUtils.h"
#import "NSArray+UDMessage.h"
#import "UDHpple.h"
#import "UDAgentHttpData.h"
#import "UDReachability.h"
#import "UDManager.h"

@interface UDChatViewModel()<UDManagerDelegate>

@property (nonatomic, strong,readwrite) NSMutableArray *messageArray;//消息数据
@property (nonatomic, strong,readwrite) NSMutableArray *failedMessageArray;//发送失败的消息
@property (nonatomic, assign) BOOL      netWorkChange;//网络切换
@property (nonatomic, assign) NSInteger message_number;//消息数

@end

@implementation UDChatViewModel

- (instancetype)initWithAgentId:(NSString *)agent_id withGroupId:(NSString *)group_id
{
    self = [super init];
    if (self) {
        
        self.messageArray = [NSMutableArray array];
        self.failedMessageArray = [NSMutableArray array];
        
        [UDManager receiveUdeskDelegate:self];
        
        @udWeakify(self);
        //获取db消息
        [self requestDataBaseMessageContent];
        
        //获取客户信息
        [UDManager createServerCustomer:^(id responseObject) {
            
            //提交设备信息
            [self submitCustomerDevicesInfo];
            //请求客服数据
            [self requestAgentWithAgentId:agent_id withGroupId:group_id];
            
        } failure:^(NSError *error) {
            
            NSLog(@"用户信息获取失败：%@",error);
        }];
        
        
        UDReachability *networkReach = [UDReachability reachabilityWithHostname:@"www.baidu.com"];
        
        networkReach.reachableBlock = ^(UDReachability *reachability)
        {
            @udStrongify(self);
            if (self.netWorkChange) {
                self.netWorkChange = NO;
                //请求客服数据
                [self requestAgentWithAgentId:agent_id withGroupId:group_id];
            }
            
        };
        
        networkReach.unreachableBlock = ^(UDReachability *reachability)
        {
            
            @udStrongify(self);
            self.netWorkChange = YES;
            self.agentModel.message = @"网络断开连接了";
            self.agentModel.code = 2003;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self callbackAgentModel:self.agentModel];
            });            
        };
        
        [networkReach startNotifier];

    }
    return self;
}

#pragma mark - 获取DB数据
- (void)requestDataBaseMessageContent {

    //获取db条数
    NSInteger messageContent = [UDManager dbMessageCount];
    
    self.message_count = messageContent;
    self.message_total_pages = messageContent;
    
    NSString *sql;
    if (self.message_total_pages<20) {
        
        sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%ld",MessageDB,(long)self.message_number,(long)self.message_total_pages];
    }
    else {
        
        sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%d",MessageDB,(long)self.message_number,20];
        self.message_total_pages-=20;
        self.message_number += 20;
    }
    
    //查询db数据
    NSArray *dbArray = [UDManager queryTabelWithSqlString:sql params:nil];
    
    for (NSDictionary *dbMessage in dbArray) {
        
        [self.messageArray insertObject:[self ud_messageModelWithDictionary:dbMessage] atIndex:0];
    }
    
    //更新UI
    [self updateContent];

}

//加载更多DB消息
- (void)pullMoreDateBaseMessage {
    
    NSString *sql;
    if (self.message_total_pages<20) {
        
        sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%ld",MessageDB,(long)self.message_number,(long)self.message_total_pages];
    }
    else {
        
        sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%d",MessageDB,(long)self.message_number,20];
        self.message_total_pages-=20;
        self.message_number += 20;

    }
    
    NSArray *dbArray = [UDManager queryTabelWithSqlString:sql params:nil];
    for (NSDictionary *dbMoreMessage in dbArray) {
        [self.messageArray insertObject:[self ud_messageModelWithDictionary:dbMoreMessage] atIndex:0];
    }
    
    //更新UI
    [self updateContent];
    
}

#pragma mark - 根据是否有客服id和客服组id请求客服数据
- (void)requestAgentWithAgentId:(NSString *)agent_id withGroupId:(NSString *)group_id {

    @udWeakify(self);
    //获取客服信息
    if (![UDTools isBlankString:group_id]||![UDTools isBlankString:agent_id]) {
        
        //指定客服或客服组
        [[UDAgentHttpData sharedAgentHttpData] chooseAgentWithAgentId:agent_id withGroupId:group_id completion:^(UDAgentModel *agentModel, NSError *error) {
            
            @udStrongify(self);
            [self distributionAgent:agentModel];
        }];
        
    }
    else {
        //根据管理员后台配置选择客服
        [[UDAgentHttpData sharedAgentHttpData] requestRandomAgent:^(UDAgentModel *agentModel, NSError *error) {
            
            @udStrongify(self);
            [self distributionAgent:agentModel];
        }];
    }
}

//获取分配客服
- (void)distributionAgent:(UDAgentModel *)agentModel {

    //回调客服信息到vc显示
    [self callbackAgentModel:agentModel];
    //获取用户登录信息
    [self requestCustomerLoginInfo];
}

//回调客服信息到vc显示
- (void)callbackAgentModel:(UDAgentModel *)agentModel {
    
    if (self.fetchAgentDataBlock) {
        self.fetchAgentDataBlock(agentModel);
    }
    self.agentModel = agentModel;
}
//取消轮询排队时候的客服接口
- (void)cancelPollingAgent {

    [UDAgentHttpData sharedAgentHttpData].stopRequest = YES;
}

#pragma mark - 获取用户登录信息
- (void)requestCustomerLoginInfo {

    @udWeakify(self);
    [UDManager getCustomerLoginInfo:^(NSDictionary *loginInfoDic, NSError *error) {
        
        //登录Udesk
        @udStrongify(self);
        [self loginUdeskWithAgentCode:self.agentModel.code];
    }];

}

#pragma mark - 提交设备信息
- (void)submitCustomerDevicesInfo {

    //提交设备信息
    [UDManager submitCustomerDevicesInfo:^(id responseObject, NSError *error) {
        
        NSLog(@"设备信息提交成功");
    }];
}

#pragma mark - 登录Udesk
- (void)loginUdeskWithAgentCode:(NSInteger)code {

    if (code != 2000 && code != 2001) {
        
        [self showAlertViewWithAgentCode:code];
        return;
    }
    //只有客服在线才登录
    if (code == 2000) {
        //登录
        [UDManager loginUdesk:^(BOOL status) {
            
            NSLog(@"登录Udesk成功");
        }];
        
    }
}

#pragma mark - UDManagerDelegate
- (void)didReceiveMessages:(NSDictionary *)message {
    
    NSDictionary *messageDictionary = [UDTools dictionaryWithJsonString:[message objectForKey:@"strContent"]];
    @udWeakify(self);
    [UDReceiveMessage ud_messageModelWithDictionary:messageDictionary completion:^(UDMessage *message) {
        
        //刷新UI
        @udStrongify(self);
        [self.messageArray addObject:message];
        [self updateContent];
        
    } redirectAgent:^(UDAgentModel *agentModel) {
        
        //把获取到的新客服回调给vc
        @udStrongify(self);
        [self callbackAgentModel:agentModel];
    }];
    
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
    if (self.agentModel.code != agentCode) {
        
        self.agentModel.code = agentCode;
        self.agentModel.message = agentMessage;
        [self callbackAgentModel:self.agentModel];
    }
    
}

//接收客服发送的满意度调查
- (void)didReceiveSurvey:(NSString *)isSurvey withAgentId:(NSString *)agentId {
    
    //客服发送满意度调查
    if ([isSurvey isEqualToString:@"true"]) {
        
        [UDManager getSurveyOptions:^(id responseObject, NSError *error) {
            //解析数据
            NSDictionary *result = [responseObject objectForKey:@"result"];
            NSString *title = [result objectForKey:@"title"];
            NSString *desc = [result objectForKey:@"desc"];
            NSArray *options = [result objectForKey:@"options"];
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                //根据返回的信息填充Alert数据
                UDAlertController *optionsAlert = [UDAlertController alertWithTitle:title message:desc];
                [optionsAlert addCloseActionWithTitle:@"关闭" Handler:NULL];
                //遍历选项数组
                for (NSDictionary *option in options) {
                    //依次添加选项
                    [optionsAlert addAction:[UDAlertAction actionWithTitle:[option objectForKey:@"text"] handler:^(UDAlertAction * _Nonnull action) {
                        //根据点击的选项 提交到Udesk
                        [UDManager survetVoteWithAgentId:agentId withOptionId:[option objectForKey:@"id"] completion:^(id responseObject, NSError *error) {
                            
                            //评价提交成功Alert
                            [self surveyCompletion];
                            
                        }];
                        
                    }]];
                }
                //展示Alert
                [optionsAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            }
            
        }];
    }
}
//评价提交成功Alert
- (void)surveyCompletion {
    
    UDAlertController *completionAlert = [UDAlertController alertWithTitle:nil message:getUDLocalizedString(@"感谢您的评价")];
    [completionAlert addCloseActionWithTitle:getUDLocalizedString(@"关闭") Handler:NULL];
    
    [completionAlert showWithSender:nil controller:nil animated:YES completion:NULL];
}

#pragma mark - 发送文字消息
- (void)sendTextMessage:(NSString *)text
             completion:(void(^)(UDMessage *message,BOOL sendStatus))completion {
    
    if (_agentModel.code != 2000) {
        
        [self showAlertViewWithAgentCode:_agentModel.code];
        
        return;
    }
    
    if ([UDTools isBlankString:text]) {
        UDAlertController *notOnline = [UDAlertController alertWithTitle:nil message:@"不能发送空白消息"];
        [notOnline addCloseActionWithTitle:@"确定" Handler:nil];
        [notOnline showWithSender:nil controller:nil animated:YES completion:NULL];
        
        return;
    }
    
    NSDate *date = [NSDate date];
    
    UDMessage *textMessage = [[UDMessage alloc] initWithText:text timestamp:date];
    
    textMessage.agent_jid = _agentModel.jid;
    
    [self.messageArray addObject:textMessage];
    //通知刷新UI
    [self updateContent];
    
    NSArray *array = @[text,[UDTools stringFromDate:date],textMessage.contentId,@"0",@"0",@"0"];
    
    [UDManager insertTableWithSqlString:InsertTextMsg params:array];
    
    //发送消息 callback发送状态和消息体
    [UDManager sendMessage:textMessage completion:^(UDMessage *message,BOOL sendStatus) {
        
        if (completion) {
            completion(message,sendStatus);
        }
        
    }];

}

#pragma mark - 发送图片消息
- (void)sendImageMessage:(UIImage *)image
              completion:(void(^)(UDMessage *message,BOOL sendStatus))completion {

    if (_agentModel.code != 2000) {
        
        [self showAlertViewWithAgentCode:_agentModel.code];
        
        return;
    }
    
    //限制图片的size
    NSString *newWidth = [NSString stringWithFormat:@"%f",[UDTools setImageSize:image].width];
    NSString *newHeight = [NSString stringWithFormat:@"%f",[UDTools setImageSize:image].height];
    
    NSDate *date = [NSDate date];
    //大于1M的照片需要压缩
    NSData *data = UIImageJPEGRepresentation(image, 1);
    if (data.length/1024 > 1024) {
        image = [UDTools compressImageWith:image];
    }
    
    UDMessage *photoMessage = [[UDMessage alloc] initWithPhoto:image timestamp:date];
    photoMessage.agent_jid = _agentModel.jid;
    photoMessage.width = newWidth;
    photoMessage.height = newHeight;
    
    [self.messageArray addObject:photoMessage];
    //通知刷新UI
    [self updateContent];
    
    //缓存图片
    [[UDCache sharedUDCache] storeImage:photoMessage.photo forKey:photoMessage.contentId];
    
    //存储
    NSArray *array = @[@"image",[UDTools stringFromDate:date],photoMessage.contentId,@"0",@"0",@"1",newWidth,newHeight];
    
    [UDManager insertTableWithSqlString:InsertPhotoMsg params:array];
    
    //发送消息 callback发送状态和消息体
    [UDManager sendMessage:photoMessage completion:^(UDMessage *message,BOOL sendStatus) {
        
        if (completion) {
            completion(message,sendStatus);
        }
    }];
    
}

#pragma mark - 发送语音消息
- (void)sendAudioMessage:(NSString *)audioPath
           audioDuration:(NSString *)audioDuration
              completion:(void (^)(UDMessage *, BOOL sendStatus))comletion {
    
    if (_agentModel.code != 2000) {
        
        [self showAlertViewWithAgentCode:_agentModel.code];
        
        return;
    }
        
    NSDate *date = [NSDate date];
    
    UDMessage *voiceMessage = [[UDMessage alloc] initWithVoicePath:audioPath voiceDuration:audioDuration timestamp:date];
    voiceMessage.agent_jid = _agentModel.jid;
    
    [self.messageArray addObject:voiceMessage];
    //通知刷新UI
    [self updateContent];
    
    NSArray *array = @[audioPath,[UDTools stringFromDate:date],voiceMessage.contentId,@"0",@"0",@"2",audioDuration];
    [UDManager insertTableWithSqlString:InsertAudioMsg params:array];
    
    NSData *voiceData = [NSData dataWithContentsOfFile:audioPath];
    
    //缓存语音
    [[UDCache sharedUDCache] storeData:voiceData forKey:voiceMessage.contentId];
    
    //发送消息 callback发送状态和消息体
    [UDManager sendMessage:voiceMessage completion:^(UDMessage *message,BOOL sendStatus) {
        
        if (comletion) {
            comletion(message,sendStatus);
        }
    }];
    
}

#pragma mark - Alert
//排队Alert
- (void)queueStatus {
    
    NSString *ticketButtonTitle = getUDLocalizedString(@"留言");
    UDAlertController *queueAlert = [UDAlertController alertWithTitle:nil message:getUDLocalizedString(@"当前客服正繁忙，如需留言请点击按钮进入表单留言")];
    [queueAlert addCloseActionWithTitle:getUDLocalizedString(@"取消") Handler:NULL];
    @udWeakify(self);
    [queueAlert addAction:[UDAlertAction actionWithTitle:ticketButtonTitle handler:^(UDAlertAction * _Nonnull action) {
        
        @udStrongify(self);
        [self sendOffLineTicket];
    }]];
    
    [queueAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    
}

//客服不在线Alert
- (void)agentNotOnline {
    
    NSString *title = getUDLocalizedString(@"客服不在线");
    NSString *message = getUDLocalizedString(@"您可以选择提交表单来描述您的问题，稍后我们会和您联系。");
    NSString *cancelButtonTitle = getUDLocalizedString(@"取消");
    NSString *ticketButtonTitle = getUDLocalizedString(@"留言");
    
    UDAlertController *notOnlineAlert = [UDAlertController alertWithTitle:title message:message];
    [notOnlineAlert addCloseActionWithTitle:cancelButtonTitle Handler:NULL];
    
    @udWeakify(self);
    [notOnlineAlert addAction:[UDAlertAction actionWithTitle:ticketButtonTitle handler:^(UDAlertAction * _Nonnull action) {
        
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
    
    UDAlertController *notNetworkAlert = [UDAlertController alertWithTitle:nil message:@"网络断开连接，请先连接网络"];
    [notNetworkAlert addCloseActionWithTitle:@"确定" Handler:NULL];
    [notNetworkAlert showWithSender:nil controller:nil animated:YES completion:NULL];
}

//不存在客服或客服组
- (void)notExistAgent {

    UDAlertController *notExistAgentAlert = [UDAlertController alertWithTitle:nil message:self.agentModel.message];
    [notExistAgentAlert addCloseActionWithTitle:@"确定" Handler:NULL];
    [notExistAgentAlert showWithSender:nil controller:nil animated:YES completion:NULL];

}

//NSDictionary转model
- (UDMessage *)ud_messageModelWithDictionary:(NSDictionary *)dbMessage {
    
    UDMessage *message = [[UDMessage alloc] init];
    message.messageFrom = [[dbMessage objectForKey:@"direction"] integerValue];
    message.messageType = [[dbMessage objectForKey:@"mesType"] integerValue];
    message.contentId = [dbMessage objectForKey:@"msgid"];
    message.messageStatus = [[dbMessage objectForKey:@"sendflag"] integerValue];
    message.timestamp = [UDTools dateFromString:[dbMessage objectForKey:@"replied_at"]];
    
    NSString *content = [dbMessage objectForKey:@"content"];
    
    switch (message.messageType) {
        case UDMessageMediaTypeText:
            message.text = [UDTools receiveTextEmoji:content];
            
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
            UDHpple *xpathParser = [[UDHpple alloc] initWithHTMLData:htmlData];
            
            NSArray *dataPArray = [xpathParser searchWithXPathQuery:@"//p"];
            NSArray *dataAArray = [xpathParser searchWithXPathQuery:@"//a"];
            
            for (UDHppleElement *happleElement in dataPArray) {
                
                if ([UDTools isBlankString:message.text]) {
                    message.text = happleElement.content;
                }
                else {
                    
                    message.text = [NSString stringWithFormat:@"%@\n",message.text];
                    message.text = [message.text stringByAppendingString:happleElement.content];
                }
                
            }
            
            NSMutableDictionary *richURLDictionary = [NSMutableDictionary dictionary];
            NSMutableArray *richContetnArray = [NSMutableArray array];
            
            for (UDHppleElement *happleElement in dataAArray) {
                
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
- (void)showAlertViewWithAgentCode:(NSInteger)code {

    if (code == 2002) {
        
        [self agentNotOnline];
    }
    else if (code == 2003) {
        
        [self netWorkDisconnectAlertView];
    }
    else if (code == 2001) {
        [self queueStatus];
    }
    else if (code == 5050||code == 5060) {
        
        [self notExistAgent];
    }
    
}

#pragma mark - 更新消息内容
- (void)updateContent {

    if (self.updateMessageContentBlock) {
        self.updateMessageContentBlock();
    }
}

#pragma mark - 重发失败的消息
- (void)resendFailedMessage:(void(^)(UDMessage *failedMessage,BOOL sendStatus))completion {
    
    @udWeakify(self);
    [NSTimer ud_scheduleTimerWithTimeInterval:6.0f repeats:YES usingBlock:^(NSTimer *timer) {
        
        @udStrongify(self);
        if (self.failedMessageArray.count==0) {
            
            [timer invalidate];
            timer = nil;
        }
        else {
            
            //重新发送
            [self sendFailedMessage:^(UDMessage *failedMessage, BOOL sendStatus) {
                
                if (completion) {
                    completion(failedMessage,sendStatus);
                }
            }];
        }
    }];
    
}

- (void)sendFailedMessage:(void(^)(UDMessage *failedMessage,BOOL sendStatus))completion {
    
    for (UDMessage *resendMessage in self.failedMessageArray) {
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:resendMessage.timestamp];
        
        if (fabs (timeInterval) > 60) {
            
            if (completion) {
                completion(resendMessage,NO);
            }
            
            [self.failedMessageArray removeObject:resendMessage];
            
        } else {
            
            [UDManager sendMessage:resendMessage completion:^(UDMessage *message, BOOL sendStatus) {
                
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

- (UDMessage *)objectAtIndexPath:(NSInteger)row {

    return [self.messageArray objectAtIndexCheck:row];
    
}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
}

@end