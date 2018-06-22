//
//  UdeskSurveyView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/9.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSurveyContentView.h"

@interface UdeskSurveyView : UIControl

@property (nonatomic, strong) UdeskSurveyContentView *surveyContentView;
@property (nonatomic, strong) UIView *contentView;

- (instancetype)initWithAgentId:(NSString *)agentId imSubSessionId:(NSString *)imSubSessionId;

- (void)show;
- (void)dismiss;

@end
