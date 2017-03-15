//
//  UDOverlayTransitioningDelegate.h
//  UdeskSDK
//
//  Created by xuchen on 2017/3/13.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UDOverlayTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;
@end
