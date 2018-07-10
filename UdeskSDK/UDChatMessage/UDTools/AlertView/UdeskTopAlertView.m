//
//  UdeskTopAlertView.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskTopAlertView.h"
#import "UdeskSDKMacro.h"
#import "UdeskSDKUtil.h"

#define UD_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;

#define hsb(h,s,b) [UIColor colorWithHue:h/360.0f saturation:s/100.0f brightness:b/100.0f alpha:1.0]

#define FlatSkyBlue hsb(204, 76, 86)
#define FlatGreen hsb(145, 77, 80)
#define FlatOrange hsb(28, 85, 90)
#define FlatRed hsb(6, 74, 91)
#define FlatSkyBlueDark hsb(204, 78, 73)
#define FlatGreenDark hsb(145, 78, 68)
#define FlatOrangeDark hsb(24, 100, 83)
#define FlatRedDark hsb(6, 78, 75)

@interface UdeskTopAlertView ()

@property (nonatomic, copy) dispatch_block_t nextTopAlertBlock;

@end

@implementation UdeskTopAlertView

- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (BOOL)hasViewWithParentView:(UIView*)parentView{
    if ([self viewWithParentView:parentView]) {
        return YES;
    }
    return NO;
}

+ (UdeskTopAlertView*)viewWithParentView:(UIView*)parentView{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[UdeskTopAlertView class]]) {
            return (UdeskTopAlertView *)view;
        }
    }
    return nil;
}

+ (UdeskTopAlertView*)viewWithParentView:(UIView*)parentView cur:(UIView*)cur{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[UdeskTopAlertView class]] && view!=cur) {
            return (UdeskTopAlertView *)view;
        }
    }
    return nil;
}

+ (void)hideViewWithParentView:(UIView*)parentView{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[UdeskTopAlertView class]]) {
            UdeskTopAlertView *alert = (UdeskTopAlertView *)view;
            [alert hide];
        }
    }
}

+ (void)showWithCode:(NSInteger)code withMessage:(NSString *)message parentView:(UIView*)parentView {
    if (!message || message == (id)kCFNull) return ;
    if (![message isKindOfClass:[NSString class]]) return ;
    
    UDAlertType type;
    
    if (code == 2000) {
        type = UDAlertTypeGreen;
    }
    else if (code == 2001) {
        type = UDAlertTypeSkyBlue;
    }
    else if (code == 2002) {
        type = UDAlertTypeOrange;
    }
    else {
        type = UDAlertTypeRed;
    }
    
    [UdeskTopAlertView showAlertType:type withMessage:message parentView:parentView];
}

+ (UdeskTopAlertView *)showAlertType:(UDAlertType)type
                         withMessage:(NSString *)message
                          parentView:(UIView*)parentView {

    UdeskTopAlertView *alertView = [[UdeskTopAlertView alloc] initWithAlertType:type withMessage:message];
    [parentView addSubview:alertView];
    [alertView show];
    return alertView;
}

- (instancetype)initWithAlertType:(UDAlertType)type withMessage:(NSString *)message// parentView:(UIView*)parentView
{
    self = [super init];
    if (self) {
        [self setTypeWithAlertType:type withMessage:message];
    }
    return self;
}

- (void)setTypeWithAlertType:(UDAlertType)type
                 withMessage:(NSString *)message {
    
    if ([UdeskSDKUtil isBlankString:message]) {
        message = @"";
    }
    
    _autoHide = YES;
    _duration = 1.8;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    [self setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - width)*0.5, -40, width, 40)];
    self.alpha = .9f;
    if (type == UDAlertTypeGreen) {
        
        self.backgroundColor = FlatGreen;
    }
    else if (type == UDAlertTypeSkyBlue) {
    
        self.backgroundColor = FlatSkyBlue;
    }
    else if (type == UDAlertTypeOrange) {
        
        self.backgroundColor = FlatOrange;
    }
    else {
    
        self.backgroundColor = FlatRed;
    }
    
    CGFloat textLabelWidth = width*0.8;
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake((width - textLabelWidth)*0.5, 0, textLabelWidth, CGRectGetHeight(self.frame))];
    textLabel.backgroundColor = [UIColor clearColor];
    [textLabel setTextColor:[UIColor whiteColor]];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:13];
    textLabel.text = message;
    [self addSubview:textLabel];
    
}

- (void)show{
    dispatch_block_t showBlock = ^{
        
        if (ud_isIOS6) {
            
            [UIView animateWithDuration:0.65f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y + 40);
            } completion:^(BOOL finished) {

                [UIView animateWithDuration:0.65 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                } completion:nil];
            }];
        } else {
        
            [UIView animateWithDuration:0.65 delay:0 usingSpringWithDamping:.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
                self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y + 40);
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:.65 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
                } completion:^(BOOL finished) {
                }];
            }];
        }
        
        [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
    };
    
    UdeskTopAlertView *lastAlert = [UdeskTopAlertView viewWithParentView:self.superview cur:self];
    if (lastAlert) {
        lastAlert.nextTopAlertBlock = ^{
            showBlock();
        };
        [lastAlert hide];
    }else{
        showBlock();
    }
}

- (void)hide{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [UIView animateWithDuration:0.35 animations:^{
        self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y - 40);
    } completion:^(BOOL finished) {
        if (_nextTopAlertBlock) {
            _nextTopAlertBlock();
            _nextTopAlertBlock = nil;
        }
        [self removeFromSuperview];
    }];

    if (_dismissBlock) {
        _dismissBlock();
        _dismissBlock = nil;
    }
}

-(void)setDuration:(NSInteger)duration{
    _duration = duration;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
}

-(void)setAutoHide:(BOOL)autoHide{
    if (autoHide && !_autoHide) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    }
    _autoHide = autoHide;
}

-(void)dealloc{
    _dismissBlock = nil;
    _nextTopAlertBlock = nil;
}

@end
