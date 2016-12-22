//
//  UdeskFatherViewController.m
//  UdeskSDK
//
//  Created by Mac开发机 on 2016/12/1.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskUtils.h"

@interface UdeskBaseViewController ()

@end

@implementation UdeskBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 0.基本设置回
    [self setupBase];

    // 1.添加左滑返回手势
    [self addGesture];

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
}

- (void)addGesture
{
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];

}

- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {

    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat xPercent = translation.x / CGRectGetWidth(self.view.bounds) * 0.9;

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [UdeskTransitioningAnimation setInteractive:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [UdeskTransitioningAnimation updateInteractiveTransition:xPercent];
            break;
        default:
            if (xPercent < .45) {
                [UdeskTransitioningAnimation cancelInteractiveTransition];
            } else {
                [UdeskTransitioningAnimation finishInteractiveTransition];
            }
            [UdeskTransitioningAnimation setInteractive:NO];
            break;
    }
}


/**
 * 左侧按钮返回
 */
- (void)dismissChatViewController {

    if ([UdeskSDKConfig sharedConfig].presentingAnimation == UDTransiteAnimationTypePush) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.view.window.layer addAnimation:[UdeskTransitioningAnimation createDismissingTransiteAnimation:[UdeskSDKConfig sharedConfig].presentingAnimation] forKey:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
}

@end
