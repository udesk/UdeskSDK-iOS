//
//  UdeskFatherViewController.m
//  UdeskSDK
//
//  Created by Udesk on 2016/12/1.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskBundleUtils.h"

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

    // 基本设置
    [self setupBase];
}

- (void)setupBase {
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];

    if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        self.navigationController.navigationBar.translucent = NO;
    }

    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)dismissChatViewController {
    
    if (self.sdkConfig.presentingAnimation == UDTransiteAnimationTypePush) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self dismissViewControllerAnimated:YES];
        } else {
            [self.view.window.layer addAnimation:[UdeskTransitioningAnimation createDismissingTransiteAnimation:self.sdkConfig.presentingAnimation] forKey:nil];
            [self dismissViewControllerAnimated:NO];
        }
    } else {
        [self dismissViewControllerAnimated:YES];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag {
    
    [self dismissViewControllerAnimated:flag completion:^{
        [self setConfigToDefault];
    }];
}

- (void)setConfigToDefault {
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:_sdkConfig.udViewControllers];
    if ([array containsObject:NSStringFromClass([self class])]) {
        [array removeObject:NSStringFromClass([self class])];
        _sdkConfig.udViewControllers = array;
    }
    
    if (!_sdkConfig.udViewControllers.count) {
        if ([UdeskSDKConfig customConfig].actionConfig.leaveUdeskSDKBlock) {
            [UdeskSDKConfig customConfig].actionConfig.leaveUdeskSDKBlock();
        }
        [[UdeskSDKConfig customConfig] setConfigToDefault];
    }
}

@end
