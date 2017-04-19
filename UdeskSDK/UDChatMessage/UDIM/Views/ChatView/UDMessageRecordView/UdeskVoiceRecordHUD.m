//
//  UDVoiceRecordHUD.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskVoiceRecordHUD.h"
#import "UdeskFoundationMacro.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskUtils.h"      

@interface UdeskVoiceRecordHUD ()

@property (nonatomic, weak) UIImageView *tooShortRecordImageView;


@end

@implementation UdeskVoiceRecordHUD

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化视图
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor clearColor];
    
    if (!_tooShortRecordImageView) {
        UIImageView *tooShortRecordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        UIImage *tooShortImage;
        
        
        NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
        NSArray* languages = [defs objectForKey:@"AppleLanguages"];
        NSString* preferredLang = [languages objectAtIndex:0];
        if ([preferredLang isEqualToString:@"zh-Hans-CN"]) {
            tooShortImage = [UIImage ud_defaultVoiceTooShortImageCN];
        }
        else {
        
            tooShortImage = [UIImage ud_defaultVoiceTooShortImageEN];
        }
        
        tooShortRecordImageView.image = tooShortImage;
        tooShortRecordImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        tooShortRecordImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:tooShortRecordImageView];
        _tooShortRecordImageView = tooShortRecordImageView;
    }

}

- (void)showTooShortRecord:(UIView *)view {
    
    CGPoint center = CGPointMake((CGRectGetWidth(view.frame) -140)/ 2.0, (CGRectGetHeight(view.frame)-140) / 2.0-44);
    self.center = center;
    [view addSubview:self];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
        self.alpha = 1.0;
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
