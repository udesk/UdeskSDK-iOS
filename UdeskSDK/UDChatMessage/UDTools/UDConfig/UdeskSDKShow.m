//
//  UdeskSDKShow.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/26.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskSDKShow.h"
#import "UdeskTransitioningAnimation.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskFoundationMacro.h"
#import "UdeskFAQViewController.h"
#import "UdeskRobotViewController.h"
#import "UdeskChatViewController.h"
#import "UdeskUtils.h"
#import "UdeskStringSizeUtil.h"

@interface UdeskSDKShow()

@property (nonatomic, strong) UdeskSDKConfig *sdkConfig;

@end

@implementation UdeskSDKShow

- (instancetype)initWithConfig:(UdeskSDKConfig *)sdkConfig
{
    self = [super init];
    if (self) {
        _sdkConfig = sdkConfig;
    }
    return self;
}

- (void)presentOnViewController:(UIViewController *)rootViewController udeskViewController:(id)udeskViewController transiteAnimation:(UDTransiteAnimationType)animation {

    _sdkConfig.presentingAnimation = animation;
    
    UIViewController *viewController = nil;
    if (animation == UDTransiteAnimationTypePush) {
        viewController = [self createNavigationControllerWithWithAnimationSupport:udeskViewController presentedViewController:rootViewController];
        BOOL shouldUseUIKitAnimation = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
        
        if(![rootViewController.navigationController.topViewController isKindOfClass:[viewController class]]) {
            [rootViewController presentViewController:viewController animated:shouldUseUIKitAnimation completion:nil];
        }
        
    } else {
        viewController = [[UINavigationController alloc] initWithRootViewController:udeskViewController];
        [self updateNavAttributesWithViewController:udeskViewController navigationController:(UINavigationController *)viewController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        
        if(![rootViewController.navigationController.topViewController isKindOfClass:[viewController class]]) {
            [rootViewController presentViewController:viewController animated:YES completion:nil];
        }
    }
}

- (UINavigationController *)createNavigationControllerWithWithAnimationSupport:(UIViewController *)rootViewController presentedViewController:(UIViewController *)presentedViewController{
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [navigationController setTransitioningDelegate:[UdeskTransitioningAnimation transitioningDelegateImpl]];
        [navigationController setModalPresentationStyle:UIModalPresentationCustom];
    } else {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [rootViewController.view.window.layer addAnimation:[UdeskTransitioningAnimation createPresentingTransiteAnimation:_sdkConfig.presentingAnimation] forKey:nil];
    }
    return navigationController;
}

