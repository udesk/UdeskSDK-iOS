//
//  UdeskSurveyView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/9.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSurveyView.h"
#import "UdeskSurveyTitleView.h"
#import "UdeskSurveyManager.h"
#import "UdeskBundleUtils.h"
#import "UIView+UdeskSDK.h"
#import "UdeskToast.h"
#import "UdeskSDKUtil.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskSurveyViewController.h"
#import "UdeskSDKMacro.h"
#import "UdeskChatViewController.h"

@interface UdeskSurveyView()<UdeskSurveyViewDelegate> {
    
    UdeskSurveyViewController *_surveyController;
}

@property (nonatomic, strong) UdeskSurveyTitleView *titleView;
@property (nonatomic, strong) UdeskSurveyManager *surveyManager;
@property (nonatomic, strong) UdeskSurveyModel *surveyModel;

@property (nonatomic, strong) NSArray *options;

@property (nonatomic, copy  ) NSString *agentId;
@property (nonatomic, copy  ) NSString *imSubSessionId;

@end

@implementation UdeskSurveyView

- (instancetype)initWithAgentId:(NSString *)agentId imSubSessionId:(NSString *)imSubSessionId
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        _agentId = agentId;
        _imSubSessionId = imSubSessionId;
        
        [self setupUI];
        [self fetchSurveyOptions];
    }
    return self;
}

