//
//  UdeskOrganization.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/23.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskOrganization : NSObject

/** 公司域名 */
@property (nonatomic, copy) NSString *domain;
/** 公司移动SDK App Key */
@property (nonatomic, copy) NSString *appKey;
/** 公司移动SDK App ID */
@property (nonatomic, copy) NSString *appId;

- (instancetype)initWithDomain:(NSString *)domian
                        appKey:(NSString *)appKey
                         appId:(NSString *)appId;

@end
