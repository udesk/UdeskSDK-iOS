//
//  UIView+UdeskSDK.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/14.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UIView+UdeskSDK.h"

@implementation UIView (UdeskSDK)

- (CGSize)udSize {
    return self.frame.size;
}

- (void)setUdSize:(CGSize)udSize {
    CGRect newframe = self.frame;
    newframe.size = udSize;
    self.frame = newframe;
}

- (CGFloat)udX {
    return self.frame.origin.x;
}

- (void)setUdX:(CGFloat)udX {
    CGRect newframe = self.frame;
    newframe.origin.x = udX;
    self.frame = newframe;
}

- (CGFloat)udY {
    return self.frame.origin.y;
}

- (void)setUdY:(CGFloat)udY {
    
    CGRect newframe = self.frame;
    newframe.origin.y = udY;
    self.frame = newframe;
}

- (CGFloat)udCenterX {
    return self.center.x;
}

- (void)setUdCenterX:(CGFloat)udCenterX {
    self.center = CGPointMake(udCenterX, self.center.y);
}

- (CGFloat)udCenterY {
    return self.center.y;
}

- (void)setUdCenterY:(CGFloat)udCenterY {
    self.center = CGPointMake(self.center.x, udCenterY);
}

- (CGFloat)udHeight {
    return self.frame.size.height;
}

- (void)setUdHeight:(CGFloat)udHeight {
    CGRect newframe = self.frame;
    newframe.size.height = udHeight;
    self.frame = newframe;
}

- (CGFloat)udWidth {
    return self.frame.size.width;
}

- (void)setUdWidth:(CGFloat)udWidth {
    CGRect newframe = self.frame;
    newframe.size.width = udWidth;
    self.frame = newframe;
}

- (CGFloat)udTop {
    return self.frame.origin.y;
}

- (void)setUdTop:(CGFloat)udTop {
    CGRect newframe = self.frame;
    newframe.origin.y = udTop;
    self.frame = newframe;
}

- (CGFloat)udLeft {
    return self.frame.origin.x;
}

- (void)setUdLeft:(CGFloat)udLeft {
    CGRect newframe = self.frame;
    newframe.origin.x = udLeft;
    self.frame = newframe;
}

- (CGFloat)udBottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setUdBottom:(CGFloat)udBottom {
    CGRect newframe = self.frame;
    newframe.origin.y = udBottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat)udRight {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setUdRight:(CGFloat)udRight {
    CGFloat delta = udRight - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

- (UIViewController *)udViewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
