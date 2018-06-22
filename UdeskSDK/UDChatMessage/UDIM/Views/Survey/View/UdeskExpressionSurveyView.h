//
//  UdeskExpressionSurveyView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSurveyProtocol.h"
@class UdeskExpressionSurvey;

@interface UdeskExpressionSurveyView : UIView

@property (nonatomic, strong) UdeskExpressionSurvey *expressionSurvey;
@property (nonatomic, weak  ) id<UdeskSurveyProtocol> delegate;

- (instancetype)initWithExpressionSurvey:(UdeskExpressionSurvey *)expressionSurvey;

@end
