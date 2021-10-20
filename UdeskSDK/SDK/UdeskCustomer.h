//
//  UdeskCustomer.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/24.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskCustomerCustomField : NSObject

/** 客户自定义字段key（获取方式参照文档）*/
@property (nonatomic, copy  ) NSString *fieldKey;
/** 客户自定义字段内容（这里会有两种格式的value，1.字符串，2.数组。 具体请参考文档） */
@property (nonatomic, strong) id        fieldValue;

@end

@interface UdeskCustomer : NSObject

/** 客户sdkToken 主键: 用户唯一标示,必须传！！！，请不要用特殊字符！！！，请不要写死固定值！！！）*/
@property (nonatomic, copy  ) NSString *sdkToken;
/** 客户customerToken（可选主键: 唯一客户外部标识,用于处理 唯一标识冲突）*/
@property (nonatomic, copy  ) NSString *customerToken;
/** 客户手机，请传入真实有效的手机号！！！ */
@property (nonatomic, copy  ) NSString *cellphone;
/** 客户邮箱，请传入真实有效的邮箱！！！ */
@property (nonatomic, copy  ) NSString *email;
/** 客户名称 */
@property (nonatomic, copy  ) NSString *nickName;
/** 客户描述 */
@property (nonatomic, copy  ) NSString *customerDescription;
/** 自定义渠道（自定义字符串，支持字符数字及-_等简单符号组合，不要传特殊字符！） */
@property (nonatomic, copy  ) NSString *channel;
/** 客户QQ */
@property (nonatomic, copy  ) NSString *qq;
/** 机器人推荐问题（后台配置获取key） */
@property (nonatomic, copy  ) NSString *robotModelKey;
/** 客户自定义字段 */
@property (nonatomic, strong) NSArray<UdeskCustomerCustomField *> *customField;

/** 客户ID（不需要传这个参数) */
@property (nonatomic, copy  ) NSString *customerId;
/** 客户JID（不需要传这个参数) */
@property (nonatomic, copy  ) NSString *customerJID;

@end
