//
//  UdeskSurveyContentView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/2.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSurveyContentView.h"
#import "UdeskSurveyModel.h"
#import "UdeskSurveyProtocol.h"
#import "UdeskSDKMacro.h"
#import "UIView+UdeskSDK.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKUtil.h"
#import "UdeskStringSizeUtil.h"

const CGFloat kUDSurveyRemarkTextViewHeight = 38;
const CGFloat kUDSurveyRemarkTextViewMaxHeight = 80;
const CGFloat kUDSurveySubmitButtonSpacing = 25;
const CGFloat kUDSurveySubmitButtonHeight = 44;
const CGFloat kUDSurveyContentSpacing = 40;
const CGFloat kUDSurveyCollectionViewItemSizeHeight = 30;
const CGFloat kUDSurveyCollectionViewItemSizeWidth = 135;
const CGFloat kUDSurveyCollectionViewItemToVerticalEdgeSpacing = 18;
const CGFloat kUDSurveyTagsCollectionViewMinimumLineSpacing = 14;
const CGFloat kUDSurveyTagsCollectionViewMinimumInteritemSpacing = 5;
const CGFloat kUDSurveyTagsCollectionViewMaxHeight = 120;
const CGFloat kUDSurveyStarOptionHeight = 100;
const CGFloat kUDSurveyExpressionOptionHeight = 100;
const CGFloat kUDSurveyOptionToVerticalEdgeSpacing = 25;
const CGFloat kUDSurveyTitleHeight = 58;
const CGFloat kUDSurveyRemarkRequiredLabelToVerticalEdgeSpacing = 5;

static NSString *kUDSurveyTagsCollectionViewCellReuseIdentifier = @"kUDSurveyTagsCollectionViewCellReuseIdentifier";

@interface UdeskSurveyContentView()<UICollectionViewDataSource,UICollectionViewDelegate,UITextViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UdeskSurveyProtocol>

@property (nonatomic, strong) NSArray  *allOptionTags;
@property (nonatomic, strong, readwrite) NSNumber *selectedOptionId;
@property (nonatomic, strong, readwrite) NSArray  *selectedOptionTags;

@end

