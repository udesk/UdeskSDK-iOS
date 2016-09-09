//
//  UdeskRobotViewController.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSDKConfig.h"

@interface UdeskRobotViewController : UIViewController

- (void)didSelectNavigationRightButton;

- (void)dismissChatViewController;

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config withURL:(NSURL *)URL;

@end
