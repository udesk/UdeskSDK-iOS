//
//  UdeskTools.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskTools.h"
#import "UdeskReachability.h"
#import <AVFoundation/AVFoundation.h>

@implementation UdeskTools

//同步获取网络状态
+ (NSString *)internetStatus {
    
    UdeskReachability *reachability   = [UdeskReachability reachabilityWithHostName:@"www.baidu.com"];
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

//随机生成唯一标示
+ (NSString *)soleString {

    CFUUIDRef identifier = CFUUIDCreate(NULL);
    NSString* identifierString = (NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, identifier));
    CFRelease(identifier);
    
    return identifierString;
}

@end
