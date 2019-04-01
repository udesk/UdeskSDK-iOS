//
//  UdeskAgentMenuModel.h
//  UdeskSDK
//
//  Created by Udesk on 16/3/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskAgentMenuModel : NSObject

@property (nonatomic, copy) NSNumber *hasNext;
@property (nonatomic, copy) NSString *menuId;
@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *parentId;

- (instancetype)initModelWithJSON:(id)json;

@end
