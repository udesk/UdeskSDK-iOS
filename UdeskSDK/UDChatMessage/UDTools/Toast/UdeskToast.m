//
//  UdeskToast.m
//  UdeskSDK
//
//  Created by xuchen on 2017/1/13.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskToast.h"
#import <UIKit/UIKit.h>

static const float kUDToastMaxWidth = 0.8; //window宽度的80%
static const float kUDToastFontSize = 14;
static const float kUDToastHorizontalSpacing = 8.0;
static const float kUDToastVerticalSpacing = 6.0;

@implementation UdeskToast

+ (void)showToast:(NSString*)message duration:(NSTimeInterval)interval window:(UIView*)window
{
    CGSize windowSize          = window.frame.size;

    UILabel* titleLabel        = [[UILabel alloc] init];
    titleLabel.numberOfLines   = 0;
    titleLabel.font            = [UIFont boldSystemFontOfSize:kUDToastFontSize];
    titleLabel.textAlignment   = NSTextAlignmentCenter;
    titleLabel.lineBreakMode   = NSLineBreakByWordWrapping;
    titleLabel.textColor       = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.alpha           = 1.0;
    titleLabel.text            = message;
    
    CGSize maxSizeTitle      = CGSizeMake(windowSize.width * kUDToastMaxWidth, windowSize.height);
    CGSize expectedSizeTitle = [message boundingRectWithSize:maxSizeTitle options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName : titleLabel.font } context:nil].size;
    titleLabel.frame         = CGRectMake(kUDToastHorizontalSpacing, kUDToastVerticalSpacing, expectedSizeTitle.width + 4, expectedSizeTitle.height);
    
    UIView* view             = [[UIView alloc] init];
    view.frame               = CGRectMake((windowSize.width - titleLabel.frame.size.width) / 2 - kUDToastHorizontalSpacing,
                                          windowSize.height * .6 - titleLabel.frame.size.height,
                                          titleLabel.frame.size.width + kUDToastHorizontalSpacing * 2,
                                          titleLabel.frame.size.height + kUDToastVerticalSpacing * 2);
    view.backgroundColor     = [UIColor colorWithWhite:.2 alpha:.7];
    view.alpha               = 0;
    view.layer.cornerRadius  = view.frame.size.height * .15;
    view.layer.masksToBounds = YES;
    [view addSubview:titleLabel];
    
    [window addSubview:view];
    [window bringSubviewToFront:view];

    [UIView animateWithDuration:.25 animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        if (interval > 0) {
            dispatch_time_t popTime =
            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView animateWithDuration:.25 animations:^{
                    view.alpha = 0;
                } completion:^(BOOL finished) {
                    [view removeFromSuperview];
                }];
            });
        }

    }];
}

@end
