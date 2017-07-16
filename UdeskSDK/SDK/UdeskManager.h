//
//  UdeskManager.h
//  UdeskSDK
//
//  Version: 3.7
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

typedef void (^UDUploadProgressHandler)(NSString *key, float percent);
typedef BOOL (^UDUploadCancellationSignal)(void);

// 排队放弃类型枚举
typedef NS_ENUM(NSUInteger, UDQuitQueueType) {
    /** 直接从排列中清除 */
    UdeskForceQuit,
    /** 标记放弃 */
    UdeskMark
};

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

@end


@interface UdeskManager : NSObject

/**
 创建用户，必须调用此函数，请正确填写参数
 @param organization 公司model
 @param customer 客户model

 */
+ (void)initWithOrganization:(UdeskOrganization *)organization
                    customer:(UdeskCustomer *)customer;

/**
 更新客户信息

 @param customer 客户model
 */
+ (void)updateCustomer:(UdeskCustomer *)customer;

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
 *  @param groupId    客服组id
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
 *  将所有未读消息设置为已读
 */
+ (void)markAllMessagesAsRead;

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
 * 获取后台配置的机器人URL
 */
+ (NSURL *)getServerRobotURLWithBaseURL:(NSString *)url;

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
 */
+ (void)createServerCustomerCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 在机器人页面创建用户

 @param completion 完成回调
 */
+ (void)createCustomerForRobot:(void (^)(BOOL success, NSError *error))completion;

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
+ (void)quitQueueWithType:(UDQuitQueueType)quiteType;

/**
 发送留言
 
 @param message 留言内容
 @param isShowEvent 是否显示事件
 @param completion 完成回调（发送成功error为nil）
 */
+ (void)sendLeaveMessage:(UdeskMessage *)message
             isShowEvent:(BOOL)isShowEvent
              completion:(void(^)(NSError *error,BOOL sendStatus))completion;


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
 发送视频信息

 @param messsage 视频信息
 @param progress 视频上传进度
 @param cancellationSignal 取消上传
 @param completion 完成回调
 */
+ (void)sendVideoMessage:(UdeskMessage *)messsage
               videoName:(NSString *)videoName
                progress:(UDUploadProgressHandler)progress
      cancellationSignal:(UDUploadCancellationSignal)cancellationSignal
              completion:(void (^) (UdeskMessage *message,BOOL sendStatus))completion;

@end
