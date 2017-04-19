//
//  UdeskAnimatorPush.m
//  UdeskSDK
//
//  Created by Udesk on 16/7/18.
//  Copyright © 2016年 Udesk. All rights reserved.
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
    //1.获得容器的View
    UIView *containerView = [transitionContext containerView];
    if(containerView == nil)  return;
    
    //2.获得源View 和toView
    UIView *toView = [self toView:transitionContext];
    UIView *fromView = [self fromView:transitionContext];
    
    //3.设置View的frame 并增加到容器中
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (self.isPresenting) {
        toView.frame = CGRectMake(screenSize.width, 0, screenSize.width, screenSize.height);
        [[transitionContext containerView] addSubview:fromView];
        [[transitionContext containerView] addSubview:toView];
    } else {
        [[transitionContext containerView] addSubview:toView];
        [[transitionContext containerView] addSubview:fromView];
        toView.frame = CGRectMake(-screenSize.width / 2, 0, screenSize.width, screenSize.height);
        fromView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    }
    
    [self.toViewController.navigationController beginAppearanceTransition:YES animated:YES];
    //5.动画效果
    [UIView animateWithDuration:0.35 animations:^{
        //源控制器推出窗口
        toView.frame = CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height);
        if (self.isPresenting) {
            fromView.frame = CGRectMake(-screenSize.width / 2, 0, screenSize.width, screenSize.height);
        } else {
            fromView.frame = CGRectMake(screenSize.width, 0, screenSize.width, screenSize.height);
        }
        
    } completion:^(BOOL finished) {
        //结束动画
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        if (![transitionContext transitionWasCancelled] && !self.isPresenting) {
            toView.alpha =1.0;
            fromView.alpha = 0.0;
        }        
    }];
    
}

- (UIView *)fromView:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *fromView = nil;
    //源控制器
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if([transitionContext respondsToSelector:@selector(viewForKey:)])
    {
        fromView =  [transitionContext viewForKey:UITransitionContextFromViewKey];
    }
    else
        fromView = self.fromViewController.view;
    //初始位置的frame
    fromView.frame = [transitionContext initialFrameForViewController:self.fromViewController];
    return fromView;
}

- (UIView *)toView:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *toView = nil;
    //目的控制器
    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if([transitionContext respondsToSelector:@selector(viewForKey:)])
    {
        toView =  [transitionContext viewForKey:UITransitionContextToViewKey];
    }
    else
        toView = self.toViewController.view;
    //动画结束位置的frame
    toView.frame = [transitionContext finalFrameForViewController:self.toViewController];
    return toView;
}

- (void)animationEnded:(BOOL)transitionCompleted {
    if (transitionCompleted) {
        [self.fromViewController.navigationController endAppearanceTransition];
    }
}

@end
