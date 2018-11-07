//
//  UdeskSDKUtil.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskSDKUtil : NSObject

//使用时需要注意8.3以下需要在主线层执行，其他要在子线程执行
+ (NSAttributedString *)attributedStringWithHTML:(NSString *)html;
//判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string;
//随机生成唯一字符串
+ (NSString *)soleString;
//网络状态
+ (NSString *)internetStatus;
//判断是否有系统表情
+ (BOOL)stringContainsEmoji:(NSString *)string;
//字符串转字典
+ (id)dictionaryWithJSON:(NSString *)json;
//字典转字符串
+ (NSString *)JSONWithDictionary:(NSDictionary *)dictionary;
//当前控制器
+ (UIViewController *)currentViewController;
//存组ID
+ (void)storeGroupId:(NSString *)groupId;
//获取组ID
+ (NSString *)getGroupId;
//号码正则
+ (NSArray *)numberRegexs;
//URL正则
+ (NSArray *)linkRegexs;
//URL正则匹配
+ (NSRange)linkRegexsMatch:(NSString *)content;

@end
