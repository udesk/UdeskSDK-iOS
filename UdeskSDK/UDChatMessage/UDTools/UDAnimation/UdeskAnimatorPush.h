//
//  UdeskAnimatorPush.h
//  UdeskSDK
//
//  Created by xuchen on 16/7/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskAnimatorPush : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property (nonatomic, assign) BOOL isPresenting;

@end
