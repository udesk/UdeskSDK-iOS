//
//  UdeskAgentNavigationMenu.h
//  UdeskSDKExample
//
//  Created by xuchen on 16/3/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"

@interface UdeskAgentNavigationMenu : UdeskBaseViewController

@property (nonatomic, strong) NSArray *agentMenuData;

- (instancetype)initWithMenuArray:(NSArray *)menu;

@end
