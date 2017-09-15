//
//  UdeskFatherViewController.h
//  UdeskSDK
//
//  Created by Udesk on 2016/12/1.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSDKConfig.h"
#import "UdeskSetting.h"

@interface UdeskBaseViewController : UIViewController

@property (nonatomic, strong) UdeskSDKConfig     *sdkConfig;//sdk配置
@property (nonatomic, strong) UdeskSetting       *sdkSetting;//sdk后台配置

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config
                          setting:(UdeskSetting *)setting;

- (void)dismissChatViewController;

@end
