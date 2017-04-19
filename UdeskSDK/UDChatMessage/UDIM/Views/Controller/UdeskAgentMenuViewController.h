//
//  UdeskAgentMenuViewController.h
//  UdeskSDK
//
//  Created by Udesk on 16/3/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseViewController.h"
@class UdeskSetting;

@interface UdeskAgentMenuViewController : UdeskBaseViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config
                        menuArray:(NSArray *)menu
                      withSetting:(UdeskSetting *)setting;


@end
