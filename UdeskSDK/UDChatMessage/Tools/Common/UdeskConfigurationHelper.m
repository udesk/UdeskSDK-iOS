//
//  UdeskConfigurationHelper.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskConfigurationHelper.h"

@interface UdeskConfigurationHelper ()

@property (nonatomic, strong) NSArray *popMenuTitles;

@end

@implementation UdeskConfigurationHelper

+ (instancetype)appearance {
    static UdeskConfigurationHelper *configurationHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configurationHelper = [[UdeskConfigurationHelper alloc] init];
    });
    return configurationHelper;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.popMenuTitles = @[@"复制"];
    }
    return self;
}

- (void)setupPopMenuTitles:(NSArray *)popMenuTitles {
    self.popMenuTitles = popMenuTitles;
}

@end
