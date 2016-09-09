//
//  UdeskAgentMenuViewController.h
//  UdeskSDK
//
//  Created by xuchen on 16/3/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSDKConfig.h"

@interface UdeskAgentMenuViewController : UIViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config menuArray:(NSArray *)menu;

- (void)dismissChatViewController;

@end
