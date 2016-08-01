//
//  UdeskAgentModel.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseModel.h"

@interface UdeskAgentModel : UdeskBaseModel

/*** 客服ID */
@property (nonatomic, strong) NSString  *agent_id;

/*** 客服名字 */
@property (nonatomic, strong) NSString  *nick;

/*** 客服JID */
@property (nonatomic, strong) NSString  *jid;

/*** 客服状态消息 */
@property (nonatomic, strong) NSString  *message;

/*** 客服状态code */
@property (nonatomic, strong) NSNumber  *code;

/*** 客服头像URL */
@property (nonatomic, strong) NSString  *avatar;

@end
