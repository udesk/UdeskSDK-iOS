//
//  UDTools.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDTools.h"
#import "UDFoundationMacro.h"
#import "UDKeywordRegularParser.h"

#define MAXIMAGESIZE    300

@implementation UDTools

//获取当前时间字符串
+ (NSString *)nowDate {
    
    NSDateFormatter *nsdf2=[[NSDateFormatter alloc] init];
    [nsdf2 setDateStyle:NSDateFormatterShortStyle];
    [nsdf2 setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    return [nsdf2 stringFromDate:[NSDate date]];
    
}

//字符串转字典
+ (id)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//判断是否为表情
+ (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}
//判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string {

    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

//16进制颜色转换
+ (UIColor *)colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

//随机生成唯一标示
+ (NSString *)soleString {

    CFUUIDRef identifier = CFUUIDCreate(NULL);
    NSString* identifierString = (NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, identifier));
    CFRelease(identifier);
    
    return identifierString;
}

+ (CGSize)setImageSize:(UIImage *)image {
    
    CGSize imageSize;
    
    CGFloat fixedSize;
    if (UD_SCREEN_WIDTH>320) {
        fixedSize = 130;
    }
    else {
        fixedSize = 115;
    }
    
    if (image.size.height > image.size.width) {
        
        CGFloat scale = image.size.height/fixedSize;
        if (scale!=0) {
            
            CGFloat newWidth = (image.size.width)/scale;
            
            imageSize = CGSizeMake(newWidth<60.0f?60:newWidth, fixedSize);
            
        }
        
    }
    else if (image.size.height < image.size.width) {
        
        CGFloat scale = image.size.width/fixedSize;
        
        if (scale!=0) {
            
            CGFloat newHeight = (image.size.height)/scale;
            imageSize = CGSizeMake(fixedSize, newHeight);
        }
        
    }
    else if (image.size.height == image.size.width) {
        
        imageSize = CGSizeMake(fixedSize, fixedSize);
    }
    
    
    return imageSize;
    
}

