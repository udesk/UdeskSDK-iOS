//
//  UdeskStarSurveyView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSurveyProtocol.h"
@class UdeskStarSurvey;

@interface UdeskStarSurveyView : UIView

@property (nonatomic, strong) UdeskStarSurvey *starSurvey;
@property (nonatomic, weak  ) id<UdeskSurveyProtocol> delegate;

- (instancetype)initWithStarSurvey:(UdeskStarSurvey *)starSurvey;

@end
