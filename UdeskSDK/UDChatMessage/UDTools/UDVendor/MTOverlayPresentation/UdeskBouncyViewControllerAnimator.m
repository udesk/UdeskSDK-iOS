//
//  UdeskBouncyViewControllerAnimator.m
//  UdeskSDK
//
//  Created by Udesk on 2017/3/13.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBouncyViewControllerAnimator.h"

@implementation UdeskBouncyViewControllerAnimator
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
	return 0.8f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPresenting)
        [self presentWithTransitionContext:transitionContext];
    else
        [self dismissWithTransitionContext:transitionContext];
}

- (void)dismissWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:0.25f animations:^{

    } completion:^(BOOL finished) {
        [fromVC.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (void)presentWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    UIView *toView = [[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] view];
    
    [inView addSubview:toView];
    // Use whatever animateWithDuration you need
    [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        // Custom animation here
    } completion:^(BOOL finished) {
        // IMPORTANT
        [transitionContext completeTransition:YES];
    }];
}

@end
