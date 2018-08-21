//
//  UdeskTextSurveyView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskTextSurveyView.h"
#import "UdeskSurveyModel.h"
#import "UdeskButton.h"
#import "UIImage+UdeskSDK.h"
#import "UIView+UdeskSDK.h"

/** 按钮间距 */
const CGFloat kUDTextSurveyButtonToVerticalEdgeSpacing = 18;
/** 按钮高度 */
const CGFloat kUDTextSurveyButtonHeight = 22;

@interface UdeskTextSurveyView()

@end

@implementation UdeskTextSurveyView

- (instancetype)initWithTextSurvey:(UdeskTextSurvey *)textSurvey
{
    self = [super init];
    if (self) {
        _textSurvey = textSurvey;
    }
    return self;
}

- (void)setTextSurvey:(UdeskTextSurvey *)textSurvey {
    if (!textSurvey || textSurvey == (id)kCFNull) return ;
    _textSurvey = textSurvey;
    
    NSArray *enabledTextSurvey = [textSurvey.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"enabled>0"]];
    for (UdeskSurveyOption *option in enabledTextSurvey) {
        
        NSInteger index = [enabledTextSurvey indexOfObject:option];
        UdeskButton *button = [UdeskButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor colorWithRed:0.2f  green:0.2f  blue:0.2f alpha:1] forState:UIControlStateNormal];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.tag = 9898+index;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setImage:[UIImage udDefaultSurveyTextNotSelectImage] forState:UIControlStateNormal];
        [button setImage:[UIImage udDefaultSurveyTextSelectedImage] forState:UIControlStateSelected];
        [button setTitle:option.text forState:UIControlStateNormal];
        button.selected = [textSurvey.defaultOptionId isEqual:option.optionId];
        
        [button addTarget:self action:@selector(selectTextSurveyOptionAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)selectTextSurveyOptionAction:(UdeskButton *)button {
 
    @try {
        
        for (UdeskButton *button in self.subviews) {
            button.selected = NO;
        }
        button.selected = !button.selected;
        
        NSArray *enabledTextSurvey = [self.textSurvey.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"enabled>0"]];
        NSInteger index = button.tag - 9898;
        
        if (index >= 0 && enabledTextSurvey.count > index) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectExpressionSurveyWithOption:)]) {
                [self.delegate didSelectExpressionSurveyWithOption:enabledTextSurvey[index]];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UdeskButton *button in self.subviews) {
        if ([button isKindOfClass:[UdeskButton class]]) {
            NSInteger index = [self.subviews indexOfObject:button];
            button.frame = CGRectMake(0, index*(kUDTextSurveyButtonToVerticalEdgeSpacing+kUDTextSurveyButtonHeight), self.udWidth, kUDTextSurveyButtonHeight);
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
