//
//  UIBarButtonItem+UdeskSDK.h
//  UdeskSDK
//
//  Created by xuchen on 2017/12/15.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (UdeskSDK)

+ (UIBarButtonItem *)udItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)udItemWithIcon:(UIImage *)icon target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)udRightItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)udItemWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action;

@end
