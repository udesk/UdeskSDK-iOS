//
//  UdeskSurveyManager.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskSurveyModel.h"

@interface UdeskSurveyManager : NSObject

//满意度调查配置选项
- (void)fetchSurveyOptions:(void(^)(UdeskSurveyModel *surveyModel))completion;
//提交满意度调查
- (void)submitSurveyWithParameters:(NSDictionary *)parameters
                      surveyRemark:(NSString *)surveyRemark
                              tags:(NSArray *)tags
                        completion:(void(^)(NSError *error))completion;
//检查是否已经评价
- (void)checkHasSurveyWithAgentId:(NSString *)agentId
                       completion:(void(^)(BOOL result,NSError *error))completion;

@end
