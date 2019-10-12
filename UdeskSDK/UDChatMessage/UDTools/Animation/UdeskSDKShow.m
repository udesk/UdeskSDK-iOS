//
//  UdeskSDKShow.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/26.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskSDKShow.h"
#import "UdeskTransitioningAnimation.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKMacro.h"
#import "UdeskFAQViewController.h"
#import "UdeskRobotViewController.h"
#import "UdeskChatViewController.h"
#import "UdeskBundleUtils.h"
#import "UdeskStringSizeUtil.h"
#import "UIBarButtonItem+UdeskSDK.h"
#import "UdeskBaseNavigationViewController.h"

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

- (void)presentOnViewController:(UIViewController *)rootViewController
            udeskViewController:(id)udeskViewController
              transiteAnimation:(UDTransiteAnimationType)animation
                     completion:(void (^)(void))completion {

    NSMutableArray *array = [NSMutableArray arrayWithArray:_sdkConfig.udViewControllers];
    NSString *vcStr = NSStringFromClass([udeskViewController class]);
    if (vcStr && ![array containsObject:vcStr]) {
        [array addObject:vcStr];
    }
    _sdkConfig.udViewControllers = array;
    
    _sdkConfig.presentingAnimation = animation;
    
    UIViewController *viewController = nil;
    if (animation == UDTransiteAnimationTypePush) {
        viewController = [self createNavigationControllerWithWithAnimationSupport:udeskViewController presentedViewController:rootViewController];
        BOOL shouldUseUIKitAnimation = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
        
        if (ud_isIOS8) {
            //防止多次点击崩溃
            if (viewController.popoverPresentationController && !viewController.popoverPresentationController.sourceView) {
                return;
            }
        }
        
        //指定浅色模式
        if (@available(iOS 13.0, *)) {
            viewController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        } else {
            // Fallback on earlier versions
        }
        
        if(![rootViewController.navigationController.topViewController isKindOfClass:[viewController class]]) {
            [rootViewController presentViewController:viewController animated:shouldUseUIKitAnimation completion:completion];
        }
        
    } else {
        viewController = [[UdeskBaseNavigationViewController alloc] initWithRootViewController:udeskViewController];
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self updateNavAttributesWithViewController:udeskViewController navigationController:(UdeskBaseNavigationViewController *)viewController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        
        if (ud_isIOS8) {
            //防止多次点击崩溃
            if (viewController.popoverPresentationController && !viewController.popoverPresentationController.sourceView) {
                return;
            }
        }
        
        //指定浅色模式
        if (@available(iOS 13.0, *)) {
            viewController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        } else {
            // Fallback on earlier versions
        }
        
        if(![rootViewController.navigationController.topViewController isKindOfClass:[viewController class]]) {
            [rootViewController presentViewController:viewController animated:YES completion:completion];
        }
    }
}

- (UdeskBaseNavigationViewController *)createNavigationControllerWithWithAnimationSupport:(UIViewController *)rootViewController presentedViewController:(UIViewController *)presentedViewController{
    UdeskBaseNavigationViewController *navigationController = [[UdeskBaseNavigationViewController alloc] initWithRootViewController:rootViewController];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UdeskBaseNavigationViewController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [navigationController setTransitioningDelegate:[UdeskTransitioningAnimation transitioningDelegateImpl]];
        [navigationController setModalPresentationStyle:UIModalPresentationCustom];
    } else {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UdeskBaseNavigationViewController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
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
        if (_sdkConfig.sdkStyle.navigationColor) {
            navigationController.navigationBar.barTintColor = _sdkConfig.sdkStyle.navigationColor;
        }
    }
    
    //导航栏左键
    UIBarButtonItem *customizedBackItem = nil;
    if (_sdkConfig.sdkStyle.navBackButtonImage) {
        customizedBackItem = [UIBarButtonItem udItemWithIcon:[_sdkConfig.sdkStyle.navBackButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] target:viewController action:@selector(dismissChatViewController)];
    }
    
    NSString *backText = _sdkConfig.backText ? : getUDLocalizedString(@"udesk_back");
    if (_sdkConfig.presentingAnimation == UDTransiteAnimationTypePresent) {
       viewController.navigationItem.leftBarButtonItem = customizedBackItem ?: [[UIBarButtonItem alloc] initWithTitle:backText style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissChatViewController)];
    } else {

        UIBarButtonItem *leftBarButtonItem = [UIBarButtonItem udItemWithTitle:backText target:viewController action:@selector(dismissChatViewController)];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];

        // 调整 leftBarButtonItem 在 iOS7 下面的位置
        if((FUDSystemVersion>=7.0)){

            negativeSpacer.width = -13;
            if (customizedBackItem) {
                viewController.navigationItem.leftBarButtonItem = customizedBackItem;
            }
            else {
                viewController.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBarButtonItem];
            }
        }
        else {
            viewController.navigationItem.leftBarButtonItem = customizedBackItem ?: leftBarButtonItem;
        }
    }
    
    if ([viewController isKindOfClass:[UdeskRobotViewController class]]) {
        
        NSString *transferText = getUDLocalizedString(@"udesk_redirect");
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        UIBarButtonItem *rightBarButtonItem = [UIBarButtonItem udRightItemWithTitle:transferText target:viewController action:@selector(didSelectNavigationRightButton)];
#pragma clang diagnostic pop

        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        
        // 调整 leftBarButtonItem 在 iOS7 下面的位置
        if((FUDSystemVersion>=7.0)){
            
            negativeSpacer.width = -10;
            viewController.navigationItem.rightBarButtonItems = @[negativeSpacer,rightBarButtonItem];
            
        }else
            viewController.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
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
