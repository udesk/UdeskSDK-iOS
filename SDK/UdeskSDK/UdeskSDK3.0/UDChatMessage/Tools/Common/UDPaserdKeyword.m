//
//  UDPaserdKeyword.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDPaserdKeyword.h"

@implementation UDPaserdKeyword

- (instancetype)initWithKeyword:(NSString *)keyword atRange:(NSRange)range
{
    self = [super init];
    if (self) {
        self.keyword = keyword;
        self.range = range;
    }
    return self;
}

@end
