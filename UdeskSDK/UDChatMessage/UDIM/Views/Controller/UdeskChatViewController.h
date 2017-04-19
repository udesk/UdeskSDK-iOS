//
//  UdeskChatViewController.h
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskSDKConfig;
@class UdeskSetting;

@interface UdeskChatViewController : UIViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config
                     withSettings:(UdeskSetting *)setting;

@end
