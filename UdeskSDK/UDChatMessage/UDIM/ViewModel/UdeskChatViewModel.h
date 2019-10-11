//
//  UdeskChatViewModel.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/19.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UdeskMessage;
@class UdeskAgent;
@class UdeskSetting;
@class UdeskLocationModel;
@class UdeskGoodsModel;

@protocol UdeskChatViewModelDelegate <NSObject>

/** 通知viewController更新tableView； */
- (void)reloadChatTableView;
/** 更新tableView某个cell */
- (void)didUpdateCellModelWithIndexPath:(NSIndexPath *)indexPath;

/** 接收到客服 */
- (void)didFetchAgentModel:(UdeskAgent *)agent;
/** 接受客服状态 */
- (void)didReceiveAgentPresence:(UdeskAgent *)agent;
/** 收到邀请评价 */
- (void)didReceiveSurveyWithAgentId:(NSString *)agentId;

/** 展示无消息会话 */
- (void)showPreSessionWithTitle:(NSString *)title;

/** 点击了发送表单 */
- (void)didSelectSendTicket;
/** 点击了黑名单提示框确定 */
- (void)didSelectBlacklistedAlertViewOkButton;

//Udesk Call
/** 收到邀请视频 */
- (void)didReceiveInviteWithAgentModel:(UdeskAgent *)agent;

@end

@interface UdeskChatViewModel : NSObject

/** 是否需要显示下拉加载 */
@property (nonatomic, assign) BOOL isShowRefresh;
/** 不显示alertview */
@property (nonatomic, assign) BOOL isNotShowAlert;
/** ViewModel代理 */
@property (nonatomic, weak  ) id <UdeskChatViewModelDelegate> delegate;

/** 消息数据 */
@property (nonatomic, strong, readonly) NSArray *messagesArray;
/** 无消息会话ID */
@property (nonatomic, strong, readonly) NSNumber *preSessionId;

- (instancetype)initWithSDKSetting:(UdeskSetting *)sdkSetting;

/** 加载更多DB消息 */
- (void)fetchNextPageDatebaseMessage;
/** 点击底部功能栏坐相应操作 */
- (void)clickInputViewShowAlertView;

/** 发送文本消息 */
- (void)sendTextMessage:(NSString *)text
             completion:(void(^)(UdeskMessage *message))completion;
/** 发送图片消息 */
- (void)sendImageMessage:(UIImage *)image progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion;
/** 发送gif图片消息 */
- (void)sendGIFImageMessage:(NSData *)gifData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion;
/** 发送视频消息 */
- (void)sendVideoMessage:(NSData *)videoData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion ;
/** 发送语音消息 */
- (void)sendVoiceMessage:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration completion:(void (^)(UdeskMessage *message))completion;
/** 发送地理位置消息 */
- (void)sendLocationMessage:(UdeskLocationModel *)model completion:(void(^)(UdeskMessage *message))completion;
/** 发送商品消息 */
- (void)sendGoodsMessage:(UdeskGoodsModel *)model completion:(void(^)(UdeskMessage *message))completion;
/** 添加需要重新发送消息 */
- (void)addResendMessageToArray:(UdeskMessage *)message;
/** 移除发送失败的消息 */
- (void)removeResendMessageInArray:(UdeskMessage *)message;
/** 自动重发失败的消息 */
- (void)autoResendFailedMessageWithProgress:(void(^)(NSString *messageId,float percent))progress completion:(void(^)(UdeskMessage *failedMessage))completion;
/** 重发失败的消息 */
- (void)resendMessageWithMessage:(UdeskMessage *)resendMessage progress:(void(^)(float percent))progress completion:(void(^)(UdeskMessage *message))completion;
/** 留言 */
- (void)clickLeaveMsgAlertButtonAction;

//根据客服code展示alertview
- (void)showAgentStatusAlert;

//Udesk Call

#if __has_include(<UdeskCall/UdeskCall.h>)
//关闭视频铃声
- (void)stopPlayVideoCallRing;
#endif

@end
