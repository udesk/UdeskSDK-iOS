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

@implementation UdeskSurveyManager

- (void)fetchSurveyOptions:(void(^)(UdeskSurveyModel *surveyModel))completion {
    
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
}

//检查是否已经评价
- (void)checkHasSurveyWithAgentId:(NSString *)agentId
                       completion:(void(^)(BOOL result,NSError *error))completion {
    
    [UdeskManager checkHasSurveyWithAgentId:agentId completion:^(NSString *hasSurvey, NSError *error) {
        
        if (completion) {
            completion(hasSurvey.boolValue,error);
        }
    }];
}

@end