@implementation UdeskSurveyContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _contentScrollerView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _contentScrollerView.delegate = self;
    _contentScrollerView.userInteractionEnabled = YES;
    [self addSubview:_contentScrollerView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScrollerViewAction)];
    tap.delegate = self;
    [_contentScrollerView addGestureRecognizer:tap];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kUDSurveyCollectionViewItemSizeWidth / 375.0 * [UIScreen mainScreen].bounds.size.width, kUDSurveyCollectionViewItemSizeHeight);
    layout.minimumInteritemSpacing = kUDSurveyTagsCollectionViewMinimumInteritemSpacing;
    layout.minimumLineSpacing = kUDSurveyTagsCollectionViewMinimumLineSpacing;
    
    _tagsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _tagsCollectionView.delegate = self;
    _tagsCollectionView.dataSource = self;
    _tagsCollectionView.backgroundColor = [UIColor whiteColor];
    [_tagsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kUDSurveyTagsCollectionViewCellReuseIdentifier];
    [_contentScrollerView addSubview:_tagsCollectionView];
    
    _remarkTextView = [[UdeskHPGrowingTextView alloc] initWithFrame:CGRectZero];
    _remarkTextView.font = [UIFont systemFontOfSize:15];
    _remarkTextView.backgroundColor = [UIColor colorWithRed:0.969f  green:0.969f  blue:0.969f alpha:1];
    _remarkTextView.returnKeyType = UIReturnKeyDone;
    _remarkTextView.delegate = (id)self;
    UDViewBorderRadius(_remarkTextView, 2, 1, [UIColor colorWithRed:0.937f  green:0.937f  blue:0.937f alpha:1]);
    [_contentScrollerView addSubview:_remarkTextView];
    
    _remarkRequiredLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _remarkRequiredLabel.font = [UIFont systemFontOfSize:10];
    _remarkRequiredLabel.textColor = [UIColor colorWithRed:0.804f  green:0.247f  blue:0.192f alpha:1];
    [_contentScrollerView addSubview:_remarkRequiredLabel];
    
    _submitButton = [[UdeskButton alloc] initWithFrame:CGRectZero];
    _submitButton.backgroundColor = [UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1];
    [_submitButton setTitle:getUDLocalizedString(@"udesk_submit_survey") forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(submitSurvetAction:) forControlEvents:UIControlEventTouchUpInside];
    UDViewRadius(_submitButton, 2);
    [_contentScrollerView addSubview:_submitButton];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIScrollView"]) {
        return YES;
    }
    
    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!self.surveyModel || self.surveyModel == (id)kCFNull) return ;
    
    CGFloat surveyOptionHeight = 0;
    NSArray *options;
    
    switch (self.surveyModel.optionType) {
        case UdeskSurveyOptionTypeStar:{
            
            if (!self.surveyModel.star || self.surveyModel.star == (id)kCFNull) return ;
            if (!self.surveyModel.star.options || self.surveyModel.star.options == (id)kCFNull) return ;
            
            surveyOptionHeight = kUDSurveyStarOptionHeight;
            options = self.surveyModel.star.options;
            
            break;
        }
        case UdeskSurveyOptionTypeText:{
            
            if (!self.surveyModel.text || self.surveyModel.text == (id)kCFNull) return ;
            if (!self.surveyModel.text.options || self.surveyModel.text.options == (id)kCFNull) return ;
            
            NSArray *array = [self.surveyModel.text.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"enabled>0"]];
            
            surveyOptionHeight = array.count * ((kUDTextSurveyButtonToVerticalEdgeSpacing+kUDTextSurveyButtonHeight)) - kUDTextSurveyButtonToVerticalEdgeSpacing;
            options = self.surveyModel.text.options;
            
            break;
        }
        case UdeskSurveyOptionTypeExpression:{
            
            if (!self.surveyModel.expression || self.surveyModel.expression == (id)kCFNull) return ;
            if (!self.surveyModel.expression.options || self.surveyModel.expression.options == (id)kCFNull) return ;
            
            surveyOptionHeight = kUDSurveyExpressionOptionHeight;
            options = self.surveyModel.expression.options;
            
            break;
        }
        default:
            break;
    }
    
    //载体
    CGFloat scrollerViewHeight = self.udHeight > UD_SCREEN_HEIGHT ? (UD_SCREEN_HEIGHT-kUDSurveyTitleHeight) : self.udHeight;
    _contentScrollerView.frame = self.bounds;
    _contentScrollerView.udHeight = scrollerViewHeight;
    _contentScrollerView.contentSize = self.bounds.size;
    
    //选项
    CGRect surveyOptionViewFrame = CGRectMake(kUDSurveyContentSpacing, kUDSurveyOptionToVerticalEdgeSpacing, self.udWidth-(kUDSurveyContentSpacing*2), surveyOptionHeight);
    
    if (self.surveyModel.optionType == UdeskSurveyOptionTypeText) {
        self.textSurveyView.frame = surveyOptionViewFrame;
    }
    else if (self.surveyModel.optionType == UdeskSurveyOptionTypeStar) {
        self.starSurveyView.frame = surveyOptionViewFrame;
    }
    else if (self.surveyModel.optionType == UdeskSurveyOptionTypeExpression) {
        self.expressionSurveyView.frame = surveyOptionViewFrame;
    }
    
    //标签
    CGFloat tagsHeight = [self tagsHeightWidthOptions:options];
    CGFloat tagsCollectionHeight = tagsHeight > kUDSurveyTagsCollectionViewMaxHeight ? kUDSurveyTagsCollectionViewMaxHeight : tagsHeight;
    self.tagsCollectionView.frame = CGRectMake(kUDSurveyContentSpacing, CGRectGetMaxY(surveyOptionViewFrame)+kUDSurveyOptionToVerticalEdgeSpacing, self.udWidth-(kUDSurveyContentSpacing*2), tagsCollectionHeight);
    self.tagsCollectionView.contentSize = CGSizeMake(self.udWidth-(kUDSurveyContentSpacing*2), tagsHeight);
    
    UdeskRemarkOptionType optionType = [self remarkOptionTypeWithOptions:options];
    //备注
    CGFloat remarkY = tagsCollectionHeight ? self.tagsCollectionView.udBottom+kUDSurveyCollectionViewItemToVerticalEdgeSpacing : kUDSurveyOptionToVerticalEdgeSpacing + CGRectGetMaxY(surveyOptionViewFrame);
    CGFloat remarkEnabled = self.surveyModel.remarkEnabled.boolValue && optionType != UdeskRemarkOptionTypeHide;
    if (remarkEnabled) {
        
        CGFloat remarkHeight = kUDSurveyRemarkTextViewMaxHeight;
        if (self.keyboardHeight) {
            remarkHeight = MAX(kUDSurveyRemarkTextViewMaxHeight, self.remarkTextView.udHeight);
        }
        else {
            if (!self.remarkTextView.text.length) {
                CGFloat remarkPlaceholderHeight = [UdeskStringSizeUtil textSize:self.remarkTextView.placeholder withFont:self.remarkTextView.font withSize:CGSizeMake(self.udWidth-(kUDSurveyContentSpacing*3), MAXFLOAT)].height + 15;
                remarkHeight = MAX(kUDSurveyRemarkTextViewHeight, remarkPlaceholderHeight);
            }
            else {
                remarkHeight = kUDSurveyRemarkTextViewMaxHeight;
            }
        }

        self.remarkTextView.minHeight = remarkHeight;
        self.remarkTextView.frame = CGRectMake(kUDSurveyContentSpacing, remarkY, self.udWidth-(kUDSurveyContentSpacing*2), MAX(CGRectGetHeight(self.remarkTextView.frame), remarkHeight));
        
        if (optionType == UdeskRemarkOptionTypeRequired) {
            self.remarkRequiredLabel.frame = CGRectMake(kUDSurveyContentSpacing, self.remarkTextView.udBottom + kUDSurveyRemarkRequiredLabelToVerticalEdgeSpacing, self.udWidth-(kUDSurveyContentSpacing*2), 10);
        }
        else {
            self.remarkRequiredLabel.frame = CGRectZero;
        }
    }
    else {
        self.remarkTextView.frame = CGRectZero;
        self.remarkRequiredLabel.frame = CGRectZero;
    }
    
    CGFloat submitY = remarkEnabled ? self.remarkTextView.udBottom+kUDSurveySubmitButtonSpacing : remarkY;
    //提交按钮
    self.submitButton.frame = CGRectMake(kUDSurveyContentSpacing, submitY, self.udWidth-(kUDSurveyContentSpacing*2), kUDSurveySubmitButtonHeight);
    
    [self.tagsCollectionView reloadData];
}

