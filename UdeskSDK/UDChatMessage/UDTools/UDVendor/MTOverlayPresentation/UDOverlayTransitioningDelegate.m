//
//  UDOverlayTransitioningDelegate.m
//  UdeskSDK
//
//  Created by xuchen on 2017/3/13.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import "UDOverlayTransitioningDelegate.h"
#import "UDBouncyViewControllerAnimator.h"

@implementation UDOverlayTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    UDBouncyViewControllerAnimator *animator = [[UDBouncyViewControllerAnimator alloc] init];
    animator.isPresenting = YES;
    
	return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    UDBouncyViewControllerAnimator *animator = [[UDBouncyViewControllerAnimator alloc] init];
    animator.isPresenting = NO;
    
    return animator;
}

@end
