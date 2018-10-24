//
//  UdeskSDKUtil.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskSDKUtil.h"
#import "UdeskReachability.h"
#import <sys/utsname.h>

static NSString *kUdeskGroupId = @"kUdeskGroupId";

@implementation UdeskSDKUtil

+ (NSAttributedString *)attributedStringWithHTML:(NSString *)html {
    
    NSDictionary *dic = @{
                          NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                          NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)
                          };
    NSAttributedString *attri = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding] options:dic documentAttributes:nil error:nil];
    return attri;
}

//字符串转字典
+ (id)dictionaryWithJSON:(NSString *)json {
    if (json == nil) {
        return nil;
    }
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"UdeskSDK：%@",err);
        return nil;
    }
    return dic;
}

//字典转字符串
+ (NSString *)JSONWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return @"";
    if (![dictionary isKindOfClass:[NSDictionary class]]) return @"";
    
    @try {
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString;
        
        if (!jsonData) {
            NSLog(@"UdeskSDK：%@",error);
        } else{
            jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
        
        NSRange range = {0,jsonString.length};
        
        //去掉字符串中的空格
        [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
        
        NSRange range2 = {0,mutStr.length};
        
        //去掉字符串中的换行符
        [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
        
        return mutStr;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//同步获取网络状态
+ (NSString *)internetStatus {
    
    UdeskReachability *reachability   = [UdeskReachability reachabilityWithHostName:@"www.apple.com"];
    UDNetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    NSString *net = nil;
    switch (internetStatus) {
        case UDReachableViaWiFi:
            net = @"wifi";
            break;
            
        case UDReachableViaWWAN:
            net = @"WWAN";
            break;
            
        case UDNotReachable:
            net = @"notReachable";
            
        default:
            break;
    }
    
    return net;
}

+ (UIViewController *)currentViewController
{
    UIWindow *keyWindow  = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController)
    {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = [(UINavigationController *)vc visibleViewController];
        }
        else if ([vc isKindOfClass:[UITabBarController class]])
        {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    
    return vc;
}

//判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string {

    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    
    if (![string isKindOfClass:[NSString class]]) {
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

//随机生成唯一标示
+ (NSString *)soleString {

    CFUUIDRef identifier = CFUUIDCreate(NULL);
    NSString* identifierString = (NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, identifier));
    CFRelease(identifier);
    
    return identifierString;
}

+ (BOOL)stringContainsEmoji:(NSString *)string
{
    @try {
        
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
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

+ (void)storeGroupId:(NSString *)groupId {
    @try {
        //用户传入GroupId
        if ([UdeskSDKUtil isBlankString:groupId]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUdeskGroupId];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            groupId = [NSString stringWithFormat:@"%@",groupId];
            [[NSUserDefaults standardUserDefaults] setObject:groupId forKey:kUdeskGroupId];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

+ (NSString *)getGroupId {
    
    @try {
        return [[NSUserDefaults standardUserDefaults] stringForKey:kUdeskGroupId];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

+ (NSArray *)numberRegexs {
    
    return @[@"0?(13|14|15|18)[0-9]{9}",
             @"[0-9-()()]{7,18}"];
}

+ (NSArray *)linkRegexs {
    
    return @[@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)",
             @"^[hH][tT][tT][pP]([sS]?):\\/\\/(\\S+\\.)+\\S{2,}$"];
}

+ (NSRange)linkRegexsMatch:(NSString *)content {
    
    NSArray *numberRegexs = [UdeskSDKUtil linkRegexs];
    // 数字正则匹配
    for (NSString *numberRegex in numberRegexs) {
        NSRange range = [content rangeOfString:numberRegex options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            return range;
        }
    }
    
    return NSMakeRange(NSNotFound, 0);
}

@end