//标签高度
- (CGFloat)tagsHeightWidthOptions:(NSArray *)options {
    
    @try {
        
        NSArray *selectedOption = [options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"optionId = %@",self.selectedOptionId]];
        if (!selectedOption.count) {
            return 0;
        }
        UdeskSurveyOption *optionModel = selectedOption.firstObject;
        if (!optionModel || optionModel == (id)kCFNull) return 0;
        self.selectedOptionId = optionModel.optionId;
        
        if (!optionModel.enabled.boolValue) {
            return 0;
        }
        
        if ([UdeskSDKUtil isBlankString:optionModel.tags]) {
            return 0;
        }
        
        self.allOptionTags = [optionModel.tags componentsSeparatedByString:@","];
        return (ceilf(self.allOptionTags.count/2.0)) * (kUDSurveyCollectionViewItemSizeHeight+kUDSurveyCollectionViewItemToVerticalEdgeSpacing) - (kUDSurveyCollectionViewItemToVerticalEdgeSpacing);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//备注
- (UdeskRemarkOptionType)remarkOptionTypeWithOptions:(NSArray *)options {
    
    @try {
        
        NSArray *selectedOption = [options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"optionId = %@",self.selectedOptionId]];
        UdeskSurveyOption *optionModel = selectedOption.firstObject;
        if (optionModel) {
            if ([optionModel isKindOfClass:[UdeskSurveyOption class]]) {
                return optionModel.remarkOptionType;
            }
        }
        return UdeskRemarkOptionTypeHide;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)setSurveyModel:(UdeskSurveyModel *)surveyModel {
    if (!surveyModel || surveyModel == (id)kCFNull) return ;
    _surveyModel = surveyModel;
    
    switch (surveyModel.optionType) {
        case UdeskSurveyOptionTypeStar:
            
            [self reloadStarSurvey];
            break;
        case UdeskSurveyOptionTypeText:
            
            [self reloadTextSurvey];
            break;
        case UdeskSurveyOptionTypeExpression:
            
            [self reloadExpressionSurvey];
            break;
            
        default:
            break;
    }
    
    //满意度评价标题
    if (self.surveyModel.remarkEnabled.boolValue) {
        self.remarkTextView.placeholder = self.surveyModel.remark;
        self.remarkRequiredLabel.text = [NSString stringWithFormat:@"* %@",getUDLocalizedString(@"udesk_survey_remark_required")];
    }
    else {
        self.remarkTextView.hidden = YES;
    }
    
    [self setNeedsLayout];
}

//文本模式
- (void)reloadTextSurvey {
    
    [self setDefaultOptionId:self.surveyModel.text.defaultOptionId options:self.surveyModel.text.options];
    
    _textSurveyView = [[UdeskTextSurveyView alloc] initWithFrame:CGRectZero];
    _textSurveyView.delegate = self;
    _textSurveyView.textSurvey = self.surveyModel.text;
    [self.contentScrollerView addSubview:self.textSurveyView];
}

//表情模式
- (void)reloadExpressionSurvey {
    
    [self setDefaultOptionId:self.surveyModel.expression.defaultOptionId options:self.surveyModel.expression.options];
    
    _expressionSurveyView = [[UdeskExpressionSurveyView alloc] initWithFrame:CGRectZero];
    _expressionSurveyView.delegate = self;
    _expressionSurveyView.expressionSurvey = self.surveyModel.expression;
    [self.contentScrollerView addSubview:_expressionSurveyView];
}

//星星模式
- (void)reloadStarSurvey {
    
    [self setDefaultOptionId:self.surveyModel.star.defaultOptionId options:self.surveyModel.star.options];
    
    _starSurveyView = [[UdeskStarSurveyView alloc] initWithFrame:CGRectZero];
    _starSurveyView.delegate = self;
    _starSurveyView.starSurvey = self.surveyModel.star;
    [self.contentScrollerView addSubview:_starSurveyView];
}

- (void)setDefaultOptionId:(NSNumber *)defaultOptionId options:(NSArray *)options {
    if (!defaultOptionId || defaultOptionId == (id)kCFNull) return ;
    if (!options || options == (id)kCFNull) return ;
    
    for (UdeskSurveyOption *option in options) {
        if ([option.optionId isEqualToNumber:defaultOptionId] && option.enabled.boolValue != NO) {
            self.selectedOptionId = option.optionId;
            break;
        }
    }
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight {
    _keyboardHeight = keyboardHeight;
    
    if (_keyboardHeight) {
        _remarkTextView.minHeight = MAX(kUDSurveyRemarkTextViewMaxHeight, _remarkTextView.udHeight);
        _remarkTextView.udHeight = MAX(kUDSurveyRemarkTextViewMaxHeight, _remarkTextView.udHeight);
        _remarkRequiredLabel.udTop = self.remarkTextView.udBottom+kUDSurveyRemarkRequiredLabelToVerticalEdgeSpacing;
        _submitButton.udTop = self.remarkTextView.udBottom+kUDSurveySubmitButtonSpacing;
    }
    else {
        if (!_remarkTextView.text.length) {
            CGFloat remarkPlaceholderHeight = [UdeskStringSizeUtil textSize:self.remarkTextView.placeholder withFont:self.remarkTextView.font withSize:CGSizeMake(self.udWidth-(kUDSurveyContentSpacing*3), MAXFLOAT)].height + 15;
            if ([UdeskSDKUtil isBlankString:self.remarkTextView.placeholder]) {
                remarkPlaceholderHeight = 0;
            }
            _remarkTextView.minHeight = MAX(kUDSurveyRemarkTextViewHeight, remarkPlaceholderHeight);
            _remarkTextView.udHeight = MAX(kUDSurveyRemarkTextViewHeight, remarkPlaceholderHeight);
        }
        else {
            _remarkTextView.minHeight = kUDSurveyRemarkTextViewMaxHeight;
            _remarkTextView.udHeight = kUDSurveyRemarkTextViewMaxHeight;
        }
        _submitButton.udTop = self.remarkTextView.udBottom+kUDSurveySubmitButtonSpacing;
        _remarkRequiredLabel.udTop = self.remarkTextView.udBottom+kUDSurveyRemarkRequiredLabelToVerticalEdgeSpacing;
    }
    [self checkRemarkTextViewHeight];
}

#pragma mark - UICollectionViewDataSource && Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allOptionTags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUDSurveyTagsCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    
    if (self.allOptionTags.count > indexPath.row) {
        UILabel *label = [[UILabel alloc] init];
        label.text = self.allOptionTags[indexPath.row];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        cell.backgroundView = label;
        [self normalTagColor:label];
        
        if ([self.selectedOptionTags containsObject:label.text]) {
            [self selectedTagColor:label];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.allOptionTags.count > indexPath.row) {
        
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        UILabel *label = (UILabel *)cell.backgroundView;
        
        NSString *tag = self.allOptionTags[indexPath.row];
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.selectedOptionTags];
        if ([self.selectedOptionTags containsObject:tag]) {
            
            [array removeObject:tag];
            if ([label isKindOfClass:[UILabel class]]) {
                [self normalTagColor:label];
            }
        }
        else {
            
            [array addObject:tag];
            if ([label isKindOfClass:[UILabel class]]) {
                [self selectedTagColor:label];
            }
        }
        self.selectedOptionTags = [array copy];
    }
}

//选择状态标签颜色
- (void)selectedTagColor:(UILabel *)label {
    
    label.textColor = [UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1];
    label.backgroundColor = [UIColor colorWithRed:0.957f  green:0.976f  blue:1 alpha:1];
    UDViewBorderRadius(label, 2, 0.6, [UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1]);
}

//未选择状态标签颜色
- (void)normalTagColor:(UILabel *)label {
    
    label.textColor = [UIColor colorWithRed:0.6f  green:0.6f  blue:0.6f alpha:1];
    label.backgroundColor = [UIColor clearColor];
    UDViewBorderRadius(label, 2, 0.6, [UIColor colorWithRed:0.898f  green:0.898f  blue:0.898f alpha:1]);
}

#pragma mark - UITextViewDelegate
- (BOOL)growingTextView:(UdeskHPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        [growingTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark @protocol UdeskSurveyProtocol
- (void)didSelectExpressionSurveyWithOption:(UdeskSurveyOption *)option {
    
    if ([self.selectedOptionId isEqual:option.optionId]) {
        return;
    }
    
    [self.remarkTextView resignFirstResponder];
    
    self.selectedOptionId = option.optionId;
    self.selectedOptionTags = nil;
    [self updateContentView];
}

#pragma mark - Button Action
- (void)submitSurvetAction:(UdeskButton *)button {

    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSubmitSurvey:)]) {
        [self.delegate clickSubmitSurvey:self];
    }
}

- (void)tapScrollerViewAction {
    [self.remarkTextView resignFirstResponder];
    [self checkRemarkTextViewHeight];
}

//检查备注文本的高度
- (void)checkRemarkTextViewHeight {
    
    [self updateContentView];
}

- (void)updateContentView {
    
    [self setNeedsLayout];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateContentView:)]) {
        [self.delegate didUpdateContentView:self];
    }
}

@end
