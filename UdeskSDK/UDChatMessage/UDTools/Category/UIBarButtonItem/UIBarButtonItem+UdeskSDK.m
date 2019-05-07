//
//  UIBarButtonItem+UdeskSDK.m
//  UdeskSDK
//
//  Created by xuchen on 2017/12/15.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UIBarButtonItem+UdeskSDK.h"
#import "UIView+UdeskSDK.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKConfig.h"
#import "UdeskStringSizeUtil.h"

@implementation UIBarButtonItem (UdeskSDK)

+ (UIBarButtonItem *)udLeftItemWithIcon:(UIImage *)icon target:(id)target action:(SEL)action {
    
    @try {
        
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [customView addGestureRecognizer:tap];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        if (icon) {
            [btn setBackgroundImage:icon forState:UIControlStateNormal];
        }
        btn.frame = CGRectMake(0, 0, btn.currentBackgroundImage.size.width, btn.currentBackgroundImage.size.height);
        btn.udCenterY = customView.udCenterY;
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [customView addSubview:btn];
        return [[UIBarButtonItem alloc] initWithCustomView:customView];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

+ (UIBarButtonItem *)udLeftItemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    
    return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
}

+ (UIBarButtonItem *)udItemWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action {
    
    @try {
        
        UIImage *backImage = image;
        CGSize backTextSize = [UdeskStringSizeUtil sizeWithText:title font:[UIFont systemFontOfSize:17] size:CGSizeMake(70, 30)];
        
        UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBarButton.frame = CGRectMake(0, 0, backTextSize.width+backImage.size.width+20, backTextSize.height);
        [leftBarButton setTitle:title forState:UIControlStateNormal];
        backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [leftBarButton setImage:backImage forState:UIControlStateNormal];
        [leftBarButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        [leftBarButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        
        if (ud_isIOS11) {
            leftBarButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
            [leftBarButton setImageEdgeInsets:UIEdgeInsetsMake(0, -8 * UD_SCREEN_WIDTH/375.0,0,0)];
            [leftBarButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -6 * UD_SCREEN_WIDTH/375.0,0,0)];
        }
        
        return [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

+ (UIBarButtonItem *)udRightItemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    
    @try {
        
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [customView addGestureRecognizer:tap];
        
        CGSize transferTextSize = [UdeskStringSizeUtil sizeWithText:title font:[UIFont systemFontOfSize:10] size:CGSizeMake(85, 44)];
        UIImage *rightImage = [UIImage udDefaultTransferImage];
        
        //导航栏右键
        UIButton *navBarRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [navBarRightButton setTitle:title forState:UIControlStateNormal];
        [navBarRightButton setImage:rightImage forState:UIControlStateNormal];
        navBarRightButton.frame = CGRectMake(CGRectGetWidth(customView.frame)-transferTextSize.width, 0, transferTextSize.width, 44);
        navBarRightButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [navBarRightButton setTitleColor:[UdeskSDKConfig customConfig].sdkStyle.transferButtonColor forState:UIControlStateNormal];
        
        [self setEdgeInsets:navBarRightButton];
        [navBarRightButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        [customView addSubview:navBarRightButton];
        return [[UIBarButtonItem alloc] initWithCustomView:customView];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

+ (void)setEdgeInsets:(UIButton *)btn {
    if (!btn || btn == (id)kCFNull) return ;
    
    float  spacing = 1;//图片和文字的上下间距
    
    CGSize imageSize = btn.imageView.frame.size;
    CGSize titleSize = btn.titleLabel.frame.size;
    CGSize textSize = [btn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : btn.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    btn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
}

@end
