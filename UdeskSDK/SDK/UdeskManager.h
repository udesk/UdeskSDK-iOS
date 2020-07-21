//
//  UdeskManager.h
//  UdeskSDK
//
//  Version: 5.1.5
//
//  Created by Udesk on 16/1/12.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskMessage.h"
#import "UdeskAgent.h"
#import "UdeskSetting.h"
#import "UdeskCustomer.h"
#import "UdeskOrganization.h"
#import "UdeskTrack.h"

/**
 *  Udesk客服系统当前有新消息，开发者可注册该通知接受未读消息，显示小红点未读标识
 */
#define UD_RECEIVED_NEW_MESSAGES_NOTIFICATION @"UD_RECEIVED_NEW_MESSAGES_NOTIFICATION"

@protocol UDManagerDelegate <NSObject>

@optional
/**
 *  接收消息代理
 *
 *  @param message 接收的消息
 */
- (void)didReceiveMessages:(UdeskMessage *)message;

/**
 *  接受转移
 *
 *  @param agent 转接之后的客服
 */
- (void)didReceiveRedirect:(UdeskAgent *)agent;

/**
 *  接收状态代理
 *
 *  @param presence 接收的状态
 */
- (void)didReceivePresence:(NSDictionary *)presence;
/**
 *  接收客服发送的满意度调查
 *
 *  @param agentId 是否调查满意度
 */
- (void)didReceiveSurveyWithAgentId:(NSString *)agentId;

/**
 需要重新拉取消息
 */
- (void)didReceiveRequestServersMessages;

/**
 请求配置信息
 */
- (void)didReceiveRequestServersSetting;

/**
 排队消息已到最大值
 */
- (void)queueMessageHasMaxed:(NSString *)alertText;

/**
 自动转人工
 */
- (void)didReceiveAutoTransferAgentServer;

/**
 请求客服信息
 */
- (void)didReceiveRequestServersAgent:(UdeskMessage *)message;

@end


@interface UdeskManager : NSObject

/**
 初始化Udesk
 @param organization 公司model
 @param customer 客户model

 */
+ (void)initWithOrganization:(UdeskOrganization *)organization customer:(UdeskCustomer *)customer;

/**
 SDK初始化
 
 @param success 回调sdk配置
 @param failure 错误回调
 */
+ (void)fetchSDKSetting:(void(^)(UdeskSetting *setting))success failure:(void(^)(NSError *error))failure;


/*-----------------客服-------------------*/


/**
 *  获取后台配置的导航菜单
 *
 *  @param completion 回调结果
 */
+ (void)fetchAgentMenu:(void(^)(id responseObject, NSError *error))completion;

/**
 *  获取后台分配的客服信息
 *
 *  @param preSessionId 无消息会话Id
 *  @param preSessionMessage 无消息会话消息
 *  @param completion 回调客服信息
 */
+ (void)fetchRandomAgentWithPreSessionId:(NSNumber *)preSessionId preSessionMessage:(UdeskMessage *)preSessionMessage completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion;

/**
 *  指定分配客服
 *
 *  @param agentId    客服id
 *  @param preSessionId 无消息会话Id
 *  @param preSessionMessage 无消息会话消息
 *  @param completion 完成之后回调
 */
+ (void)fetchAgentWithId:(NSString *)agentId preSessionId:(NSNumber *)preSessionId preSessionMessage:(UdeskMessage *)preSessionMessage completion:(void(^) (UdeskAgent *agent, NSError *error))completion;
/**
 *  指定分配客服组
 *
 *  @param groupId    客服组id
 *  @param preSessionId 无消息会话Id
 *  @param preSessionMessage 无消息会话消息
 *  @param completion 完成之后回调
 */
+ (void)fetchAgentWithGroupId:(NSString *)groupId preSessionId:(NSNumber *)preSessionId preSessionMessage:(UdeskMessage *)preSessionMessage completion:(void(^) (UdeskAgent *agent, NSError *error))completion;

/**
 指定分配客服组
 *
 *  @param menuId 客服组id
 *  @param preSessionId 无消息会话Id
 *  @param preSessionMessage 无消息会话消息
 *  @param completion 完成之后回调
 */
+ (void)fetchAgentWithMenuId:(NSString *)menuId preSessionId:(NSNumber *)preSessionId preSessionMessage:(UdeskMessage *)preSessionMessage completion:(void (^) (UdeskAgent *agent, NSError *error))completion;

/**
 无消息会话
 @param completion 完成回调
 */
+ (void)createPreSessionWithAgentId:(NSString *)agentId groupId:(NSString *)groupId completion:(void(^)(NSNumber *preSessionId,NSError *error))completion;


/*-----------------消息-------------------*/


/**
 * 根据时间从本地数据库获取历史消息
 *
 * @param messageDate        获取该日期之前的历史消息;
 * @param result             回调中，messagesArray:消息数组
 */
+ (void)fetchDatabaseMessagesWithDate:(NSDate *)messageDate result:(void (^)(NSArray *messagesArray,BOOL hasMore))result;

/**
 获取会话消息记录
 
 @param completion 完成回调
 */
+ (void)fetchServersMessage:(void(^)(NSArray *msgList,NSError *error))completion;

/**
 *  发送消息
 *
 *  @param message    UDMessage类型消息体
 *  @param completion 发送回调
 */
+ (void)sendMessage:(UdeskMessage *)message progress:(void(^)(float percent))progress completion:(void(^)(UdeskMessage *message))completion;

/**
 * 将用户正在输入的内容，提供给客服查看。该接口没有调用限制，但每1秒内只会向服务器发送一次数据
 * @param content 提供给客服看到的内容
 * @warning 需要在初始化成功后，且客服是在线状态时调用才有效
 */
