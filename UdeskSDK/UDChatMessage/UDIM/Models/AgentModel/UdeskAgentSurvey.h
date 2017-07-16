//
//  UdeskAgentSurvey.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskAgentSurvey : NSObject

+ (instancetype)sharedManager;

- (void)showAgentSurveyAlertViewWithAgentId:(NSString *)agentId
                           isShowErrorAlert:(BOOL)isShowErrorAlert
                                 completion:(void(^)(BOOL result, NSError *error))completion;

- (void)checkHasSurveyWithAgentId:(NSString *)agentId
                       completion:(void (^)(NSString *hasSurvey,NSError *error))completion;

@end
