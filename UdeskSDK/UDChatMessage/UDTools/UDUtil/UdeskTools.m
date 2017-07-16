//
//  UdeskTools.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskTools.h"
#import "UdeskReachability.h"
#import <AVFoundation/AVFoundation.h>
#import "UdeskReachability.h"

@implementation UdeskTools

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
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
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

// 计算图片实际大小
+ (CGSize)neededSizeForPhoto:(UIImage *)image {
    
    @try {
        
        CGFloat fixedSize;
        if ([[UIScreen mainScreen] bounds].size.width>320) {
            fixedSize = 140;
        }
        else {
            fixedSize = 115;
        }
        
        CGSize imageSize = CGSizeMake(fixedSize, fixedSize);
        
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
        
        // 这里需要缩放后的size
        return imageSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
