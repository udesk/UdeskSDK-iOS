//
//  UdeskAgentMenuViewController.h
//  UdeskSDK
//
//  Created by xuchen on 16/3/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UdeskSDKConfig.h"

@interface UdeskAgentMenuViewController : UdeskBaseViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config menuArray:(NSArray *)menu;


@end