+(UIImage *)compressImageWith:(UIImage *)image
{
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = 450;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

+ (NSString *)sendTextEmoji:(NSString *)text {
    
    NSDictionary *emojiDictionary = @{
                                      @"\U0001F604":@"[emoji001]",
                                      @"\U0001F60A":@"[emoji002]",
                                      @"\U0001F603":@"[emoji003]",
                                      @"\U0000263A":@"[emoji004]",
                                      @"\U0001F609":@"[emoji005]",
                                      @"\U0001F60D":@"[emoji006]",
                                      @"\U0001F618":@"[emoji007]",
                                      @"\U0001F61A":@"[emoji008]",
                                      @"\U0001F633":@"[emoji009]",
                                      @"\U0001F60C":@"[emoji010]",
                                      @"\U0001F601":@"[emoji011]",
                                      @"\U0001F61C":@"[emoji012]",
                                      @"\U0001F61D":@"[emoji013]",
                                      @"\U0001F612":@"[emoji014]",
                                      @"\U0001F60F":@"[emoji015]",
                                      @"\U0001F613":@"[emoji016]",
                                      @"\U0001F614":@"[emoji017]",
                                      @"\U0001F61E":@"[emoji018]",
                                      @"\U0001F616":@"[emoji019]",
                                      @"\U0001F625":@"[emoji020]",
                                      @"\U0001F630":@"[emoji021]",
                                      @"\U0001F628":@"[emoji022]",
                                      @"\U0001F623":@"[emoji023]",
                                      @"\U0001F622":@"[emoji024]",
                                      @"\U0001F62D":@"[emoji025]",
                                      @"\U0001F602":@"[emoji026]",
                                      @"\U0001F632":@"[emoji027]",
                                      @"\U0001F631":@"[emoji028]",
                                      };
    
    NSArray *symbolArray = [NSArray arrayWithObjects:
                            @"\U0001F604", //@"\ue415",
                            @"\U0001F60A", //@"\ue056",
                            @"\U0001F603", //@"\ue057",
                            @"\U0000263A", //@"\ue414",
                            @"\U0001F609", //@"\ue405",
                            @"\U0001F60D", //@"\ue106",
                            @"\U0001F618", //@"\ue418",
                            @"\U0001F61A", //@"\ue417",
                            @"\U0001F633", //@"\ue40d",
                            @"\U0001F60C", //@"\ue40a",
                            @"\U0001F601", //@"\ue404",
                            @"\U0001F61C", //@"\ue105",
                            @"\U0001F61D", //@"\ue409",
                            @"\U0001F612", //@"\ue40e",
                            @"\U0001F60F", //@"\ue402",
                            @"\U0001F613", //@"\ue108",
                            @"\U0001F614", //@"\ue403",
                            @"\U0001F61E", //@"\ue058",
                            @"\U0001F616", //@"\ue407",
                            @"\U0001F625", //@"\ue401",
                            @"\U0001F630", //@"\ue40f",
                            @"\U0001F628", //@"\ue40b",
                            @"\U0001F623", //@"\ue406",
                            @"\U0001F622", //@"\ue413",
                            @"\U0001F62D", //@"\ue411",
                            @"\U0001F602", //@"\ue412",
                            @"\U0001F632", //@"\ue410",
                            @"\U0001F631", //@"\ue107",
                            nil];
    
    NSString *emojiKey = nil;
    
    if ([UDTools isContainsEmoji:text]) {
        
        for (NSString *name in symbolArray) {
            if ([text rangeOfString:name].location != NSNotFound) {
                emojiKey = name;
                NSString *value = [emojiDictionary objectForKey:emojiKey];
                text = [text stringByReplacingOccurrencesOfString:emojiKey withString:value];
            }
        }
    }
    
    return text;
    
}

+ (NSString *)receiveTextEmoji:(NSString *)text {
    
    NSString *contentCoy = text;
    
    NSDictionary * dicss = @{
                             @"[emoji001]":@"\U0001F604",
                             @"[emoji002]":@"\U0001F60A",
                             @"[emoji003]":@"\U0001F603",
                             @"[emoji004]":@"\U0000263A",
                             @"[emoji005]":@"\U0001F609",
                             @"[emoji006]":@"\U0001F60D",
                             @"[emoji007]":@"\U0001F618",
                             @"[emoji008]":@"\U0001F61A",
                             @"[emoji009]":@"\U0001F633",
                             @"[emoji010]":@"\U0001F60C",
                             @"[emoji011]":@"\U0001F601",
                             @"[emoji012]":@"\U0001F61C",
                             @"[emoji013]":@"\U0001F61D",
                             @"[emoji014]":@"\U0001F612",
                             @"[emoji015]":@"\U0001F60F",
                             @"[emoji016]":@"\U0001F613",
                             @"[emoji017]":@"\U0001F614",
                             @"[emoji018]":@"\U0001F61E",
                             @"[emoji019]":@"\U0001F616",
                             @"[emoji020]":@"\U0001F625",
                             @"[emoji021]":@"\U0001F630",
                             @"[emoji022]":@"\U0001F628",
                             @"[emoji023]":@"\U0001F623",
                             @"[emoji024]":@"\U0001F622",
                             @"[emoji025]":@"\U0001F62D",
                             @"[emoji026]":@"\U0001F602",
                             @"[emoji027]":@"\U0001F632",
                             @"[emoji028]":@"\U0001F631",
                             };
    
    
    if ([text rangeOfString:@"emoji"].location!=NSNotFound) {
        
        NSArray *array = [UDKeywordRegularParser keywordRangesOfEmotionInString:text trimedString:&text];
        
        for (UDPaserdKeyword *keyworkEntity in array) {
            NSString *keyword = keyworkEntity.keyword;
            NSString *value = [dicss objectForKey:keyword];
            
            if ([UDTools isBlankString:value] == NO) {
                
                contentCoy = [contentCoy stringByReplacingOccurrencesOfString:keyword withString:value];
            }
            
            
        }
        
    }
    
    return contentCoy;
    
}

//检索文本的正则表达式的字符串
+ (NSString *)contentsOfRegexStringWithWXLabel
{
    //需要添加链接字符串的正则表达式：@http://、@邮箱、号码
    NSString *regex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    return regex;
}

//返回所有的链接字符串数组
+ (NSString *)contentsOfRegexStrArray:(NSString *)text
{
    
    //需要添加链接字符串正则表达：邮箱、http://、号码
    NSString *regex = [UDTools contentsOfRegexStringWithWXLabel];
    NSError *error = NULL;
    NSTextCheckingResult *result;
    if (text != nil){
        
        NSRegularExpression *regexs = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
        result = [regexs firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    }
    
    return [text substringWithRange:result.range];
    
}

//NSString转NSDate
+ (NSDate *)dateFromString:(NSString *)string
{
    //设置转换格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString转NSDate
    NSDate *date=[formatter dateFromString:string];
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:date];
    //输出currentDateString
    return currentDateString;
}

@end
