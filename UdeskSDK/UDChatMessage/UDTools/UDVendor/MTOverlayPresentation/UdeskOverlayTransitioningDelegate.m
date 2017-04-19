//
//  UdeskOverlayTransitioningDelegate.m
//  UdeskSDK
//
//  Created by Udesk on 2017/3/13.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskOverlayTransitioningDelegate.h"
#import "UdeskBouncyViewControllerAnimator.h"

@implementation UdeskOverlayTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    UdeskBouncyViewControllerAnimator *animator = [[UdeskBouncyViewControllerAnimator alloc] init];
    animator.isPresenting = YES;
    
	return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    UdeskBouncyViewControllerAnimator *animator = [[UdeskBouncyViewControllerAnimator alloc] init];
    animator.isPresenting = NO;
    
    return animator;
}

@end
