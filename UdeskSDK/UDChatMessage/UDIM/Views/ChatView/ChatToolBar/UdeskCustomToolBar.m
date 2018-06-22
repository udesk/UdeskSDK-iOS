//
//  UdeskCustomToolBar.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/21.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskCustomToolBar.h"
#import "UdeskCustomButtonConfig.h"
#import "UdeskButton.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskSDKMacro.h"
#import "UdeskButton.h"
#import "UdeskBundleUtils.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKConfig.h"

static CGFloat kUdeskCustomButtonHeight = 30;
static CGFloat kUdeskCustomSurveySpacing = 11;

@interface UdeskCustomToolBar()

@property (nonatomic, strong) UIScrollView  *scrollview;
@property (nonatomic, strong) UdeskButton   *surveyButton;
@property (nonatomic, strong) NSArray *customButtonConfigs;
@property (nonatomic, strong) NSMutableArray *customButtons;
@property (nonatomic, assign) BOOL enableSurvey;

@end

@implementation UdeskCustomToolBar

- (instancetype)initWithFrame:(CGRect)frame customButtonConfigs:(NSArray<UdeskCustomButtonConfig *> *)customButtonConfigs enableSurvey:(BOOL)enableSurvey
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _enableSurvey = enableSurvey;
        _customButtonConfigs = customButtonConfigs;
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    _scrollview = [[UIScrollView alloc] init];
    _scrollview.canCancelContentTouches = NO;
    _scrollview.delaysContentTouches = YES;
    _scrollview.backgroundColor = self.backgroundColor;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    [_scrollview setScrollsToTop:NO];
    _scrollview.pagingEnabled = YES;
    [self addSubview:_scrollview];
    
    if (self.enableSurvey && [UdeskSDKConfig customConfig].showTopCustomButtonSurvey) {
        _surveyButton = [UdeskButton buttonWithType:UIButtonTypeCustom];
        [_surveyButton setTitle:getUDLocalizedString(@"udesk_service_survey") forState:UIControlStateNormal];
        [_surveyButton setImage:[UIImage udDefaultCustomToolBarSurveyImage] forState:UIControlStateNormal];
        [_surveyButton addTarget:self action:@selector(didTapSurveyAction:) forControlEvents:UIControlEventTouchUpInside];
        [_surveyButton setTitleColor:[UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1] forState:UIControlStateNormal];
        _surveyButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _surveyButton.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
        [self addSubview:_surveyButton];
    }
    
    if (!self.customButtonConfigs || self.customButtonConfigs == (id)kCFNull) return ;
    if (!self.customButtonConfigs.count) return;
    if (![self.customButtonConfigs.firstObject isKindOfClass:[UdeskCustomButtonConfig class]]) return;
    
    for (UdeskCustomButtonConfig *customButton in self.customButtonConfigs) {
        if (![customButton isKindOfClass:[UdeskCustomButtonConfig class]]) return;
        
        if (customButton.type == UdeskCustomButtonConfigTypeInInputTop) {
            
            UdeskButton *button = [UdeskButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(customButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:customButton.title forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:[UIColor colorWithRed:0.471f  green:0.471f  blue:0.471f alpha:1] forState:UIControlStateNormal];
            button.tag = 9447 + [self.customButtonConfigs indexOfObject:customButton];
            UDViewBorderRadius(button, 13, 1, [UIColor colorWithRed:0.906f  green:0.906f  blue:0.906f alpha:1]);
            [self.scrollview addSubview:button];
            [self.customButtons addObject:button];
        }
    }
}

- (void)didTapSurveyAction:(UdeskButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapSurveyAction:)]) {
        [self.delegate didTapSurveyAction:self];
    }
}

- (void)customButtonAction:(UdeskButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCustomToolBar:atIndex:)]) {
        [self.delegate didSelectCustomToolBar:self atIndex:button.tag - 9447];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.enableSurvey) {
        CGFloat surveyButtonWidth = [UdeskStringSizeUtil textSize:_surveyButton.titleLabel.text withFont:_surveyButton.titleLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame)-1)].width + 20;
        _surveyButton.frame = CGRectMake(CGRectGetWidth(self.frame)-surveyButtonWidth-kUdeskCustomSurveySpacing, 0, surveyButtonWidth, CGRectGetHeight(self.frame)-1);
    }
    
    if (!self.customButtons.count) return;
    CGFloat scrollViewWidth = self.enableSurvey ? CGRectGetWidth(self.frame)-CGRectGetWidth(self.surveyButton.frame)-(kUdeskCustomSurveySpacing*2) : CGRectGetWidth(self.frame);
    _scrollview.frame = CGRectMake(0, 0, scrollViewWidth, CGRectGetHeight(self.frame)-1);
    
    CGFloat paddingX = 10;
    CGFloat contentSpace = 20;
    NSMutableArray *array = [NSMutableArray array];
    for (UdeskButton *button in self.customButtons) {
        
        @try {
         
            NSInteger index = [self.customButtons indexOfObject:button];
            CGSize buttonSize = [UdeskStringSizeUtil textSize:button.titleLabel.text withFont:button.titleLabel.font withSize:CGSizeMake(CGFLOAT_MAX, kUdeskCustomButtonHeight)];
            
            UdeskButton *previousButton;
            if (index-1 < self.customButtons.count && index > 0) {
                previousButton = self.customButtons[index-1];
            }
            
            button.frame = CGRectMake(paddingX + CGRectGetMaxX(previousButton.frame), (CGRectGetHeight(self.scrollview.frame)-kUdeskCustomButtonHeight)/2, buttonSize.width + contentSpace, kUdeskCustomButtonHeight);
            [array addObject:@(CGRectGetWidth(button.frame))];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    UdeskButton *lastButton = self.customButtons.lastObject;
    [_scrollview setContentSize:CGSizeMake(CGRectGetMaxX(lastButton.frame) + paddingX, CGRectGetHeight(_scrollview.bounds))];
}

- (NSMutableArray *)customButtons {
    if (!_customButtons) {
        _customButtons = [NSMutableArray array];
    }
    return _customButtons;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.9 alpha:1].CGColor);
    
    CGContextMoveToPoint(ctx, 0, 44);
    CGContextAddLineToPoint(ctx, rect.size.width, 44);
    
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}

@end
