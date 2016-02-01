//
//  UDManager.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/12.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDMessage.h"

#define MessageDB @"Message"

//DB-Create
#define CreateMessage [NSString stringWithFormat:@"CREATE TABLE %@ ('content' text,'replied_at' text,'msgid' text,'sendflag' text,'direction' text,'duration' text,'mesType' text,'width' text,'height' text)",MessageDB]

//DB-Insert
#define InsertTextMsg [NSString stringWithFormat:@"insert into %@ ('content','replied_at','msgid','sendflag','direction','mesType') values(?,?,?,?,?,?)",MessageDB]

#define InsertAudioMsg [NSString stringWithFormat:@"insert into %@ ('content','replied_at','msgid','sendflag','direction','mesType','duration') values(?,?,?,?,?,?,?)",MessageDB]

#define InsertPhotoMsg [NSString stringWithFormat:@"insert into %@ ('content','replied_at','msgid','sendflag','direction','mesType','width','height') values(?,?,?,?,?,?,?,?)",MessageDB]

//DBSelect
#define QueryMessage [NSString stringWithFormat:@"select *from %@",MessageDB]
//DBDelete
#define DeleteMessage [NSString stringWithFormat:@"delete *from %@",MessageDB]

//重发消息
#define ClickResendMessage                    @"ClickResendMessage"

//语音最大时长
#define kVoiceRecorderTotalTime 60.0

@protocol UDManagerDelegate <NSObject>

/**
 *  接收消息代理
 *
 *  @param message 接收的消息
 */
- (void)didReceiveMessages:(NSDictionary *)message;

/**
 *  接收状态代理
 *
 *  @param presence 接收的状态
 */
- (void)didReceivePresence:(NSDictionary *)presence;

@end

@interface UDManager : NSObject

/**
 *  初始化Udesk
 *
 *  @param key    公司密钥
 *  @param domain 公司域名
 */
+ (void)initWithAppkey:(NSString *)key domianName:(NSString *)domain;
/**
 *  创建用户
 *
 *  @param customerMsg 用户信息
 *  @param completion  创建成功回调（返回用户ID）
 */
+ (void)createCustomer:(NSDictionary *)customerMsg
            completion:(void (^)(NSString *customerId,NSError *error))completion;

/**
 *  获取用户的登录信息
 *
 *  @param completion 回调用户登录信息
 */
+ (void)getCustomerLoginInfo:(void (^)(NSDictionary *loginInfoDic,NSError *error))completion;

/**
 *  通过开发者存储的用户ID获取用户登录信息
 *
 *  @param customerId 用户ID
 *  @param completion 回调用户信息
 */
+ (void)getCustomerLoginInfo:(NSString *)customerId
                  completion:(void (^)(NSDictionary *loginInfoDic,NSError *error))completion;

/**
 *  获取客服信息
 *
 *  @param completion 回调客服信息
 */
+ (void)getAgentInformation:(void (^)(id responseObject,NSError *error))completion;

/**
 *  通过开发者存储的用户ID获取客服信息
 *
 *  @param customerId 用户ID
 *  @param completion 回调客服信息
 */
+ (void)getAgentInformation:(NSString *)customerId
                 completion:(void (^)(id responseObject,NSError *error))completion;

/**
 *  登录Udesk
 *
 *  @param userName        用户帐号
 *  @param password        用户密码
 *  @param completion      回调登录状态
 *  @param receiveDelegate 接收消息和接收状态代理
 */
+ (void)loginUdeskWithUserName:(NSString *)userName
                      password:(NSString *)password
                    completion:(void (^) (BOOL status))completion
               receiveDelegate:(id<UDManagerDelegate>)receiveDelegate;

/**
 *  登录Udesk
 *
 *  @param completion      回调登录状态
 *  @param receiveDelegate 接收消息和接收状态代理
 */
+ (void)loginUdesk:(void (^) (BOOL status))completion
   receiveDelegate:(id<UDManagerDelegate>)receiveDelegate;

/**
 *  退出Udesk
 */
+ (void)logoutUdesk;

/**
 *  发送消息
 *
 *  @param message    UDMessage类型消息体
 *  @param completion 发送回调
 */
+ (void)sendMessage:(UDMessage *)message
         completion:(void (^) (UDMessage *message,BOOL sendStatus))completion;

/**
 *  获取用户自定义字段
 *
 *  @param completion 回调用户自定义子段信息
 */
+ (void)getCustomerFields:(void (^)(id responseObject, NSError *error))completion;
/**
 *  提交用户设备信息
 *
 *  @param completion 回调提交状态
 */
+ (void)submitCustomerDevicesInfo:(void (^)(id responseObject, NSError *error))completion;

/**
 *  通过开发者存储的用户ID提交用户设备信息
 *
 *  @param customerId 用户ID
 *  @param completion 回调提交状态
 */
+ (void)submitCustomerDevicesInfo:(NSString *)customerId
                        completion:(void (^)(id responseObject, NSError *error))completion;

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
 *  插入信息到数据库
 *
 *  @param sql    sql语句
 *  @param params 参数
 *
 *  @return 插入状态
 */
+ (BOOL)insertTableWithSqlString:(NSString *)sql params:(NSArray *)params;

/**
 *  查询数据库
 *
 *  @param sql           sql语句
 *  @param params        参数
 *  @param finishedblock 回调查询内容
 */
+ (void)queryTabelWithSqlString:(NSString *)sql
                         params:(NSArray *)params
                  finishedBlock:(void (^) (NSArray *dbData))finishedblock;


/**
 *  删除数据库内容
 *
 *  @param sql    sql语句
 *  @param params 参数
 *
 *  @return 删除状态
 */
+ (BOOL)deleteTableWithSqlString:(NSString *)sql params:(NSArray *)params;

/**
 *  修改数据库内容
 *
 *  @param sql    sql语句
 *  @param params 参数
 *
 *  @return 修改状态
 */
+ (BOOL)updateTableWithSqlString:(NSString *)sql params:(NSArray *)params;

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

@end
