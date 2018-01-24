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
    UDAgentStatusResultNotNetWork   = 2003,//无网络
    UDAgentConversationOver         = 2004,//会话结束
    UDAgentStatusResultNoExist      = 5050,//客服不存在
    UDAgentGroupStatusResultNoExist = 5060,//客服组不存在
    UDAgentStatusResultLeaveMessage = 3001,//直接留言
    UDAgentStatusResultUnKnown      = 4444,//其他错误
} UDAgentStatusType;

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

/** 客服状态code */
@property (nonatomic, assign) UDAgentStatusType code;

/**
 *  JSON数据转换成UdeskAgent
 *
 *  @param json 客服json数据
 */
- (instancetype)initModelWithJSON:(id)json;

@end
