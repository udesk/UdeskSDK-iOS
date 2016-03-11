//
//  UDChatViewModel.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/19.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDMessageTextView.h"

@class UDAgentViewModel;
@class UDMessageTableView;
@class UDMessageInputView;
@class UDEmotionManagerView;
@class UDAgentModel;
@class UDMessage;

@protocol UDChatViewModelDelegate <NSObject>

/**
 *  刷新TableView
 */
- (void)reloadChatTableView;
/**
 *  回调客服状态
 *
 *  @param presence 客服状态
 */
- (void)receiveAgentPresence:(NSString *)presence;
/**
 *  点击发送离线表单
 */
- (void)clickSendOffLineTicket;
/**
 *  通知VC客户被转接
 *
 *  @param agentMsg 转接客服信息
 */
- (void)notificationRedirect:(UDAgentModel *)agentModel;

@end

@interface UDChatViewModel : NSObject

/**
 *  消息数据
 */
@property (nonatomic, strong) NSMutableArray *messageArray;

/**
 *  发送失败的消息
 */
@property (nonatomic, strong) NSMutableArray *failedMessageArray;

/**
 *  客服Model
 */
@property (nonatomic, strong) UDAgentModel        *agentModel;

@property (nonatomic, weak  ) id<UDChatViewModelDelegate> delegate;

/**
 *  发送文本消息
 *
 *  @param text       文本
 *  @param completion 发送状态&发送消息体
 */
- (void)sendTextMessage:(NSString *)text
                    completion:(void(^)(UDMessage *message,BOOL sendStatus))completion;

/**
 *  发送图片消息
 *
 *  @param image      图片
 *  @param completion 发送状态&发送消息体
 */
- (void)sendImageMessage:(UIImage *)image
              completion:(void(^)(UDMessage *message,BOOL sendStatus))completion;

/**
 *  发送语音消息
 *
 *  @param audioPath     语音文件地址
 *  @param audioDuration 语音时长
 *  @param comletion     发送状态&发送消息体
 */
- (void)sendAudioMessage:(NSString *)audioPath
           audioDuration:(NSString *)audioDuration
             completion:(void(^)(UDMessage *message,BOOL sendStatus))comletion;

/**
 *  登录Udesk
 *
 *  @param viewModel 客服model(根据客服状态去登录)
 */
- (void)loginUdeskWithAgent:(UDAgentModel *)agentModel;

/**
 *  DB消息
 *
 *  @param messageArray 消息数组
 */
- (void)viewModelWithDatabase:(NSArray *)messageArray;

/**
 *  加载更多消息（本地消息）
 *
 *  @param messageArray 更多消息数组
 */
- (void)viewModelWithMoreMessage:(NSArray *)messageArray;

/**
 *  点击底部功能栏坐相应操作
 */
- (void)clickInputView;
/**
 *  根据点击展示功能模块
 *
 *  @param hide        隐藏显示模块
 *  @param viewType    模块类型
 *  @param chatView    ChatView
 *  @param tableview   ChatTableView
 *  @param inputView   ChatInputView
 *  @param emotionView ChatEmotionView
 *  @param completion  动画回调
 */
- (void)layoutOtherMenuViewHiden:(BOOL)hide
                        ViewType:(UDInputViewType)viewType
                        chatView:(UIView *)chatView
                       tabelView:(UDMessageTableView *)tableview
                       inputView:(UDMessageInputView *)inputView
                     emotionView:(UDEmotionManagerView *)emotionView
                      completion:(void(^)(BOOL finished))completion;

/**
 *  是否显示时间轴Label
 *
 *  @param indexPath 目标消息的位置IndexPath
 *
 *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
 */
- (BOOL)shouldDisplayTimeForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  重发失败的消息
 *
 *  @param message    失败的消息
 *  @param completion 发送回调
 */
- (void)resendFailedMessage:(void(^)(UDMessage *failedMessage,BOOL sendStatus))completion;

@end
