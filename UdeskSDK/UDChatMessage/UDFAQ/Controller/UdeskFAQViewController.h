//
//  UdeskFAQViewController.h
//  UdeskSDK
//
//  Created by xuchen on 16/6/20.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSDKConfig.h"

@interface UdeskFAQViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config;

- (void)dismissChatViewController;

@end
