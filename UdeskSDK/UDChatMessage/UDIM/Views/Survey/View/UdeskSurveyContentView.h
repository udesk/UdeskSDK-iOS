//
//  UdeskSurveyContentView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/2.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSurveyTitleView.h"
#import "UdeskTextSurveyView.h"
#import "UdeskExpressionSurveyView.h"
#import "UdeskStarSurveyView.h"
#import "UdeskHPGrowingTextView.h"
#import "UdeskButton.h"

@class UdeskSurveyModel;
@class UdeskSurveyContentView;

extern const CGFloat kUDSurveyRemarkTextViewHeight;
extern const CGFloat kUDSurveyRemarkTextViewMaxHeight;
extern const CGFloat kUDSurveySubmitButtonSpacing;
extern const CGFloat kUDSurveySubmitButtonHeight;
extern const CGFloat kUDSurveyContentSpacing;
extern const CGFloat kUDSurveyCollectionViewItemSizeHeight;
extern const CGFloat kUDSurveyCollectionViewItemSizeWidth;
extern const CGFloat kUDSurveyCollectionViewItemToVerticalEdgeSpacing;
extern const CGFloat kUDSurveyTagsCollectionViewMinimumLineSpacing;
extern const CGFloat kUDSurveyTagsCollectionViewMinimumInteritemSpacing;
extern const CGFloat kUDSurveyTagsCollectionViewMaxHeight;
extern const CGFloat kUDSurveyStarOptionHeight;
extern const CGFloat kUDSurveyExpressionOptionHeight;
extern const CGFloat kUDSurveyOptionToVerticalEdgeSpacing;
extern const CGFloat kUDSurveyTitleHeight;
extern const CGFloat kUDSurveyRemarkRequiredLabelToVerticalEdgeSpacing;

@protocol UdeskSurveyViewDelegate <NSObject>

- (void)clickSubmitSurvey:(UdeskSurveyContentView *)survey;
- (void)didUpdateContentView:(UdeskSurveyContentView *)survey;

@end

@interface UdeskSurveyContentView : UIView

/** 载体 */
@property (nonatomic, strong) UIScrollView *contentScrollerView;
/** 文本模式 */
@property (nonatomic, strong) UdeskTextSurveyView *textSurveyView;
/** 表情模式 */
@property (nonatomic, strong) UdeskExpressionSurveyView *expressionSurveyView;
/** 五星模式 */
@property (nonatomic, strong) UdeskStarSurveyView *starSurveyView;
/** 标签 */
@property (nonatomic, strong) UICollectionView *tagsCollectionView;
/** 备注 */
@property (nonatomic, strong) UdeskHPGrowingTextView *remarkTextView;
/** 备注必填 */
@property (nonatomic, strong) UILabel           *remarkRequiredLabel;
/** 提交按钮 */
@property (nonatomic, strong) UdeskButton            *submitButton;

/** 数据 */
@property (nonatomic, strong) UdeskSurveyModel *surveyModel;

@property (nonatomic, strong, readonly) NSNumber *selectedOptionId;
@property (nonatomic, strong, readonly) NSArray  *selectedOptionTags;

@property (nonatomic, assign) CGFloat tagsHeight;
@property (nonatomic, assign) CGFloat surveyOptionHeight;

@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, weak  ) id<UdeskSurveyViewDelegate> delegate;

@end
