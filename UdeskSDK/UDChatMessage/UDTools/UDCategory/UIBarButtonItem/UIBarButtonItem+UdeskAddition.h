//
//  UIBarButtonItem+UdeskAddition.h
//  UdeskSDK
//
//  Created by xuchen on 2017/12/15.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (UdeskAddition)

+ (UIBarButtonItem *)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)itemWithIcon:(UIImage *)icon target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)rightItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end
