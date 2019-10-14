//
//  UdeskAgent.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/10.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    UDAgentStatusResultOnline       = 2000,//客服在线
    UDAgentStatusResultQueue        = 2001,//客服繁忙
    UDAgentStatusResultOffline      = 2002,//客服离线
    UDAgentStatusResultNoExist      = 5050,//客服不存在
    UDAgentGroupStatusResultNoExist = 5060,//客服组不存在
    UDAgentStatusResultUnKnown      = 4444,//其他错误
} UDAgentStatusType;

typedef enum : NSUInteger {
    UDAgentLeaveMessageTypeLeave = 3001,//直接留言
    UDAgentLeaveMessageTypeBoard = 3002,//工作台留言
    UDAgentLeaveMessageTypeForm  = 3003,//表单留言
    UDAgentLeaveMessageTypeClose = 3004,//留言未开启
} UDAgentLeaveMessageType;

typedef enum : NSUInteger {
    UDAgentSessionTypeInSession = 4001,//在会话中
    UDAgentSessionTypeNotCreate = 4002,//会话没创建
    UDAgentSessionTypeHasOver = 4003,//会话已关闭
} UDAgentSessionType;

@interface UdeskAgent : NSObject

/** 客服ID */
@property (nonatomic, strong) NSString          *agentId;
/** 客服名字 */
@property (nonatomic, strong) NSString          *nick;
/** 客服JID */
@property (nonatomic, strong) NSString          *jid;
/** 客服状态消息 */
@property (nonatomic, strong) NSString          *message;
/** 客服头像URL */
@property (nonatomic, strong) NSString          *avatar;
/** 会话ID（不需要传这个参数)  */
@property (nonatomic, assign) NSInteger         imSubSessionId;
/** 客服状态 */
@property (nonatomic, assign) UDAgentStatusType statusType;
/** 留言类型 */
@property (nonatomic, assign) UDAgentLeaveMessageType leaveMessageType;
/** 会话类型 */
@property (nonatomic, assign) UDAgentSessionType sessionType;

/**
 *  JSON数据转换成UdeskAgent
 *
 *  @param json 客服json数据
 */
- (instancetype)initModelWithJSON:(id)json;

@end
