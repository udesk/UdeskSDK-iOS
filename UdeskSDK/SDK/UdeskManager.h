//
//  UdeskManager.h
//  UdeskSDK
//
//  Version: 4.3.1
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
 *  接收离线工单回复
 *
 */
- (void)didReceiveTicketReply;
/**
 接收撤回消息

 @param messageId 撤回的消息ID
 */
- (void)didReceiveRollback:(NSString *)messageId agentNick:(NSString *)agentNick;

/**
 需要重新拉取消息
 */
- (void)fetchSessionMessages:(NSString *)sessionId;

/**
 请求客服信息，创建会话
 */
- (void)fetchAgentAgainCreateSession;

@end


@interface UdeskManager : NSObject

/**
 初始化Udesk
 @param organization 公司model
 @param customer 客户model

 */
+ (void)initWithOrganization:(UdeskOrganization *)organization
                    customer:(UdeskCustomer *)customer;

/**
    更新客户信息

 *  @param customer 客户model
 *  @param completion 回调信息
 */
+ (void)updateCustomer:(UdeskCustomer *)customer completion:(void(^)(NSError *error))completion;

/**
 *  获取后台分配的客服信息
 *
 *  @param preSessionId 无消息会话Id
 *  @param preSessionMessage 无消息会话消息
 *  @param completion 回调客服信息
 */
+ (void)requestRandomAgentWithPreSessionId:(NSNumber *)preSessionId
                         preSessionMessage:(UdeskMessage *)preSessionMessage
                                completion:(void(^)(UdeskAgent *agentModel,NSError *error))completion;
/**
 *  指定分配客服
 *
 *  @param agentId    客服id
 *  @param preSessionId 无消息会话Id
 *  @param preSessionMessage 无消息会话消息
 *  @param completion 完成之后回调
 */
+ (void)scheduledAgentId:(NSString *)agentId
            preSessionId:(NSNumber *)preSessionId
       preSessionMessage:(UdeskMessage *)preSessionMessage
              completion:(void (^) (UdeskAgent *agent, NSError *error))completion;
/**
 *  指定分配客服组
 *
 *  @param groupId    客服组id
 *  @param preSessionId 无消息会话Id
 *  @param preSessionMessage 无消息会话消息
 *  @param completion 完成之后回调
 */
+ (void)scheduledGroupId:(NSString *)groupId
            preSessionId:(NSNumber *)preSessionId
       preSessionMessage:(UdeskMessage *)preSessionMessage
              completion:(void (^) (UdeskAgent *agent, NSError *error))completion;
/**
 * 根据时间从本地数据库获取历史消息
 *
 * @param messageDate        获取该日期之前的历史消息;
 * @param messagesNumber     获取消息的数量
 * @param result             回调中，messagesArray:消息数组
 */
+ (void)getHistoryMessagesFromDatabaseWithMessageDate:(NSDate *)messageDate
                                       messagesNumber:(NSInteger)messagesNumber
                                               result:(void (^)(NSArray *messagesArray))result;
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
+ (void)enterTheSDKPage;
/**
 *  发送消息
 *
 *  @param message    UDMessage类型消息体
 *  @param completion 发送回调
 */
+ (void)sendMessage:(UdeskMessage *)message
           progress:(void(^)(float percent))progress
         completion:(void(^)(UdeskMessage *message))completion;

/**
 * 将用户正在输入的内容，提供给客服查看。该接口没有调用限制，但每1秒内只会向服务器发送一次数据
 * @param content 提供给客服看到的内容
 * @warning 需要在初始化成功后，且客服是在线状态时调用才有效
 */
+ (void)sendClientInputtingWithContent:(NSString *)content;

/**
 *  获取用户自定义字段
 *
 *  @param completion 回调用户自定义子段信息
 */
+ (void)getCustomerFields:(void (^)(id responseObject, NSError *error))completion;
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
+ (void)getFaqArticlesContent:(NSString *)contentId
                   completion:(void (^)(id responseObject, NSError *error))completion;

/**
 *  搜索帮助中心文章
 *
 *  @param content    搜索内容
 *  @param completion 回调搜索信息
 */
+ (void)searchFaqArticles:(NSString *)content
               completion:(void (^)(id responseObject, NSError *error))completion;

