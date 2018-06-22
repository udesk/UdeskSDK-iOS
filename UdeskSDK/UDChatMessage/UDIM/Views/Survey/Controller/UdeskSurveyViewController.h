//
//  UdeskSurveyViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/9.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskSurveyView;

@interface UdeskSurveyViewController : UIViewController

@property(nonatomic, strong, readonly) UdeskSurveyView *surveyView;

- (void)showSurveyView:(UdeskSurveyView *)surveyView completion:(void (^)(void))completion;
- (void)dismissWithCompletion:(void (^)(void))completion;

@end