//修改导航栏属性
- (void)updateNavAttributesWithViewController:(UIViewController *)viewController
                         navigationController:(UINavigationController *)navigationController
                  defaultNavigationController:(UINavigationController *)defaultNavigationController
                           isPresentModalView:(BOOL)isPresentModalView {
    if (_sdkConfig.sdkStyle.navBackButtonColor) {
        navigationController.navigationBar.tintColor = _sdkConfig.sdkStyle.navBackButtonColor;
    } else if (defaultNavigationController && defaultNavigationController.navigationBar.tintColor) {
        navigationController.navigationBar.tintColor = defaultNavigationController.navigationBar.tintColor;
    }
    
    if (defaultNavigationController.navigationBar.titleTextAttributes) {
        navigationController.navigationBar.titleTextAttributes = defaultNavigationController.navigationBar.titleTextAttributes;
    } else {
        UIColor *color = _sdkConfig.sdkStyle.titleColor;
        UIFont *font = _sdkConfig.sdkStyle.titleFont;
        NSDictionary *attr = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
        navigationController.navigationBar.titleTextAttributes = attr;
    }
    
    if (_sdkConfig.sdkStyle.navBarBackgroundImage) {
        [navigationController.navigationBar setBackgroundImage:_sdkConfig.sdkStyle.navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    } else {
        navigationController.navigationBar.barTintColor = _sdkConfig.sdkStyle.navigationColor;
    }
    
    //导航栏左键
    UIBarButtonItem *customizedBackItem = nil;
    if (_sdkConfig.sdkStyle.navBackButtonImage) {
        customizedBackItem = [[UIBarButtonItem alloc]initWithImage:_sdkConfig.sdkStyle.navBackButtonImage style:(UIBarButtonItemStylePlain) target:viewController action:@selector(dismissChatViewController)];
    }
    
    if (_sdkConfig.presentingAnimation == UDTransiteAnimationTypePresent) {
        viewController.navigationItem.leftBarButtonItem = customizedBackItem ?: [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:viewController action:@selector(dismissChatViewController)];
    } else {
        
        NSString *backText = getUDLocalizedString(@"udesk_back");
        UIImage *backImage = [UIImage ud_defaultBackImage];
        
        CGSize backTextSize = [UdeskStringSizeUtil textSize:backText withFont:[UIFont systemFontOfSize:17] withSize:CGSizeMake(70, 30)];
        
        UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBarButton.frame = CGRectMake(0, 0, backTextSize.width+backImage.size.width+20, backTextSize.height);
        [leftBarButton setTitle:backText forState:UIControlStateNormal];
        backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [leftBarButton setTintColor:_sdkConfig.sdkStyle.navBackButtonColor];
        [leftBarButton setImage:backImage forState:UIControlStateNormal];
        [leftBarButton setTitleColor:_sdkConfig.sdkStyle.navBackButtonColor forState:UIControlStateNormal];
        [leftBarButton addTarget:viewController action:@selector(dismissChatViewController) forControlEvents:UIControlEventTouchUpInside];
        
        [leftBarButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        
        UIBarButtonItem *otherNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        
        // 调整 leftBarButtonItem 在 iOS7 下面的位置
        if((FUDSystemVersion>=7.0)){
            
            negativeSpacer.width = -13;
            if (customizedBackItem) {
                viewController.navigationItem.leftBarButtonItems = @[negativeSpacer,customizedBackItem];
            }
            else {
                viewController.navigationItem.leftBarButtonItems = @[negativeSpacer,otherNavigationItem];
            }
            
        }else
            viewController.navigationItem.leftBarButtonItem = customizedBackItem ?: otherNavigationItem;
        
    }
    
    if ([viewController isKindOfClass:[UdeskRobotViewController class]]) {
        
        NSString *transferText;
        if (_sdkConfig.transferText) {
            transferText = _sdkConfig.transferText;
        }
        else {
            transferText = getUDLocalizedString(@"udesk_redirect");
        }
        
        CGSize transferTextSize = [UdeskStringSizeUtil textSize:transferText withFont:[UIFont systemFontOfSize:16] withSize:CGSizeMake(85, 30)];
        UIImage *rightImage = [UIImage ud_defaultTransferImage];
        
        //导航栏右键
        UIButton *navBarRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [navBarRightButton setTitle:transferText forState:UIControlStateNormal];
        rightImage = [rightImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [navBarRightButton setTintColor:_sdkConfig.sdkStyle.transferButtonColor];
        [navBarRightButton setImage:rightImage forState:UIControlStateNormal];
        navBarRightButton.frame = CGRectMake(0, 0, transferTextSize.width+rightImage.size.width, transferTextSize.height);
        navBarRightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [navBarRightButton setTitleColor:_sdkConfig.sdkStyle.transferButtonColor forState:UIControlStateNormal];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [navBarRightButton addTarget:viewController action:@selector(didSelectNavigationRightButton) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        UIBarButtonItem *otherNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:navBarRightButton];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        
        // 调整 leftBarButtonItem 在 iOS7 下面的位置
        if((FUDSystemVersion>=7.0)){
            
            negativeSpacer.width = -10;
            viewController.navigationItem.rightBarButtonItems = @[negativeSpacer,otherNavigationItem];
            
        }else
            viewController.navigationItem.rightBarButtonItem = otherNavigationItem;
        
        //导航栏标题
        if (_sdkConfig.robotTtile) {
            viewController.navigationItem.title = _sdkConfig.robotTtile;
        }
        else {
            viewController.navigationItem.title = getUDLocalizedString(@"udesk_robot_title");
        }
        
    }
    else if ([viewController isKindOfClass:[UdeskFAQViewController class]]) {
        
        //导航栏标题
        if (_sdkConfig.faqTitle) {
            viewController.navigationItem.title = _sdkConfig.faqTitle;
        }
        else {
            viewController.navigationItem.title = getUDLocalizedString(@"udesk_faq_title");
        }
    }
    else if ([viewController isKindOfClass:[UdeskChatViewController class]]) {
        
        //导航栏标题
        if (_sdkConfig.imTitle) {
            viewController.navigationItem.title = _sdkConfig.imTitle;
        }
    }
    
}

@end
