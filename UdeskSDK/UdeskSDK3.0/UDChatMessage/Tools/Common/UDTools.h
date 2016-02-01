//
//  UDTools.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface UDTools : NSObject

//获取当前时间
+ (NSString *)nowDate;

//字符串转字典
+ (id)dictionaryWithJsonString:(NSString *)jsonString;

//判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string;

//获取网络状态
+ (NSString *)internetStatus;

+ (void)receiveNetwork:(void(^)(Reachability *reachability))completion;

//16进制换算颜色
+ (UIColor *)colorWithHexString: (NSString *)color;

//随机生成唯一字符串
+ (NSString *)soleString;
//计算图片大小
+ (CGSize)setImageSize:(UIImage *)image;

+ (NSString *)sendTextEmoji:(NSString *)text;
+ (NSString *)receiveTextEmoji:(NSString *)text;

//检索是否为链接
+ (NSString *)contentsOfRegexStrArray:(NSString *)text;
//NSString转NSDate
+ (NSDate *)dateFromString:(NSString *)string;
//NSDate转NSString
+ (NSString *)stringFromDate:(NSDate *)date;
//压缩图片
+ (UIImage *)compressionImage:(UIImage *)image;

@end
