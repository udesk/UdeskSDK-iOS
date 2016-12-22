//
//  UdeskShareTransitioningDelegateImpl.h
//  UdeskSDK
//
//  Created by xuchen on 16/7/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskShareTransitioningDelegateImpl : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning> *interactiveTransitioning;

- (void)finishTransition;
@end
