//
//  UdeskAgentMenuViewController.h
//  UdeskSDK
//
//  Created by xuchen on 16/3/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"
@class UdeskSetting;

@interface UdeskAgentMenuViewController : UdeskBaseViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config menuArray:(NSArray *)menu;

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config
                        menuArray:(NSArray *)menu
                      withSetting:(UdeskSetting *)setting;


@end
