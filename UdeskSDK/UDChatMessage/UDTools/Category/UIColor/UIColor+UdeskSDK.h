//
//  UIColor+UdeskSDK.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UdeskSDK)

//16进制颜色转换
+ (UIColor *)udColorWithHexString:(NSString *)color;

@end
