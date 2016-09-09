//
//  UdeskAnimatorPush.m
//  UdeskSDK
//
//  Created by xuchen on 16/7/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskAnimatorPush.h"

@interface UdeskAnimatorPush()

@property (nonatomic, strong) UIViewController *toViewController;
@property (nonatomic, strong) UIViewController *fromViewController;

@end

@implementation UdeskAnimatorPush

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:self.toViewController];
    if (CGRectIsEmpty(finalFrame)) {
        finalFrame = [[UIScreen mainScreen] bounds];
    }
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if (self.isPresenting) {
        self.toViewController.view.frame = CGRectMake(screenSize.width, 0, screenSize.width, screenSize.height);
        [[transitionContext containerView] addSubview:self.fromViewController.view];
        [[transitionContext containerView] addSubview:self.toViewController.view];
    } else {
        [[transitionContext containerView] addSubview:self.toViewController.view];
        [[transitionContext containerView] addSubview:self.fromViewController.view];
        self.toViewController.view.frame = CGRectMake(-screenSize.width / 2, 0, screenSize.width, screenSize.height);
        self.fromViewController.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    }
    
    [self.toViewController.navigationController beginAppearanceTransition:YES animated:YES];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.toViewController.view.frame = finalFrame;
        if (self.isPresenting) {
            self.fromViewController.view.frame = CGRectMake(-screenSize.width / 2, 0, screenSize.width, screenSize.height);
        } else {
            self.fromViewController.view.frame = CGRectMake(screenSize.width, 0, screenSize.width, screenSize.height);
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        if (![transitionContext transitionWasCancelled] && !self.isPresenting) {
            [[UIApplication sharedApplication].keyWindow addSubview:self.toViewController.view];
        }
    }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    if (transitionCompleted) {
        [self.fromViewController.navigationController endAppearanceTransition];
    }
}

@end
