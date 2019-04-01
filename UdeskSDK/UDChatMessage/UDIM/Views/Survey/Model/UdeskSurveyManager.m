//
//  UdeskSurveyManager.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSurveyManager.h"
#import "UdeskManager.h"
#import "UdeskSDKUtil.h"
#import "UdeskBundleUtils.h"

@implementation UdeskSurveyManager

- (void)fetchSurveyOptions:(void(^)(UdeskSurveyModel *surveyModel))completion {
    
    //机器人会话满意度
    if (self.isRobotSession) {
        
        UdeskSurveyModel *surveyModel = [[UdeskSurveyModel alloc] init];
        surveyModel.enabled = @(1);
        surveyModel.remarkEnabled = @(1);
        surveyModel.title = getUDLocalizedString(@"udesk_robot_survey");
        surveyModel.showType = @"text";
        surveyModel.optionType = UdeskSurveyOptionTypeText;
        
        UdeskTextSurvey *textSurvey = [[UdeskTextSurvey alloc] init];
        
        UdeskSurveyOption *satisfiedOption = [[UdeskSurveyOption alloc] init];
        satisfiedOption.optionId = @(2);
        satisfiedOption.enabled = @(1);
        satisfiedOption.text = getUDLocalizedString(@"udesk_survey_satisfied");
        satisfiedOption.remarkOptionType = UdeskRemarkOptionTypeOptional;
        
        UdeskSurveyOption *generalOption = [[UdeskSurveyOption alloc] init];
        generalOption.optionId = @(3);
        generalOption.enabled = @(1);
        generalOption.text = getUDLocalizedString(@"udesk_survey_general");
        generalOption.remarkOptionType = UdeskRemarkOptionTypeOptional;
        
        UdeskSurveyOption *unsatisfactoryOption = [[UdeskSurveyOption alloc] init];
        unsatisfactoryOption.optionId = @(4);
        unsatisfactoryOption.enabled = @(1);
        unsatisfactoryOption.text = getUDLocalizedString(@"udesk_survey_unsatisfactory");
        unsatisfactoryOption.remarkOptionType = UdeskRemarkOptionTypeOptional;
        
        textSurvey.options = @[satisfiedOption,generalOption,unsatisfactoryOption];
        
        surveyModel.text = textSurvey;
        
        if (completion) {
            completion(surveyModel);
        }
        
        return;
    }
    
    [UdeskManager getSurveyOptions:^(id responseObject, NSError *error) {
       
        @try {
         
            if (error) {
                NSLog(@"UdeskSDK：%@",error);
                if (completion) {
                    completion(nil);
                }
                return ;
            }
            
            NSNumber *code = responseObject[@"code"];
            if ([code isEqual:@"1000"] || [code isEqual:@1000]) {
                NSDictionary *result = responseObject[@"result"];
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    UdeskSurveyModel *surveyModel = [[UdeskSurveyModel alloc] initWithDictionary:result];
                    if (completion) {
                        completion(surveyModel);
                    }
                }
                else {
                    NSLog(@"UdeskSDK：%@",responseObject);
                    if (completion) {
                        completion(nil);
                    }
                }
            }
            else {
                NSLog(@"UdeskSDK：%@",responseObject);
                if (completion) {
                    completion(nil);
                }
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
        
    }];
}

//提交满意度调查
- (void)submitSurveyWithParameters:(NSDictionary *)parameters
                      surveyRemark:(NSString *)surveyRemark
                              tags:(NSArray *)tags
                        completion:(void(^)(NSError *error))completion {
    
    if (!parameters || parameters == (id)kCFNull) return ;
    if (![parameters isKindOfClass:[NSDictionary class]]) return;
    
    @try {
     
        //机器人满意度呀
        if (self.isRobotSession) {
            NSArray *array = [parameters allKeys];
            if (![array containsObject:@"option_id"]) return;
            
            NSMutableDictionary *mParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
            
            if (![UdeskSDKUtil isBlankString:surveyRemark]) {
                [mParameters setObject:surveyRemark forKey:@"remark"];
            }
            [mParameters removeObjectForKey:@"agent_id"];
            [mParameters removeObjectForKey:@"im_sub_session_id"];
            [mParameters removeObjectForKey:@"show_type"];
            [UdeskManager submitRobotSurveyWithParameters:mParameters completion:completion];
            return;
        }
        
        NSArray *array = [parameters allKeys];
        if (![array containsObject:@"agent_id"]) return;
        if (![array containsObject:@"option_id"]) return;
        if (![array containsObject:@"im_sub_session_id"]) return;
        if (![array containsObject:@"show_type"]) return;
        
        NSMutableDictionary *mParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        
        if (![UdeskSDKUtil isBlankString:surveyRemark]) {
            [mParameters setObject:surveyRemark forKey:@"survey_remark"];
        }
        
        if (tags.count) {
            
            NSString *tagsString = [tags componentsJoinedByString:@","];
            if (![UdeskSDKUtil isBlankString:tagsString]) {
                [mParameters setObject:tagsString forKey:@"tags"];
            }
        }
        
        [UdeskManager submitSurveyWithParameters:mParameters completion:completion];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//检查是否已经评价
+ (void)checkHasSurveyWithAgentId:(NSString *)agentId isRobotSession:(BOOL)isRobotSession completion:(void(^)(BOOL hasSurvey,NSError *error))completion {
    
    if (isRobotSession) {
        [UdeskManager checkRobotSessionHasSurvey:completion];
        return;
    }
    
    if (!agentId || agentId == (id)kCFNull) return ;
    [UdeskManager checkHasSurveyWithAgentId:agentId completion:completion];
}

@end
