//
//  UdeskExpressionSurveyView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskExpressionSurveyView.h"
#import "UdeskSurveyModel.h"
#import "UdeskButton.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskBundleUtils.h"
#import "UIView+UdeskSDK.h"
#import "UdeskSDKMacro.h"

static CGFloat kUDSurveyExpressionSize = 90;
static CGFloat kUDSurveyExpressionSpacing = 13;
static CGFloat kUDSurveyExpressionToVerticalEdgeSpacing = 10;

@interface UdeskExpressionSurveyView()

@property (nonatomic, strong) UIImageView *satisfiedImageView;
@property (nonatomic, strong) UIImageView *generalImageView;
@property (nonatomic, strong) UIImageView *unsatisfactoryImageView;

@property (nonatomic, strong) UILabel *satisfiedLabel;
@property (nonatomic, strong) UILabel *generalLabel;
@property (nonatomic, strong) UILabel *unsatisfactoryLabel;

@property (nonatomic, strong) UIView  *satisfiedView;
@property (nonatomic, strong) UIView  *generalView;
@property (nonatomic, strong) UIView  *unsatisfactoryView;

@end

@implementation UdeskExpressionSurveyView

- (instancetype)initWithExpressionSurvey:(UdeskExpressionSurvey *)expressionSurvey
{
    self = [super init];
    if (self) {
        _expressionSurvey = expressionSurvey;
    }
    return self;
}

- (void)setExpressionSurvey:(UdeskExpressionSurvey *)expressionSurvey {
    if (!expressionSurvey || expressionSurvey == (id)kCFNull) return ;
    _expressionSurvey = expressionSurvey;
    
    _satisfiedView = [self expressionView];
    [_satisfiedView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSatisfiedAction)]];
    [self addSubview:_satisfiedView];
    _satisfiedImageView = [self expressionImageViewWithImage:[UIImage udDefaultSurveyExpressionSatisfiedImage]];
    [_satisfiedView addSubview:_satisfiedImageView];
    _satisfiedLabel = [self expressionLabelWithTitle:getUDLocalizedString(@"udesk_survey_satisfied")];
    [_satisfiedView addSubview:_satisfiedLabel];
    
    _generalView = [self expressionView];
    [_generalView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGeneralAction)]];
    [self addSubview:_generalView];
    _generalImageView = [self expressionImageViewWithImage:[UIImage udDefaultSurveyExpressionGeneralImage]];
    [_generalView addSubview:_generalImageView];
    _generalLabel = [self expressionLabelWithTitle:getUDLocalizedString(@"udesk_survey_general")];
    [_generalView addSubview:_generalLabel];
    
    _unsatisfactoryView = [self expressionView];
    [_unsatisfactoryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUnsatisfactoryAction)]];
    [self addSubview:_unsatisfactoryView];
    _unsatisfactoryImageView = [self expressionImageViewWithImage:[UIImage udDefaultSurveyExpressionUnsatisfactoryImage]];
    [_unsatisfactoryView addSubview:_unsatisfactoryImageView];
    _unsatisfactoryLabel = [self expressionLabelWithTitle:getUDLocalizedString(@"udesk_survey_unsatisfactory")];
    [_unsatisfactoryView addSubview:_unsatisfactoryLabel];
    
    NSArray *optionIds = [expressionSurvey.options valueForKey:@"optionId"];
    if ([optionIds containsObject:expressionSurvey.defaultOptionId]) {
        NSInteger index = [optionIds indexOfObject:expressionSurvey.defaultOptionId];
        [self updateSelectedViewWithIndex:index];
    }
}

//满意
- (void)didTapSatisfiedAction {
    
    [self updateViewUIWithFirstView:self.generalView secondView:self.unsatisfactoryView];
    [self updateSelectedViewWithIndex:0];
    
    [self callbackClickWithIndex:0];
}

//一般
- (void)didTapGeneralAction {
    
    [self updateViewUIWithFirstView:self.satisfiedView secondView:self.unsatisfactoryView];
    [self updateSelectedViewWithIndex:1];
    
    [self callbackClickWithIndex:1];
}

//不满意
- (void)didTapUnsatisfactoryAction {
    
    [self updateViewUIWithFirstView:self.satisfiedView secondView:self.generalView];
    [self updateSelectedViewWithIndex:2];
    
    [self callbackClickWithIndex:2];
}

