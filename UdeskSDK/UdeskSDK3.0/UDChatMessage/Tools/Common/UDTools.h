//
//  UDTools.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "UDManager.h"
#import "UDMessage.h"

#import "UdeskUtils.h"
#import "NSArray+UDUtils.h"
#import "UDFoundationMacro.h"
#import "NSDictionary+UDUtils.h"
#import "UDKeywordRegularParser.h"
#import "UDMessageBubbleFactory.h"
#import "UDVoiceRecordHelper.h"
#import "UDVoiceRecordHUD.h"
#import "UDGeneral.h"
#import "UDConfig.h"
#import "UIViewExt.h"
#import "PSTAlertController.h"
#import "YYCache.h"

#define  Config [UDConfig sharedUDConfig]

@interface UDTools : NSObject

//获取当前时间
+ (NSString *)nowDate;

//字符串转字典
+ (id)dictionaryWithJsonString:(NSString *)jsonString;

//判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string;

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