+ (void)sendClientInputtingWithContent:(NSString *)content;

/**
 *  获取未读消息数量
 *
 *  @return 未读消息数量
 */
+ (NSInteger)getLocalUnreadeMessagesCount;

/**
 *  获取未读消息
 *
 *  @return 未读消息数组
 */
+ (NSArray *)getLocalUnreadeMessages;

/**
 *  将所有未读消息设置为已读
 */
+ (void)markAllMessagesAsRead;

/**
 *  将 SDK 本地数据库中的消息都删除
 */
+ (void)removeAllMessagesFromDatabase;

/**
 *  接收消息代理
 *
 *  @param receiveDelegate 接收消息和接收状态代理
 *  @warning 需要在登陆成功后调用才有效
 */
+ (void)receiveUdeskDelegate:(id<UDManagerDelegate>)receiveDelegate;


/*-----------------机器人-------------------*/

/**
 初始化机器人

 @param completion 结果回调
 */
+ (void)initRobot:(void(^)(NSString *robotName))completion;

/**
 机器人快速提示
 
 @param keyword 关键字
 @param completion 结果回调
 */
+ (void)fetchRobotTips:(NSString *)keyword completion:(void(^)(NSArray<UdeskMessage *> *result))completion;

/**
 机器人答案评价
 
 @param message 答案消息体
 @param completion 结果回调
 */
+ (void)answerSurvey:(UdeskMessage *)message completion:(void(^)(NSError *error))completion;

/**
 检查机器人满意度调查

 @param completion 结果回调
 */
+ (void)checkRobotSessionHasSurvey:(void(^)(BOOL hasSurvey,NSError *error))completion;

/**
 提交机器人满意度调查

 @param parameters 需要的参数
 @param completion 结果回调
 */
+ (void)submitRobotSurveyWithParameters:(NSDictionary *)parameters completion:(void(^)(NSError *error))completion;


/*-----------------满意度-------------------*/


/**
 *  获取满意度调查选项
 *
 *  @param completion 回调选项内容
 */
+ (void)getSurveyOptions:(void (^)(id responseObject, NSError *error))completion;

/**
 提交满意度调查

 @param parameters 需要的参数
 @param completion 回调结果
 */
+ (void)submitSurveyWithParameters:(NSDictionary *)parameters completion:(void(^)(NSError *error))completion;

/**
 *  检查是否已经提交过满意度
 *
 *  @param agentId    满意度调查的客服
 *  @param completion 回调结果
 */
+ (void)checkHasSurveyWithAgentId:(NSString *)agentId completion:(void(^)(BOOL hasSurvey,NSError *error))completion;


/*-----------------推送-------------------*/


/**
 开始推送
 */
+ (void)startUdeskPush;
/**
 结束推送
 */
+ (void)endUdeskPush;

/**
 设置用户的设备唯一标识
 */
+ (void)registerDeviceToken:(id)deviceToken;


/*-----------------电商-------------------*/


/**
 发送轨迹，此接口只有在“initWithOrganization:customer:”接口调用过之后才会生效，调用此接口请保证管理员后台开启了轨迹功能
 
 @param track 轨迹
 */
+ (void)sendTrack:(UdeskTrack *)track completion:(void(^)(BOOL result))completion;
/**
 发送订单，此接口只有在“initWithOrganization:customer:”接口调用过之后才生效，调用此接口请保证管理员后台开启了订单功能
 
 @param order 订单
 */
+ (void)sendOrder:(UdeskOrder *)order completion:(void(^)(BOOL result))completion;


/*-----------------帮助中心-------------------*/


/**
 *  获取公司帮助中心文章
 *
 *  @param completion 回调帮助中心文章信息
 */
+ (void)getFaqArticles:(void (^)(id responseObject, NSError *error))completion;

/**
 *  获取公司帮助中心文章内容
 *
 *  @param contentId  文章内容ID
 *  @param completion 回调文章内容信息
 */
+ (void)getFaqArticlesContent:(NSString *)contentId completion:(void (^)(id responseObject, NSError *error))completion;

/**
 *  搜索帮助中心文章
 *
 *  @param content    搜索内容
 *  @param completion 回调搜索信息
 */
+ (void)searchFaqArticles:(NSString *)content completion:(void (^)(id responseObject, NSError *error))completion;

/**
 *  设置离线
 */
+ (void)setupCustomerOffline;

/**
 *  设置客户在线
 */
+ (void)setupCustomerOnline;

/**
 退出
 */
+ (void)logoutUdesk;

/**
 用户进入sdk页面（开发者不需要调用）
 */
+ (void)enterSDKPage;

/**
 用户离开sdk页面（开发者不需要调用）
 */
+ (void)LeaveSDKPage;

/**
 *  获取提交工单URL
 *
 *  @return 提交工单URL
 */
+ (NSURL *)getSubmitTicketURL;

/**
 *  获取客服注册的Udesk域名
 *
 *  @return 域名
 */
+ (NSString *)domain;
/**
 *  获取用户Udesk key
 *
 *  @return Udesk key
 */
+ (NSString *)key;

/**
 获取用户Udesk App ID
 
 @return App ID
 */
+ (NSString *)appId;

/**
 获取用户JID
 
 @return customerJID
 */
+ (NSString *)customerJID;
/**
 放弃排队
 
 @param quiteType 放弃排队类型
 */
+ (void)quitQueueWithType:(NSString *)quiteType;

/**
 *  取消所有网络操作
 */

+ (void)cancelAllOperations;

/**
 URL签名

 @param url url
 @return url
 */
+ (NSURL *)udeskURLSignature:(NSString *)url;

@end