/**
 *  获取提交工单URL
 *
 *  @return 提交工单URL
 */
+ (NSURL *)getSubmitTicketURL;

/**
 * 获取后台配置的机器人URL (开发者不需要调用此接口)
 */
+ (NSURL *)getServerRobotURLWithBaseURL:(NSString *)url;

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
 * 当前用户是否被加入黑名单
 *  @warning 需要先调用创建用户接口
 */
+ (BOOL)isBlacklisted;

/**
 *  获取满意度调查选项
 *
 *  @param completion 回调选项内容
 */
+ (void)getSurveyOptions:(void (^)(id responseObject, NSError *error))completion;

/**
 *  满意度调查投票
 *
 *  @param agentId    满意度调查的客服
 *  @param optionId   满意度选项ID
 *  @param completion 回调结果
 */
+ (void)survetVoteWithAgentId:(NSString *)agentId
                 withOptionId:(NSString *)optionId
                   completion:(void (^)(id responseObject, NSError *error))completion;

/**
 提交满意度调查

 @param parameters 需要的参数
 @param completion 回调结果
 */
+ (void)submitSurveyWithParameters:(NSDictionary *)parameters
                        completion:(void(^)(NSError *error))completion;

/**
 *  检查是否已经提交过满意度
 *
 *  @param agentId    满意度调查的客服
 *  @param completion 回调结果
 */
+ (void)checkHasSurveyWithAgentId:(NSString *)agentId
                       completion:(void (^)(NSString *hasSurvey,NSError *error))completion;

/**
 *  获取后台配置的导航菜单
 *
 *  @param completion 回调结果
 */
+ (void)getAgentNavigationMenu:(void (^)(id responseObject, NSError *error))completion;

/**
 *  取消所有网络操作
 */

+ (void)cancelAllOperations;

/**
 转换 emoji 别名为 Unicode
 */
+ (NSString *)convertToUnicodeWithEmojiAlias:(NSString *)text;

/**
 *  在服务端创建用户。（开发者无需调用此函数）
 *
 *  @param completion 成功信息回调
 *  @param preSessionEnbaleCallback 开启了无消息对话过滤
 */
+ (void)createServerCustomerCompletion:(void (^)(UdeskCustomer *customer, NSError *error))completion
              preSessionEnbaleCallback:(void(^)(UdeskCustomer *customer, NSString *preSessionTitle))preSessionEnbaleCallback;

/**
 在机器人页面创建用户

 @param completion 完成回调
 */
+ (void)createCustomerForRobot:(void (^)(NSError *error))completion;

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

/**
 客户是否正在会话

 @return yes/no
 */
+ (BOOL)customersAreSession;

/**
 获取后台sdk配置

 @param success 成功返回配置model
 @param failure 失败信息
 */
+ (void)getServerSDKSetting:(void(^)(UdeskSetting *setting))success
                    failure:(void(^)(NSError *error))failure;

/**
 放弃排队

 @param quiteType 放弃排队类型
 */
+ (void)quitQueueWithType:(NSString *)quiteType;

/**
 获取客服工单回复
 
 @param lastDate  最后一条消息的时间
 @param success 成功回调（dataSource的元素是UdeskMessage）
 @param failure 失败回调
 */
+ (void)fetchAgentTicketReply:(NSString *)lastDate
                      success:(void(^)(NSArray *dataSource,NSString *lastDate))success
                      failure:(void(^)(NSError *error))failure;

/**
 获取会话消息记录

 @param sessionId 会话ID
 @param completion 完成回调
 */
+ (void)fetchServersMessageWithSessionId:(NSString *)sessionId
                              completion:(void(^)(NSError *error, NSArray *msgList))completion;

/**
 无消息会话

 @param completion 完成回调
 */
+ (void)createPreSessionWithAgentId:(NSString *)agentId
                            groupId:(NSString *)groupId
                         completion:(void(^)(NSNumber *preSessionId,NSError *error))completion;

/**
 排队发送消息

 @param message 消息
 @param progress 进度
 @param completion 完成回调
 */
+ (void)sendQueueMessage:(UdeskMessage *)message
                progress:(void(^)(float percent))progress
              completion:(void (^)(UdeskMessage *message,NSString *resultMsg))completion;

@end
