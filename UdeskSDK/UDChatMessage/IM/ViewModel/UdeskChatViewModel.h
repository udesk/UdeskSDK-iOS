//
//  UdeskChatViewModel.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/19.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskMessageTextView.h"

@class UdeskAgentHttpData;
@class UdeskMessageTableView;
@class UdeskMessageInputView;
@class UdeskEmotionManagerView;
@class UdeskAgentModel;
@class UdeskMessage;


@interface UdeskChatViewModel : NSObject

@property (nonatomic, strong,readonly) NSMutableArray  *messageArray;//消息数据

@property (nonatomic, strong,readonly) NSMutableArray  *failedMessageArray;//发送失败的消息

@property (nonatomic, strong         ) UdeskAgentModel *agentModel;//客服Model

@property (nonatomic, assign         ) NSInteger       message_total_pages;//消息条数总数

@property (nonatomic, assign         ) NSInteger       message_count;//消息条数总数

@property (nonatomic, copy           ) void(^updateMessageContentBlock)();//消息内容更新

@property (nonatomic, copy           ) void(^fetchAgentDataBlock)(UdeskAgentModel *agentModel);//接收客服数据

@property (nonatomic, copy           ) void(^clickSendOffLineTicket)();//点击发送表单


- (instancetype)initWithAgentId:(NSString *)agent_id withGroupId:(NSString *)group_id;

/**
 *  发送文本消息
 *
 *  @param text       文本
 *  @param completion 发送状态&发送消息体
 */
- (void)sendTextMessage:(NSString *)text
                    completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion;

/**
 *  发送图片消息
 *
 *  @param image      图片
 *  @param completion 发送状态&发送消息体
 */
- (void)sendImageMessage:(UIImage *)image
              completion:(void(^)(UdeskMessage *message,BOOL sendStatus))completion;

/**
 *  发送语音消息
 *
 *  @param audioPath     语音文件地址
 *  @param audioDuration 语音时长
 *  @param comletion     发送状态&发送消息体
 */
- (void)sendAudioMessage:(NSString *)audioPath
           audioDuration:(NSString *)audioDuration
             completion:(void(^)(UdeskMessage *message,BOOL sendStatus))comletion;


//加载更多DB消息
- (void)pullMoreDateBaseMessage;

//取消轮询排队时候的客服接口
- (void)cancelPollingAgent;

/**
 *  点击底部功能栏坐相应操作
 */
- (void)clickInputViewShowAlertView;

/**
 *  重发失败的消息
 *
 *  @param message    失败的消息
 *  @param completion 发送回调
 */
- (void)resendFailedMessage:(void(^)(UdeskMessage *failedMessage,BOOL sendStatus))completion;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (UdeskMessage *)objectAtIndexPath:(NSInteger)row;

- (void)saveProductMessage:(UdeskMessage *)message;
- (void)requestQueue;

@end
