//
//  UdeskFatherViewController.m
//  UdeskSDK
//
//  Created by Udesk on 2016/12/1.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskUtils.h"

@interface UdeskBaseViewController ()

@end

@implementation UdeskBaseViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config
                          setting:(UdeskSetting *)setting {

    self = [super init];
    if (self) {
        _sdkConfig = config;
        _sdkSetting = setting;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 0.基本设置回
    [self setupBase];
}

- (void)setupBase
{
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];

    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }

    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)dismissChatViewController {
    
    if (self.sdkConfig.presentingAnimation == UDTransiteAnimationTypePush) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.view.window.layer addAnimation:[UdeskTransitioningAnimation createDismissingTransiteAnimation:self.sdkConfig.presentingAnimation] forKey:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
