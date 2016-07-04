//
//  UdeskTools.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskTools : NSObject

//字符串转字典
+ (id)dictionaryWithJsonString:(NSString *)jsonString;

//判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string;

//16进制换算颜色
+ (UIColor *)colorWithHexString: (NSString *)color;

//随机生成唯一字符串
+ (NSString *)soleString;

+ (NSString *)internetStatus;

//计算图片大小
+ (CGSize)setImageSize:(UIImage *)image;

+ (NSString *)sendTextEmoji:(NSString *)text;
+ (NSString *)receiveTextEmoji:(NSString *)text;

//压缩图片
+ (UIImage *)compressImageWith:(UIImage *)image;

+ (BOOL)canRecord;

@end