- (void)setupUI {
    
    self.userInteractionEnabled = YES;
    
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    _titleView = [[UdeskSurveyTitleView alloc] initWithFrame:CGRectZero];
    [_titleView.closeButton addTarget:self action:@selector(closeSurveyViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_titleView];
    
    _surveyContentView = [[UdeskSurveyContentView alloc] init];
    _surveyContentView.delegate = self;
    [_contentView addSubview:_surveyContentView];
}

- (void)fetchSurveyOptions {
    
    [self.surveyManager fetchSurveyOptions:^(UdeskSurveyModel *surveyModel) {
        
        if (!surveyModel) {
            [self closeSurveyViewAction:nil];
            return ;
        }
        self.surveyModel = surveyModel;
        [self reloadSurveyView];
    }];
}

//刷新UI
- (void)reloadSurveyView {
    
    self.surveyContentView.surveyModel = self.surveyModel;
    self.titleView.titleLabel.text = self.surveyModel.title;
    [self setNeedsLayout];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.surveyContentView.remarkTextView resignFirstResponder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.surveyModel || self.surveyModel == (id)kCFNull) return ;
    
    CGFloat surveyOptionHeight = 0;
    
    switch (self.surveyModel.optionType) {
        case UdeskSurveyOptionTypeStar:{
            
            if (!self.surveyModel.star || self.surveyModel.star == (id)kCFNull) return ;
            if (!self.surveyModel.star.options || self.surveyModel.star.options == (id)kCFNull) return ;
            
            surveyOptionHeight = kUDSurveyStarOptionHeight;
            self.options = self.surveyModel.star.options;
            
            break;
        }
        case UdeskSurveyOptionTypeText:{
            
            if (!self.surveyModel.text || self.surveyModel.text == (id)kCFNull) return ;
            if (!self.surveyModel.text.options || self.surveyModel.text.options == (id)kCFNull) return ;
            
            NSArray *array = [self.surveyModel.text.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"enabled>0"]];
            surveyOptionHeight = array.count * ((kUDTextSurveyButtonToVerticalEdgeSpacing+kUDTextSurveyButtonHeight)) - kUDTextSurveyButtonToVerticalEdgeSpacing;
            self.options = self.surveyModel.text.options;
            
            break;
        }
        case UdeskSurveyOptionTypeExpression:{
            
            if (!self.surveyModel.expression || self.surveyModel.expression == (id)kCFNull) return ;
            if (!self.surveyModel.expression.options || self.surveyModel.expression.options == (id)kCFNull) return ;
            
            surveyOptionHeight = kUDSurveyExpressionOptionHeight;
            self.options = self.surveyModel.expression.options;
            
            break;
        }
        default:
            break;
    }
    
    CGFloat tagsHeight = [self tagsHeight];
    
    CGFloat tagsCollectionHeight = tagsHeight > kUDSurveyTagsCollectionViewMaxHeight ? kUDSurveyTagsCollectionViewMaxHeight : tagsHeight;
    
    CGFloat surveyButtonSpacing = surveyOptionHeight ? kUDTextSurveyButtonToVerticalEdgeSpacing : 0;
    CGFloat tagsCollectionViewSpacing = tagsCollectionHeight ? kUDSurveyCollectionViewItemToVerticalEdgeSpacing : 0;
    
    CGFloat remarkHeight = kUDSurveyRemarkTextViewMaxHeight;
    CGFloat remarkPlaceholderHeight = [UdeskStringSizeUtil textSize:self.surveyContentView.remarkTextView.placeholder withFont:[UIFont systemFontOfSize:15] withSize:CGSizeMake(self.contentView.udWidth-(kUDSurveyContentSpacing*3), MAXFLOAT)].height + 15;
    
    if (!self.surveyContentView.remarkTextView.text.length) {
        remarkHeight = MAX(remarkPlaceholderHeight, kUDSurveyRemarkTextViewHeight);
    }
    
    CGFloat contentHeight = kUDSurveyTitleHeight + kUDTextSurveyButtonToVerticalEdgeSpacing + surveyOptionHeight + surveyButtonSpacing + tagsCollectionHeight + tagsCollectionViewSpacing + remarkHeight + kUDSurveySubmitButtonSpacing + kUDSurveySubmitButtonHeight + kUDSurveySubmitButtonSpacing;
    
    if (!self.surveyModel.remarkEnabled.boolValue) {
        contentHeight -= (remarkHeight+kUDSurveySubmitButtonSpacing);
    }
    else {
        
        UdeskSurveyOption *option = [self selectedOption];
        if (option) {
            if (option.remarkOptionType == UdeskRemarkOptionTypeHide) {
                contentHeight -= (remarkHeight+kUDSurveySubmitButtonSpacing);
            }
        }
        else {
            contentHeight -= (remarkHeight+kUDSurveySubmitButtonSpacing);
        }
    }
    
    contentHeight = udIsIPhoneXSeries ? contentHeight+34 : contentHeight;
    
    CGFloat contentY = UD_SCREEN_HEIGHT > contentHeight ? UD_SCREEN_HEIGHT-contentHeight : 0;
    self.contentView.frame = CGRectMake(0, contentY, self.udWidth, contentHeight);
    self.titleView.frame = CGRectMake(0, 0, self.contentView.udWidth, kUDSurveyTitleHeight);
    self.surveyContentView.frame = CGRectMake(0, self.titleView.udBottom, self.contentView.udWidth, contentHeight - kUDSurveyTitleHeight);
}

