//
//  UdeskRobotViewController.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UdeskSetting.h"

@interface UdeskRobotViewController : UdeskBaseViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config withURL:(NSURL *)URL;

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config
                          withURL:(NSURL *)URL
                      withSetting:(UdeskSetting *)setting;

@property (nonatomic, strong) UdeskSetting *sdkSetting;

@end
