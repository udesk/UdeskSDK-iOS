//
//  UDAgentMenuModel.h
//  UdeskSDKExample
//
//  Created by xuchen on 16/3/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDBaseModel.h"

@interface UDAgentMenuModel : UDBaseModel

@property (nonatomic, copy) NSString *group_id;

@property (nonatomic, copy) NSString *has_next;

@property (nonatomic, copy) NSString *menu_id;

@property (nonatomic, copy) NSString *item_name;

@property (nonatomic, copy) NSString *link;

@property (nonatomic, copy) NSString *parentId;

@end
