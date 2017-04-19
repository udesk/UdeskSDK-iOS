//
//  UdeskSDKConfig.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskSDKConfig.h"
#import "UIColor+UdeskSDK.h"
#import "UdeskFoundationMacro.h"
#import "UIImage+UdeskSDK.h"

@interface UdeskSDKConfig()

/** 超链接正则 */
@property (nonatomic, strong, readwrite) NSMutableArray *linkRegexs;
/** 号码正则 */
@property (nonatomic, strong, readwrite) NSMutableArray *numberRegexs;

@end

@implementation UdeskSDKConfig

+ (instancetype)sharedConfig {

    static UdeskSDKConfig *udConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        udConfig = [[UdeskSDKConfig alloc] init];
    });
    
    return udConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setDefaultConfig];
        
        self.numberRegexs = [[NSMutableArray alloc] initWithArray:@[@"^(\\d{3,4}-?)\\d{7,8}$",
                                                                    @"^1[3|4|5|7|8]\\d{9}",
                                                                    @"[0-9]\\d{4,10}",
                                                                    @"^400(-\\d{3,4}){2}$"]];
        
        self.linkRegexs   = [[NSMutableArray alloc] initWithArray:@[@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"]];
    }
    return self;
}

//默认配置
- (void)setDefaultConfig {

    self.sdkStyle = [UdeskSDKStyle defaultStyle];
    self.customerImage = [UIImage ud_defaultCustomerImage];
}

@end
