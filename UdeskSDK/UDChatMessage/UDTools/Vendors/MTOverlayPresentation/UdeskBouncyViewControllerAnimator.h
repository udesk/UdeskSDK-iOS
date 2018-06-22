//
//  UdeskBouncyViewControllerAnimator.h
//  UdeskSDK
//
//  Created by Udesk on 2017/3/13.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskBouncyViewControllerAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresenting;

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;
@end
