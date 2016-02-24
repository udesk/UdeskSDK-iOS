//
//  UDChatViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/19.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDChatViewModel.h"
#import "UDMessageTableView.h"
#import "UDReceiveChatMsg.h"
#import "UDAgentViewModel.h"
#import "UDMessageInputView.h"
#import "UDEmotionManagerView.h"
#import "UDMessageTextView.h"
#import "UDAgentModel.h"

@interface UDChatViewModel()<UDManagerDelegate> {

    dispatch_source_t timer;
}

@end

@implementation UDChatViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.messageArray = [NSMutableArray array];
        self.failedMessageArray = [NSMutableArray array];
        
    }
    return self;
}

#pragma mark - 发送文字消息
- (void)sendTextMessage:(NSString *)text
             completion:(void(^)(UDMessage *message,BOOL sendStatus))completion {
    
    if (_viewModel.agentModel.code == 2000) {
        
        if ([UDTools isBlankString:text]) {
            UDAlertController *notOnline = [UDAlertController alertWithTitle:nil message:@"不能发送空白消息"];
            [notOnline addCloseActionWithTitle:@"确定" Handler:nil];
            [notOnline showWithSender:nil controller:nil animated:YES completion:NULL];
            
        }
        
        NSDate *date = [NSDate date];
        
        UDMessage *textMessage = [[UDMessage alloc] initWithText:text timestamp:date];
        
        textMessage.agent_jid = _viewModel.agentModel.jid;
        
        [self.messageArray addObject:textMessage];
        //通知刷新UI
        [self reloadChatTableView];
        
        NSArray *array = @[text,[UDTools stringFromDate:date],textMessage.contentId,@"0",@"0",@"0"];
        
        [UDManager insertTableWithSqlString:InsertTextMsg params:array];
        
        //发送消息 callback发送状态和消息体
        [UDManager sendMessage:textMessage completion:^(UDMessage *message,BOOL sendStatus) {
            
            if (completion) {
                completion(message,sendStatus);
            }
            
        }];
        
    }
    else if (_viewModel.agentModel.code == 2001) {
        //请求客服队列
        [self queueStatus];
    }
    else {
        //提示客服不在线
        [self agentNotOnline];
    }

}