//标签高度
- (CGFloat)tagsHeight {
    
    @try {
        
        NSArray *selectedOption = [self.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"optionId = %@",self.surveyContentView.selectedOptionId]];
        if (!selectedOption.count) {
            return 0;
        }
        UdeskSurveyOption *optionModel = selectedOption.firstObject;
        if (!optionModel || optionModel == (id)kCFNull) return 0;
        
        if (!optionModel.enabled.boolValue) {
            return 0;
        }
        
        if ([UdeskSDKUtil isBlankString:optionModel.tags]) {
            return 0;
        }
        NSArray *array = [optionModel.tags componentsSeparatedByString:@","];
        return (ceilf(array.count/2.0)) * (kUDSurveyCollectionViewItemSizeHeight+kUDSurveyCollectionViewItemToVerticalEdgeSpacing) - kUDSurveyCollectionViewItemToVerticalEdgeSpacing;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//选择的选项
- (UdeskSurveyOption *)selectedOption {
    
    @try {
        
        NSArray *selectedOption = [self.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"optionId = %@",self.surveyContentView.selectedOptionId]];
        UdeskSurveyOption *optionModel = selectedOption.firstObject;
        if (optionModel) {
            if ([optionModel isKindOfClass:[UdeskSurveyOption class]]) {
                return optionModel;
            }
        }
        return nil;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - lazy
- (UdeskSurveyManager *)surveyManager {
    if (!_surveyManager) {
        _surveyManager = [[UdeskSurveyManager alloc] init];
    }
    return _surveyManager;
}

#pragma mark - Button Action
- (void)clickSubmitSurvey:(UdeskSurveyContentView *)survey {
    
    [self.surveyContentView.remarkTextView resignFirstResponder];
    if (!self.agentId || self.agentId == (id)kCFNull) return ;
    if (!self.imSubSessionId || self.imSubSessionId == (id)kCFNull) return ;
    
    @try {
        
        if (!survey.selectedOptionId || survey.selectedOptionId == (id)kCFNull) {
            [UdeskToast showToast:getUDLocalizedString(@"udesk_survey_tips") duration:0.5f window:self];
            return;
        }
        
        UdeskSurveyOption *option = [self selectedOption];
        if (self.surveyModel.remarkEnabled.boolValue && option && option.remarkOptionType == UdeskRemarkOptionTypeRequired) {
            if (!self.surveyContentView.remarkTextView.text.length) {
                [UdeskToast showToast:getUDLocalizedString(@"udesk_survey_remark_required") duration:0.5f window:self];
                return;
            }
        }
        
        if (self.surveyContentView.remarkTextView.text.length > 255) {
            [UdeskToast showToast:getUDLocalizedString(@"udesk_survey_remark_max_num") duration:0.5f window:self];
            return;
        }
        
        NSDictionary *parameters = @{
                                     @"agent_id":self.agentId,
                                     @"option_id":survey.selectedOptionId,
                                     @"im_sub_session_id":self.imSubSessionId,
                                     @"show_type":[self.surveyModel stringWithOptionType],
                                     };
        
        [self.surveyManager checkHasSurveyWithAgentId:self.agentId completion:^(BOOL result, NSError *error) {
            if (!result) {
                
                [self.surveyManager submitSurveyWithParameters:parameters surveyRemark:survey.remarkTextView.text tags:survey.selectedOptionTags completion:^(NSError *error) {
                    NSString *string = getUDLocalizedString(@"udesk_top_view_thanks_evaluation");
                    if (error) {
                        string = getUDLocalizedString(@"udesk_top_view_failure");
                    }
                    [UdeskToast showToast:string duration:0.5f window:self];
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6/*延迟执行时间*/ * NSEC_PER_SEC));
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        [self closeSurveyViewAction:nil];
                    });
                }];
            }
            else {
                [UdeskToast showToast:getUDLocalizedString(@"udesk_has_survey") duration:0.5f window:self];
            }
        }];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)didUpdateContentView:(UdeskSurveyContentView *)survey {
    [self setNeedsLayout];
}

- (void)closeSurveyViewAction:(UdeskButton *)button {
    [self.surveyContentView.remarkTextView resignFirstResponder];
    [self dismiss];
}

- (void)dismiss {
    [_surveyController dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    [_surveyController dismissWithCompletion:completion];
}

- (void)show {
    [self showWithCompletion:nil];
}

- (void)showWithCompletion:(void (^)(void))completion {
    
    if ([[UdeskSDKUtil currentViewController] isKindOfClass:[UdeskSurveyViewController class]]) {
        return;
    }
    
    if (![[UdeskSDKUtil currentViewController] isKindOfClass:[UdeskChatViewController class]]) {
        return;
    }
    
    _surveyController = [[UdeskSurveyViewController alloc] init];
    [_surveyController showSurveyView:self completion:completion];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
