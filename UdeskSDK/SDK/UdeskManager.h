//
//  UdeskManager.h
//  UdeskSDK
//
//  Version: 3.3.1
//  Created by xuchen on 16/1/12.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskMessage.h"
#import "UdeskAgent.h"

/**
 *  Udesk客服系统当前有新消息，开发者可实现该协议方法，通过此方法显示小红点未读标识
 */
#define UD_RECEIVED_NEW_MESSAGES_NOTIFICATION @"UD_RECEIVED_NEW_MESSAGES_NOTIFICATION"

@protocol UDManagerDelegate <NSObject>

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
 *  @param isSurvey 是否调查满意度
 */
- (void)didReceiveSurveyWithAgentId:(NSString *)agentId;

@end

@interface UdeskManager : NSObject

/**
 *  初始化Udesk，必须调用此函数，请正确填写参数。
 *
 *  @param key    公司密钥
 *  @param domain 公司域名
 */
+ (void)initWithAppkey:(NSString *)key domianName:(NSString *)domain;
/**
 *  创建用户，必须调用此函数，请正确填写参数
 *
 *  @param customerInfo 用户信息
 */
+ (void)createCustomerWithCustomerInfo:(NSDictionary *)customerInfo;
/**
 *  更新用户信息
 *
 *  @param customerInfo 参数跟创建用户信息的结构体一样(不需要传sdk_token)
 *  @warning 用户自定义字段"customer_field"改为"custom_fields"其他不变
 *  @warning 请不要使用已经存在的邮箱或者手机号进行更新，否则会更新失败！
 */
+ (void)updateUserInformation:(NSDictionary *)customerInfo;

/**
 *  获取后台分配的客服信息
 *
 *  @param completion 回调客服信息
 */
+ (void)requestRandomAgent:(void (^)(UdeskAgent *agent, NSError *error))completion;
/**
 *  指定分配客服
 *
 *  @param agentId    客服id
 *  @param completion 完成之后回调
 */
+ (void)scheduledAgentId:(NSString *)agentId
              completion:(void (^) (UdeskAgent *agent, NSError *error))completion;
/**
 *  指定分配客服组
 *
 *  @param agentId    客服组id
 *  @param completion 完成之后回调
 */
+ (void)scheduledGroupId:(NSString *)groupId
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
 *  将 SDK 本地数据库中的消息都删除
 */
+ (void)removeAllMessagesFromDatabaseWithCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  接收消息代理
 *
 *  @param receiveDelegate 接收消息和接收状态代理
 *  @warning 需要在登陆成功后调用才有效
 */
+ (void)receiveUdeskDelegate:(id<UDManagerDelegate>)receiveDelegate;

/**
 *  退出Udesk (切换用户，需要调用此接口)
 */
+ (void)logoutUdesk;

/**
 *  设置客户在线 (用户点击app进入页面时调用此方法)
 */
+ (void)setCustomerOnline;

/**
 *  发送消息
 *
 *  @param message    UDMessage类型消息体
 *  @param completion 发送回调
 */
+ (void)sendMessage:(UdeskMessage *)message
         completion:(void (^) (UdeskMessage *message,BOOL sendStatus))completion;

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
 *  获取机器人URL
 *
 *  @return 机器人URL
 */
+ (NSURL *)getRobotURL;

/**
 *  异步获取
 *
 *  @param completion 回调机器人URL
 */
+ (void)getRobotURL:(void(^)(NSURL *robotUrl))completion;

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
 *  机器人客服是否支持转移
 *
 *  @return 是否支持转移
 */
+ (BOOL)supportTransfer;

/**
 * 当前用户是否被加入黑名单
 *  @warning 需要先调用创建用户接口
 */
+ (BOOL)isBlacklisted;

/**
 *  获取sdk版本
 *
 *  @return sdk版本
 */
+ (NSString *)udeskSDKVersion;

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
 *  获取后台配置的导航菜单
 *
 *  @param completion 回调结果
 */
+ (void)getAgentNavigationMenu:(void (^)(id responseObject, NSError *error))completion;

/**
 *  取消所有网络操作
 */
+ (void)ud_cancelAllOperations;

/**
 *  异步获取缓存里的聊天图片数据
 *
 *  @param key       图片消息id
 *  @param doneBlock 回调
 *
 *  @return NSOperation
 */
+ (void)downloadMediaWithUrlString:(NSString *)key done:(void(^)(NSString *key, id<NSCoding> object))doneBlock;

/**
 *  清除所有Udesk的多媒体缓存
 */
+ (void)removeAllUdeskDataWithCompletion:(void (^)())completion;

/**
 转换 emoji 别名为 Unicode
 */
+ (NSString *)convertToUnicodeWithEmojiAlias:(NSString *)text;

/**
 *  在服务端创建用户。（开发者无需调用此函数）
 *
 *  @param completion 成功信息回调
 *  @param failure    失败信息回调
 */
+ (void)createServerCustomerCompletion:(void (^)(BOOL success, NSError *error))completion;

@end
