//
//  UdeskAgentMenuModel.m
//  UdeskSDK
//
//  Created by Udesk on 16/3/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskAgentMenuModel.h"

@implementation UdeskAgentMenuModel

- (id)initWithContentsOfDic:(NSDictionary *)dic {
    
    self = [super initWithContentsOfDic:dic];
    if (self) {
        self.menu_id = dic[@"id"];
    }
    
    return self;
}

@end
