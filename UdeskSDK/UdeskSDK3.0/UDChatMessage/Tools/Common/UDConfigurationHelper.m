//
//  UDConfigurationHelper.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDConfigurationHelper.h"

@interface UDConfigurationHelper ()

@property (nonatomic, strong) NSArray *popMenuTitles;

@end

@implementation UDConfigurationHelper

+ (instancetype)appearance {
    static UDConfigurationHelper *configurationHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configurationHelper = [[UDConfigurationHelper alloc] init];
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
