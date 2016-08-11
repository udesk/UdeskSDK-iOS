//
//  UIViewController+UdeskBackButtonHandler.h
//  UdeskSDK
//
//  Created by xuchen on 16/6/15.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UdeskBackButtonHandler)

@end

typedef void(^UDGestureBackAnimationBlock) ();

@interface UINavigationController (UdeskShouldPopOnBackButton)

@property (nonatomic, copy) UDGestureBackAnimationBlock gestureBack;

@end
