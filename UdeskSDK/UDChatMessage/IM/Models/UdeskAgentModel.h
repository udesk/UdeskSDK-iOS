//
//  UdeskAgentModel.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseModel.h"

typedef enum : NSUInteger {
    UDAgentStatusResultOnline       = 2000,//客服在线
    UDAgentStatusResultQueue        = 2001,//客服繁忙
    UDAgentStatusResultOffline      = 2002,//客服离线
    UDAgentStatusResultNotNetWork   = 2003,//无网络
    UDAgentStatusResultNoExist      = 5050,//客服不存在
    UDAgentGroupStatusResultNoExist = 5060,//客服组不存在
    UDAgentStatusResultUnKnown      = -2000,//其他错误
} UDAgentStatusType;

@interface UdeskAgentModel : UdeskBaseModel

/*** 客服ID */
@property (nonatomic, strong) NSString          *agent_id;

/*** 客服名字 */
@property (nonatomic, strong) NSString          *nick;

/*** 客服JID */
@property (nonatomic, strong) NSString          *jid;

/*** 客服状态消息 */
@property (nonatomic, strong) NSString          *message;

/*** 客服头像URL */
@property (nonatomic, strong) NSString          *avatar;

/*** 客服状态code */
@property (nonatomic, assign) UDAgentStatusType code;

@end
