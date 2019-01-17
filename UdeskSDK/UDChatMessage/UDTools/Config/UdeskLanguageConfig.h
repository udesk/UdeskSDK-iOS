//
//  UdeskLanguageConfig.h
//  UdeskSDK
//
//  Created by Udesk on 16/9/5.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskLanguageConfig : NSObject

+ (instancetype)sharedConfig;

/**
 *  返回table中指定的key的值
 *
 *  @param key   key
 *  @param table table
 *
 *  @return 返回table中指定的key的值
 */
- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;

//更新语言
- (void)setSDKLanguageToEnglish;
- (void)setSDKLanguageToChinease;

@property (nonatomic,strong) NSString *language;

@end
