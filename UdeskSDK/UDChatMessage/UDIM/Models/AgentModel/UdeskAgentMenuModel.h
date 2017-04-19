//
//  UdeskAgentMenuModel.h
//  UdeskSDK
//
//  Created by Udesk on 16/3/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseModel.h"

@interface UdeskAgentMenuModel : UdeskBaseModel

@property (nonatomic, copy) NSString *group_id;

@property (nonatomic, copy) NSString *has_next;

@property (nonatomic, copy) NSString *menu_id;

@property (nonatomic, copy) NSString *item_name;

@property (nonatomic, copy) NSString *link;

@property (nonatomic, copy) NSString *parentId;

@end
