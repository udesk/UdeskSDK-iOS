//
//  UdeskChatViewModel.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/19.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UdeskCallManager.h"
#import "UdeskNetworkManager.h"
#import "UdeskMessageManager.h"
#import "UdeskAgentManager.h"

@class UdeskMessage;
@class UdeskAgent;
@class UdeskSetting;
@class UdeskLocationModel;
@class UdeskGoodsModel;

@protocol UdeskChatViewModelDelegate <NSObject>

/** 通知viewController更新tableView； */
- (void)reloadChatTableView;
- (void)reloadMoreMessageChatTableView;
/** 更新tableView某个cell */
- (void)didUpdateCellModelWithIndexPath:(NSIndexPath *)indexPath;

/** 接收到客服 */
- (void)didUpdateAgentModel:(UdeskAgent *)agent;
/** 接受客服状态 */
- (void)didUpdateAgentPresence:(UdeskAgent *)agent;
/** 收到邀请评价 */
- (void)didReceiveSurveyWithAgentId:(NSString *)agentId;

/** 展示机器人会话 */
- (void)showRobotSessionWithName:(NSString *)name;
/** 展示无消息会话 */
- (void)showPreSessionWithTitle:(NSString *)title;
/** 客户在黑名单 */
- (void)customerOnTheBlacklist:(NSString *)message;
/** 收到自动转人工 */
- (void)didReceiveAutoTransferAgentServer;
/** 显示转人工按钮 */
- (void)showTransferButton;
/** 更新标题 */
- (void)updateChatTitleWithText:(NSString *)text;

/** 网络断开连接 */
- (void)didReceiveNetworkDisconnect;

@end

@interface UdeskChatViewModel : NSObject

/** 是否需要显示下拉加载 */
@property (nonatomic, assign) BOOL isShowRefresh;
/** ViewModel代理 */
@property (nonatomic, weak  ) id <UdeskChatViewModelDelegate> delegate;

/** 消息数据 */
@property (nonatomic, strong, readonly) NSArray *messagesArray;
/** 无消息会话ID */
@property (nonatomic, strong, readonly) NSNumber *preSessionId;

/** 视频通话管理类 */
@property (nonatomic, strong) UdeskCallManager *callManager;
/** 网络管理类 */
@property (nonatomic, strong) UdeskNetworkManager *networkManager;
/** 消息管理类 */
@property (nonatomic, strong) UdeskMessageManager *messageManager;
/** 客服管理类 */
@property (nonatomic, strong) UdeskAgentManager *agentManager;

- (instancetype)initWithSDKSetting:(UdeskSetting *)sdkSetting delegate:(id)delegate;

/** 加载更多DB消息 */
- (void)fetchNextPageMessages;
/** 转人工 */
- (void)transferToAgentServer;

/** 发送机器人消息 */
- (void)sendRobotMessage:(UdeskMessage *)message completion:(void(^)(UdeskMessage *message))completion;
/** 发送文本消息 */
- (void)sendTextMessage:(NSString *)text completion:(void(^)(UdeskMessage *message))completion;
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
/** 发送事件消息 */
- (void)sendChatEventMessage:(NSString *)text completion:(void(^)(UdeskMessage *message))completion;
/** 添加需要重新发送消息 */
- (void)addResendMessageToArray:(UdeskMessage *)message;
/** 移除发送失败的消息 */
- (void)removeResendMessageInArray:(UdeskMessage *)message;
/** 自动重发失败的消息 */
- (void)autoResendFailedMessageWithProgress:(void(^)(float percent))progress completion:(void(^)(UdeskMessage *failedMessage))completion;
/** 重发失败的消息 */
- (void)resendMessageWithMessage:(UdeskMessage *)resendMessage progress:(void(^)(float percent))progress completion:(void(^)(UdeskMessage *message))completion;

/** 显示提示框 */
- (void)showSDKAlert;
/** 留言 */
- (void)leaveMessageTapAction;

//开始视频通话
- (void)startUdeskVideoCall;

@end
