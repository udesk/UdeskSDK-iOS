//
//  UdeskVideoLanguageHelper.h
//  UdeskSDK
//
//  Created by xuchen on 2017/11/29.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UVC_LANGUAGE_SET @"UVC_LANGUAGE_SET"

//语言类型枚举
typedef NS_ENUM(NSUInteger, UVCLanguageType) {
    UVCLanguageTypeCN = 0,
    UVCLanguageTypeEN,
};

@interface UdeskVideoLanguageHelper : NSObject

+ (instancetype)shared;

/**
 *  返回table中指定的key的值
 *
 *  @param key   key
 *  @param table table
 *
 *  @return 返回table中指定的key的值
 */
- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;

/**
 *  设置新的语言
 *
 *  @param language 新语言
 */
- (void)setNewLanguage:(UVCLanguageType)language;

@end
