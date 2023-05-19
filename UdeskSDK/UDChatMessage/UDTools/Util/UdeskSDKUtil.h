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

//判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string;
//网络状态
+ (NSString *)networkStatus;
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
//存菜单ID
+ (void)storeMenuId:(NSString *)menuId;
//获取菜单ID
+ (NSString *)getMenuId;
//号码正则
+ (NSArray *)numberRegexs;
//URL正则
+ (NSArray *)linkRegexs;
//URL正则匹配
+ (NSRange)linkRegexsMatch:(NSString *)content;
//URL编码
+ (NSString *)stringByURLEncode:(NSString *)string;
//编码
+ (NSString *)percentEscapedStringFromString:(NSString *)string;
//url编码
+ (NSString *)urlEncode:(NSString *)url;

//url链接校准 - 可能不处理
+ (NSString *)urlQueryFix:(NSString *)urlString;

//监听屏幕旋转
+ (void)listenScreenRotate;
//是否横屏
+ (BOOL)isLandScape;

@end
