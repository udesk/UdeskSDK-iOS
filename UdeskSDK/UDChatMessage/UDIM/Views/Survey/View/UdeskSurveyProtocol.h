//
//  UdeskSurveyProtocol.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/30.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UdeskSurveyOption;

@protocol UdeskSurveyProtocol <NSObject>

- (void)didSelectExpressionSurveyWithOption:(UdeskSurveyOption *)option;

@end
