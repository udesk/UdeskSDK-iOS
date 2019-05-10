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

/** 客户sdkToken（主键: 用户唯一标示,创建的时候必须传，更新的时候不用传）*/
@property (nonatomic, copy  ) NSString *sdkToken;
/** 客户customerToken（可选主键: 唯一客户外部标识）*/
@property (nonatomic, copy  ) NSString *customerToken;
/** 客户手机 */
@property (nonatomic, copy  ) NSString *cellphone;
/** 客户手机 */
@property (nonatomic, copy  ) NSString *email;
/** 客户名称 */
@property (nonatomic, copy  ) NSString *nickName;
/** 客户描述 */
@property (nonatomic, copy  ) NSString *customerDescription;
/** 自定义渠道（自定义字符串，支持字符数字及-_等简单符号组合，不要传特殊字符！） */
@property (nonatomic, copy  ) NSString *channel;
/** 客户自定义字段 */
@property (nonatomic, strong) NSArray<UdeskCustomerCustomField *> *customField;

/** 客户ID（不需要传这个参数) */
@property (nonatomic, copy  ) NSString *customerId;
/** 客户JID（不需要传这个参数) */
@property (nonatomic, copy  ) NSString *customerJID;

@end
