//
//  UdeskFatherViewController.m
//  UdeskSDK
//
//  Created by Udesk on 2016/12/1.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UdeskTransitioningAnimation.h"

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
    
    //适配ios15
    if (@available(iOS 15.0, *)) {
        if(self.navigationController){
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            // 背景色
            appearance.backgroundColor = [UIColor whiteColor];
            // 去掉半透明效果
            appearance.backgroundEffect = nil;
            // 去除导航栏阴影（如果不设置clear，导航栏底下会有一条阴影线）
            //        appearance.shadowColor = [UIColor clearColor];
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
            self.navigationController.navigationBar.standardAppearance = appearance;
        }
    }
    
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

- (void)dealloc {
    NSLog(@"UdeskSDK：%@释放了",[self class]);
}

@end
