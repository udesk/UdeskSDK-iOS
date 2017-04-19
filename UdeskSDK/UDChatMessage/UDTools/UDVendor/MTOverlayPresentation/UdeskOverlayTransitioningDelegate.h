//
//  UdeskOverlayTransitioningDelegate.h
//  UdeskSDK
//
//  Created by Udesk on 2017/3/13.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskOverlayTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;
@end
