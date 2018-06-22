//
//  UIView+UdeskSDK.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/14.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UdeskSDK)

@property (nonatomic) CGSize udSize;

@property (nonatomic) CGFloat udX;
@property (nonatomic) CGFloat udY;

@property (nonatomic) CGFloat udHeight;
@property (nonatomic) CGFloat udWidth;

@property (nonatomic) CGFloat udTop;
@property (nonatomic) CGFloat udLeft;

@property (nonatomic) CGFloat udBottom;
@property (nonatomic) CGFloat udRight;

@property (nonatomic) CGFloat udCenterX;

@property (nonatomic) CGFloat udCenterY;

- (UIViewController *)udViewController;

@end