- (void)updateSelectedViewWithIndex:(NSInteger)index {
    
    if (index == 0) {
        self.satisfiedView.backgroundColor = [UIColor colorWithRed:0.914f  green:0.98f  blue:0.937f alpha:1];
        self.satisfiedView.layer.borderColor = [UIColor colorWithRed:0.576f  green:0.902f  blue:0.682f alpha:1].CGColor;
    }
    else if (index == 1) {
        self.generalView.backgroundColor = [UIColor colorWithRed:1  green:0.969f  blue:0.89f alpha:1];
        self.generalView.layer.borderColor = [UIColor colorWithRed:1  green:0.835f  blue:0.478f alpha:1].CGColor;
    }
    else if (index == 2) {
        self.unsatisfactoryView.backgroundColor = [UIColor colorWithRed:1  green:0.922f  blue:0.922f alpha:1];
        self.unsatisfactoryView.layer.borderColor = [UIColor colorWithRed:1  green:0.608f  blue:0.6f alpha:1].CGColor;
    }
}

- (void)updateViewUIWithFirstView:(UIView *)firstView secondView:(UIView *)secondView {
    
    firstView.backgroundColor = [UIColor whiteColor];
    firstView.layer.borderColor = [UIColor colorWithRed:1  green:0.969f  blue:0.89f alpha:1].CGColor;
    
    secondView.backgroundColor = [UIColor whiteColor];
    secondView.layer.borderColor = [UIColor colorWithRed:1  green:0.969f  blue:0.89f alpha:1].CGColor;
}

- (void)callbackClickWithIndex:(NSInteger)index {
    
    if (self.expressionSurvey.options.count > index) {
     
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectExpressionSurveyWithOption:)]) {
            [self.delegate didSelectExpressionSurveyWithOption:self.expressionSurvey.options[index]];
        }
    }
}

- (UIView *)expressionView {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    UDViewBorderRadius(view, 2, 1, [UIColor colorWithRed:0.937f  green:0.937f  blue:0.937f alpha:1]);
    
    return view;
}

- (UIImageView *)expressionImageViewWithImage:(UIImage *)image {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    return imageView;
}

- (UILabel *)expressionLabelWithTitle:(NSString *)title {
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = [UIColor colorWithRed:0.6f  green:0.6f  blue:0.6f alpha:1];
    label.font = [UIFont systemFontOfSize:12.0];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _satisfiedView.frame = CGRectMake((self.udWidth-(kUDSurveyExpressionSize*3 + kUDSurveyExpressionSpacing*2))/2, kUDSurveyExpressionToVerticalEdgeSpacing, kUDSurveyExpressionSize, kUDSurveyExpressionSize);
    
    CGSize satisfiedSize = _satisfiedImageView.image.size;
    _satisfiedImageView.frame = CGRectMake((_satisfiedView.udWidth-satisfiedSize.width)/2, kUDSurveyExpressionToVerticalEdgeSpacing, satisfiedSize.width, satisfiedSize.height);
    _satisfiedLabel.frame = CGRectMake(0, _satisfiedImageView.udBottom+16, _satisfiedView.udWidth, 20);
    
    
    _generalView.frame = CGRectMake(_satisfiedView.udRight+kUDSurveyExpressionSpacing, kUDSurveyExpressionToVerticalEdgeSpacing, kUDSurveyExpressionSize, kUDSurveyExpressionSize);
    
    CGSize generalSize = _generalImageView.image.size;
    _generalImageView.frame = CGRectMake((_satisfiedView.udWidth-generalSize.width)/2, kUDSurveyExpressionToVerticalEdgeSpacing, generalSize.width, generalSize.height);
    _generalLabel.frame = CGRectMake(0, _generalImageView.udBottom+16, _generalView.udWidth, 20);
    
    _unsatisfactoryView.frame = CGRectMake(_generalView.udRight+kUDSurveyExpressionSpacing, kUDSurveyExpressionToVerticalEdgeSpacing, kUDSurveyExpressionSize, kUDSurveyExpressionSize);
    
    CGSize unsatisfactorySize = _unsatisfactoryImageView.image.size;
    _unsatisfactoryImageView.frame = CGRectMake((_satisfiedView.udWidth-unsatisfactorySize.width)/2, kUDSurveyExpressionToVerticalEdgeSpacing, unsatisfactorySize.width, unsatisfactorySize.height);
    _unsatisfactoryLabel.frame = CGRectMake(0, _unsatisfactoryImageView.udBottom+16, _unsatisfactoryView.udWidth, 20);
    
}

@end
