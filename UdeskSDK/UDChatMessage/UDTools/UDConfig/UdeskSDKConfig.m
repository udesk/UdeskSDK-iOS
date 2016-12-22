//
//  UdeskSDKConfig.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskSDKConfig.h"
#import "UIColor+UdeskSDK.h"
#import "UdeskFoundationMacro.h"
#import "UIImage+UdeskSDK.h"

@interface UdeskSDKConfig()

/** 超链接正则 */
@property (nonatomic, copy, readwrite) NSMutableArray *linkRegexs;

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