#pragma mark - 发送图片消息
- (void)sendImageMessage:(UIImage *)image
              completion:(void(^)(UDMessage *message,BOOL sendStatus))completion {

    if (_viewModel.agentModel.code == 2000) {
        
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
        photoMessage.agent_jid = _viewModel.agentModel.jid;
        photoMessage.width = newWidth;
        photoMessage.height = newHeight;
        
        [self.messageArray addObject:photoMessage];
        //通知刷新UI
        [self reloadChatTableView];
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
    else if (_viewModel.agentModel.code == 2001) {
        //请求队列
        [self queueStatus];
    }
    else {
        //提示客服不在线
        [self agentNotOnline];
    }

}

#pragma mark - 发送语音消息
- (void)sendAudioMessage:(NSString *)audioPath
           audioDuration:(NSString *)audioDuration
              completion:(void (^)(UDMessage *, BOOL))comletion {

    if (_viewModel.agentModel.code == 2000) {
        
        NSDate *date = [NSDate date];
        
        UDMessage *voiceMessage = [[UDMessage alloc] initWithVoicePath:audioPath voiceDuration:audioDuration timestamp:date];
        voiceMessage.agent_jid = _viewModel.agentModel.jid;
        
        [self.messageArray addObject:voiceMessage];
        //通知刷新UI
        [self reloadChatTableView];
        
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
    else if (_viewModel.agentModel.code == 2001) {
        //请求客服队列
        [self queueStatus];
    }
    else {
        //客服不在线提示
        [self agentNotOnline];
    }
}
#pragma mark - 登录Udesk
- (void)loginUdeskWithAgent:(UDAgentViewModel *)viewModel {

    _viewModel = viewModel;
    
    if (viewModel.agentModel.code == 2000) {
        
        //客服在线才登录XMPP
        [UDManager loginUdesk:^(BOOL status) {
            
            if (status) {
                NSLog(@"登录Udesk成功");
            }
            
        } receiveDelegate:self];
    } else if (viewModel.agentModel.code == 2002) {
        
        [self agentNotOnline];
    }
   
}

#pragma mark - UDManagerDelegate
- (void)didReceiveMessages:(NSDictionary *)message {
    
    NSDictionary *messageDic = [UDTools dictionaryWithJsonString:[message objectForKey:@"strContent"]];
    
    UDWEAKSELF
    //解析消息创建消息体并添加到数组
    [UDReceiveChatMsg.store resolveChatMsg:messageDic callbackMsg:^(UDMessage *message) {
        
        [weakSelf.messageArray addObject:message];
        
        [self reloadChatTableView];
    }];
    
}
//接收客服状态
- (void)didReceivePresence:(NSDictionary *)presence {
    
    NSString *statusType = [presence objectForKey:@"type"];
    
    if ([statusType isEqualToString:@"available"]) {
        
        self.viewModel.agentModel.code = 2000;
        
    } else {
        
        self.viewModel.agentModel.code = 2002;
    }
    
    if ([self.delegate respondsToSelector:@selector(receiveAgentPresence:)]) {
        [self.delegate receiveAgentPresence:statusType];
    }
}

#pragma mark - Alert
//排队Alert
- (void)queueStatus {
    
    NSString *ticketButtonTitle = NSLocalizedString(@"留言",@"");
    UDAlertController *queueAlert = [UDAlertController alertWithTitle:nil message:@"当前客服正繁忙，如需留言请点击按钮进入表单留言"];
    [queueAlert addCloseActionWithTitle:@"取消" Handler:NULL];
    [queueAlert addAction:[UDAlertAction actionWithTitle:ticketButtonTitle handler:^(UDAlertAction * _Nonnull action) {
        
        if ([self.delegate respondsToSelector:@selector(clickSendOffLineTicket)]) {
            [self.delegate clickSendOffLineTicket];
        }
    }]];
    
    [queueAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    
}

//非法创建用户Alert
- (void)notCustomer {
    
    UDAlertController *notCustomerAlert = [UDAlertController alertWithTitle:nil message:_viewModel.agentModel.message];
    [notCustomerAlert addCloseActionWithTitle:@"确定" Handler:NULL];
    [notCustomerAlert showWithSender:nil controller:nil animated:YES completion:NULL];
    
}

//客服不在线Alert
- (void)agentNotOnline {
    
    NSString *title = NSLocalizedString(@"客服不在线",@"");
    NSString *message = NSLocalizedString(@"您可以选择提交表单来描述您的问题，稍后我们会和您联系。",@"");
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", @"");
    NSString *ticketButtonTitle = NSLocalizedString(@"留言",@"");
    
    UDAlertController *leaveOrTicket = [UDAlertController alertWithTitle:title message:message];
    [leaveOrTicket addCloseActionWithTitle:cancelButtonTitle Handler:NULL];
    
    [leaveOrTicket addAction:[UDAlertAction actionWithTitle:ticketButtonTitle handler:^(UDAlertAction * _Nonnull action) {
        
        if ([self.delegate respondsToSelector:@selector(clickSendOffLineTicket)]) {
            [self.delegate clickSendOffLineTicket];
        }
    }]];
    
    [leaveOrTicket showWithSender:nil controller:nil animated:YES completion:NULL];
    
}

//无网络Alert
- (void)netWorkDisconnectAlertView {
    
    UDAlertController *leaveOrTicket = [UDAlertController alertWithTitle:nil message:@"网络断开连接，请先连接网络"];
    [leaveOrTicket addCloseActionWithTitle:@"确定" Handler:NULL];
    [leaveOrTicket showWithSender:nil controller:nil animated:YES completion:NULL];
}

#pragma mark - db消息
- (void)viewModelWithDatabase:(NSMutableArray *)messageArray {

    self.messageArray = messageArray;
    
    [self reloadChatTableView];
}

#pragma mark - 更多消息
- (void)viewModelWithMoreMessage:(NSMutableArray *)messageArray {

    for (int i = 0; i<messageArray.count; i++) {
        
        [self.messageArray insertObject:messageArray[i] atIndex:0];
    }
    
}

#pragma mark - 点击功能栏弹出相应Alert
- (void)clickInputView {

    if (self.viewModel.agentModel.code == 2002) {
        
        [self agentNotOnline];
    } else if (self.viewModel.agentModel.code == 2003) {
        
        [self netWorkDisconnectAlertView];
    } else if (self.viewModel.agentModel.code == 2001) {
        [self queueStatus];
    } else if (self.viewModel.agentModel.code == 2004) {
    
        [self notCustomer];
    }

}

#pragma mark - 刷新Tableview
- (void)reloadChatTableView {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(reloadChatTableView)]) {
            [self.delegate reloadChatTableView];
        }
    }
}
#pragma mark - 点击功能栏弹出对应的模块
- (void)layoutOtherMenuViewHiden:(BOOL)hide
                        ViewType:(UDInputViewType)viewType
                        chatView:(UIView *)chatView
                       tabelView:(UDMessageTableView *)tableview
                       inputView:(UDMessageInputView *)inputView
                     emotionView:(UDEmotionManagerView *)emotionView
                      completion:(void(^)(BOOL finished))completion {

    [inputView.inputTextView resignFirstResponder];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = inputView.frame;
        __block CGRect otherMenuViewFrame;
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(chatView.bounds) - CGRectGetHeight(inputViewFrame)) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
            inputView.frame = inputViewFrame;
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = emotionView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(chatView.frame) : (CGRectGetHeight(chatView.frame) - CGRectGetHeight(otherMenuViewFrame)));
            emotionView.alpha = !hide;
            emotionView.frame = otherMenuViewFrame;
            
        };
        
        if (hide) {
            switch (viewType) {
                case UDInputViewTypeEmotion: {
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        } else {
            
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
            switch (viewType) {
                case UDInputViewTypeEmotion: {
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case UDInputViewTypeShareMenu: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);
        
        [tableview setTableViewInsetsWithBottomValue:chatView.frame.size.height
         - inputView.frame.origin.y];
        
        [tableview scrollToBottomAnimated:NO];
        
    } completion:^(BOOL finished) {
        
        if (completion) {
            completion(finished);
        }
    }];
    
}

#pragma mark - 是否显示时间轴Label
- (BOOL)shouldDisplayTimeForRowAtIndexPath:(NSIndexPath *)indexPath{

    UDMessage* message=[self.messageArray objectAtIndexCheck:indexPath.row];
    
    if(indexPath.row==0 || indexPath.row>=self.messageArray.count){
        return YES;
    }  else{
        
        UDMessage *previousMessage=[self.messageArray objectAtIndex:indexPath.row-1];
        NSInteger interval=[message.timestamp timeIntervalSinceDate:previousMessage.timestamp];
        if(interval>60*3){
            return YES;
        }else{
            return NO;
        }
    }
}

#pragma mark - 重发失败的消息
- (void)resendFailedMessage:(void(^)(UDMessage *failedMessage,BOOL sendStatus))completion {
    
    //第一种 每一秒执行一次（重复性）
    double delayInSeconds = 5;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        
        //重新发送
        [self resendFailedMessage:^(UDMessage *failedMessage, BOOL sendStatus) {
            
            if (completion) {
                completion(failedMessage,sendStatus);
            }
        }];
        
    });
    dispatch_resume(timer);
    
    
}

- (void)sendFailedMessage:(void(^)(UDMessage *failedMessage,BOOL sendStatus))completion {
    
    if (self.failedMessageArray.count==0) {
        
        timer = nil;
        
        return;
    }

    [self.failedMessageArray ud_each:^(UDMessage *resendMessage) {
        
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
        
    }];
}

@end
