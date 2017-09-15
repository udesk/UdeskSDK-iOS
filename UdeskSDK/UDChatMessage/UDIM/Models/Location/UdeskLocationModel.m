//
//  UdeskLocationModel.m
//  UdeskSDK
//
//  Created by xuchen on 2017/8/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskLocationModel.h"

@implementation UdeskLocationModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.zoomLevel = 16;
    }
    return self;
}

@end
