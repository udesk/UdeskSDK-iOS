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
    }
    return self;
}

//默认配置
- (void)setDefaultConfig {

    self.sdkStyle = [UdeskSDKStyle defaultStyle];
    self.customerImage = [UIImage ud_defaultCustomerImage];
}

@end
