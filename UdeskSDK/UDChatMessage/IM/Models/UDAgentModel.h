//
//  UDAgentModel.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDBaseModel.h"

@interface UDAgentModel : UDBaseModel

/*** 客服ID */
@property (nonatomic, copy  ) NSString  *agent_id;

/*** 客服名字 */
@property (nonatomic, copy  ) NSString  *nick;

/*** 客服JID */
@property (nonatomic, copy  ) NSString  *jid;

/*** 客服状态消息 */
@property (nonatomic, copy  ) NSString  *message;

/*** 客服状态code */
@property (nonatomic, assign) NSInteger code;


@end
