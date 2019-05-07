//
//  UdeskAgentManager.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/18.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UdeskAgent;
@class UdeskMessage;
@class UdeskSetting;

@interface UdeskAgentManager : NSObject

/** 更新客服信息 */
@property (nonatomic, copy) void(^didUpdateAgentBlock)(UdeskAgent *agent);
/** 更新客服状态信息 */
@property (nonatomic, copy) void(^didUpdateAgentPresenceBlock)(UdeskAgent *agent);
/** 更新排队消息 */
@property (nonatomic, copy) void(^didUpdateQueueMessageBlock)(NSString *contentText);
/** 移除排队消息 */
@property (nonatomic, copy) void(^didRemoveQueueMessageBlock)(void);
/** 添加直接留言引导语消息 */
@property (nonatomic, copy) void(^didAddLeaveMessageGuideBlock)(void);

/** 无消息会话ID */
@property (nonatomic, strong) NSNumber *preSessionId;
/** 网络断开 */
@property (nonatomic, assign) BOOL      networkDisconnect;
/** 客服信息 */
@property (nonatomic, strong, readonly) UdeskAgent *agentModel;

- (instancetype)initWithSetting:(UdeskSetting *)setting;

- (void)fetchAgent:(void(^)(UdeskAgent *agentModel))completion;
- (void)fetchAgentWithPreSessionMessage:(UdeskMessage *)preSessionMessage completion:(void(^)(UdeskAgent *agentModel))completion;

//客服组ID
+ (NSString *)udGroupId;
//客服ID
+ (NSString *)udAgentId;

//根据客服code展示alert
- (void)showAlert;
//点击留言
- (void)leaveMessageTapAction;
//收到转接
- (void)receiveRedirect:(UdeskAgent *)agent;
//收到状态
- (void)receivePresence:(NSDictionary *)presence;

@end
