//
//  UDBouncyViewControllerAnimator.h
//  UdeskSDK
//
//  Created by xuchen on 2017/3/13.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UDBouncyViewControllerAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresenting;

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;
@end
