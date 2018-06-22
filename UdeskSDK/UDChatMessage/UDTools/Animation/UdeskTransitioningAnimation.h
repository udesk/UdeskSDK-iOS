//
//  UdeskTransitioningAnimation.h
//  UdeskSDK
//
//  Created by Udesk on 16/7/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskAnimatorPush.h"
#import "UdeskShareTransitioningDelegateImpl.h"
#import "UdeskSDKConfig.h"

@interface UdeskTransitioningAnimation : NSObject

+ (id <UIViewControllerTransitioningDelegate>)transitioningDelegateImpl;

+ (CATransition *)createPresentingTransiteAnimation:(UDTransiteAnimationType)animation;

+ (CATransition *)createDismissingTransiteAnimation:(UDTransiteAnimationType)animation;

+ (void)setInteractive:(BOOL)interactive;

+ (BOOL)isInteractive;

+ (void)updateInteractiveTransition:(CGFloat)percent;

+ (void)cancelInteractiveTransition;

+ (void)finishInteractiveTransition;

@end
