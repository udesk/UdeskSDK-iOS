//
//  UDAgentMenuModel.m
//  UdeskSDKExample
//
//  Created by xuchen on 16/3/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDAgentMenuModel.h"

@implementation UDAgentMenuModel

- (id)initWithContentsOfDic:(NSDictionary *)dic {
    
    self = [super initWithContentsOfDic:dic];
    if (self) {
        self.menu_id = dic[@"id"];
    }
    
    return self;
}

@end
