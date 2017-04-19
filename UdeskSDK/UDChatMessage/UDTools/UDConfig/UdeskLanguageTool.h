//
//  UdeskLanguageTool.h
//  UdeskSDK
//
//  Created by Udesk on 16/9/5.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CNS @"zh-Hans"
#define EN  @"en"
#define LANGUAGE_SET @"udLangeuageset"

@interface UdeskLanguageTool : NSObject

+ (id)sharedInstance;

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
 *  改变当前语言
 */
- (void)changeNowLanguage;

/**
 *  设置新的语言
 *
 *  @param language 新语言
 */
- (void)setNewLanguage:(NSString*)language;

@end
