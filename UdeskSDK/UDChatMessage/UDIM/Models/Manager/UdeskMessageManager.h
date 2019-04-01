//
//  UdeskMessageManager.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/18.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class UdeskSetting;
@class UdeskAgent;
@class UdeskMessage;
@class UdeskLocationModel;
@class UdeskGoodsModel;

@interface UdeskMessageManager : NSObject

/** 更新消息 */
@property (nonatomic, copy) void(^didUpdateMessagesBlock)(NSArray *messages);
/** 更新单个消息 */
@property (nonatomic, copy) void(^didUpdateMessageAtIndexPathBlock)(NSIndexPath *indexPath);

/** 是否需要显示下拉加载 */
@property (nonatomic, assign) BOOL isShowRefresh;
/** 客服信息 */
@property (nonatomic, strong) UdeskAgent *agentModel;
/** sdk配置项 */
@property (nonatomic, strong) UdeskSetting *sdkSetting;
/** 消息数据 */
@property (nonatomic, strong, readonly) NSArray *messagesArray;
/** 机器人会话 */
@property (nonatomic, assign) BOOL isRobotSession;

- (instancetype)initWithSetting:(UdeskSetting *)setting;

//获取db消息
- (void)fetchMessages;
//加载更多DB消息
- (void)fetchNextPageMessages;
//获取servers消息
- (void)fetchServersMessages;
//添加直接留言文案
- (void)addLeaveGuideMessageToArray;
//更新排队事件
- (void)updateQueue:(NSString *)contentText;
//移除排队事件
- (void)removeQueueInArray;
//添加消息到数组
- (void)addMessageToArray:(NSArray *)messageArray;
//收到撤回消息
- (void)receiveRollbackWithMessageId:(NSString *)messageId rollbackAgentNick:(NSString *)rollbackAgentNick;

/* 发送消息 */

- (void)sendRobotMessage:(UdeskMessage *)message completion:(void(^)(UdeskMessage *message))completion;
//发送文本消息
- (void)sendTextMessage:(NSString *)text completion:(void(^)(UdeskMessage *message))completion;
//发送图片消息
- (void)sendImageMessage:(UIImage *)image progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion;
//发送gif图片消息
- (void)sendGIFImageMessage:(NSData *)gifData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion;
//发送视频消息
- (void)sendVideoMessage:(NSData *)videoData progress:(void(^)(NSString *key,float percent))progress completion:(void(^)(UdeskMessage *message))completion ;
//发送语音消息
- (void)sendVoiceMessage:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration completion:(void (^)(UdeskMessage *message))completion;
//发送地理位置消息
- (void)sendLocationMessage:(UdeskLocationModel *)model completion:(void(^)(UdeskMessage *message))completion;
//发送商品消息
- (void)sendGoodsMessage:(UdeskGoodsModel *)model completion:(void(^)(UdeskMessage *message))completion;

//获取GIF Message
- (UdeskMessage *)gifMessageWithData:(NSData *)gifData;
- (UdeskMessage *)videoMessageWithVideoData:(NSData *)videoData;
- (UdeskMessage *)voiceMessageWithPath:(NSString *)voicePath duration:(NSString *)duration;
- (UdeskMessage *)locationMessageWithModel:(UdeskLocationModel *)locationModel;

@end
