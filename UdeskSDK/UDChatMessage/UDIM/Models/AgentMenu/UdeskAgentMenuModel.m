//
//  UdeskAgentMenuModel.m
//  UdeskSDK
//
//  Created by Udesk on 16/3/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskAgentMenuModel.h"

@implementation UdeskAgentMenuModel

- (instancetype)initModelWithJSON:(id)json
{
    self = [super init];
    if (self) {
        
        @try {
            
            self.menuId = [NSString stringWithFormat:@"%@",json[@"id"]];
            self.hasNext = json[@"has_next"];
            self.itemName = [NSString stringWithFormat:@"%@",json[@"item_name"]];
            self.link = [NSString stringWithFormat:@"%@",json[@"link"]];
            self.parentId = [NSString stringWithFormat:@"%@",json[@"parentId"]];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    return self;
}

@end
