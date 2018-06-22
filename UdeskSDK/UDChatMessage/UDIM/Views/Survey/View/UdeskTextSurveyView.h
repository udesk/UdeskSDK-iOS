//
//  UdeskTextSurveyView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSurveyProtocol.h"
@class UdeskTextSurvey;

/** 头像距离屏幕水平边沿距离 */
extern const CGFloat kUDTextSurveyButtonToVerticalEdgeSpacing;
extern const CGFloat kUDTextSurveyButtonHeight;

@interface UdeskTextSurveyView : UIView

@property (nonatomic, strong) UdeskTextSurvey *textSurvey;
@property (nonatomic, weak  ) id<UdeskSurveyProtocol> delegate;

- (instancetype)initWithTextSurvey:(UdeskTextSurvey *)textSurvey;

@end
