//
//  UdeskTransitioningAnimation.h
//  UdeskSDK
//
//  Created by xuchen on 16/7/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskTransitioningAnimation.h"

@interface UdeskTransitioningAnimation()

@property (nonatomic, strong) UdeskShareTransitioningDelegateImpl <UIViewControllerTransitioningDelegate> * transitioningDelegateImpl;

@end


@implementation UdeskTransitioningAnimation

///使用 singleton 的原因是使用这个 transition 的对象并没有维护这个 transition 对象，如果被释放 transition 则会失效，为了减少自定义 transition 对使用者的侵入，只好使用 singleton 来保持该对象
+ (instancetype)sharedInstance {
    static UdeskTransitioningAnimation *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [UdeskTransitioningAnimation new];
    });
    
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.transitioningDelegateImpl = [UdeskShareTransitioningDelegateImpl new];
    }
    return self;
}

+ (void)setInteractive:(BOOL)interactive {
    [UdeskTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactive = interactive;
}

+ (BOOL)isInteractive {
    return [UdeskTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactive;
}

+ (id <UIViewControllerTransitioningDelegate>)transitioningDelegateImpl {
    return [[self sharedInstance] transitioningDelegateImpl];
}

+ (void)updateInteractiveTransition:(CGFloat)percent {
    [[UdeskTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning updateInteractiveTransition:percent];
}

+ (void)cancelInteractiveTransition {
    [[UdeskTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning cancelInteractiveTransition];
    [UdeskTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning = nil;
}

+ (void)finishInteractiveTransition {
    [[UdeskTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning finishInteractiveTransition];
    [[UdeskTransitioningAnimation sharedInstance].transitioningDelegateImpl finishTransition];
    
}

#pragma mark -

+ (CATransition *)createPresentingTransiteAnimation:(UDTransiteAnimationType)animation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    switch (animation) {
        case UDTransiteAnimationTypePush:
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            break;
        case UDTransiteAnimationTypePresent:
        default:
            break;
    }
    return transition;
}
+ (CATransition *)createDismissingTransiteAnimation:(UDTransiteAnimationType)animation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    switch (animation) {
        case UDTransiteAnimationTypePush:
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromLeft;
            break;
        case UDTransiteAnimationTypePresent:
        default:
            break;
    }
    return transition;
}


@end
