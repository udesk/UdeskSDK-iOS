//
//  UdeskAgentSurvey.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskAgentSurvey.h"
#import "UdeskAlertController.h"
#import "UdeskManager.h"
#import "UdeskUtils.h"
#import "UdeskOverlayTransitioningDelegate.h"
#import "UdeskFoundationMacro.h"
#import "UdeskTools.h"

@implementation UdeskAgentSurvey {
    
    UdeskAlertController *_optionsAlert;
    UdeskAlertController *_unKnownAlert;
    UdeskOverlayTransitioningDelegate *_transitioningDelegate;
}

+ (instancetype)sharedManager {
    static UdeskAgentSurvey *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[UdeskAgentSurvey alloc] init];
    });
    
    return _sharedManager;
}

- (void)showAgentSurveyAlertViewWithAgentId:(NSString *)agentId
                           isShowErrorAlert:(BOOL)isShowErrorAlert
                                 completion:(void(^)(BOOL result, NSError *error))completion {
    
    [UdeskManager getSurveyOptions:^(id responseObject, NSError *error) {
        
        @try {
            
            if (error) {
                if (completion) {
                    completion(NO,error);
                }
                return ;
            }
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                
                //已经弹出不用再弹
                if (_optionsAlert) {
                    return ;
                }
                //解析数据
                NSDictionary *result = [responseObject objectForKey:@"result"];
                NSString *title = [result objectForKey:@"title"];
                NSString *desc = [result objectForKey:@"desc"];
                id options = [result objectForKey:@"options"];
                
                if ([options isKindOfClass:[NSArray class]]) {
                    NSArray *optionsArray = (NSArray *)options;
                    if (optionsArray.count > 0) {
                        //根据返回的信息填充Alert数据
                        _optionsAlert = [UdeskAlertController alertControllerWithTitle:title message:desc preferredStyle:UDAlertControllerStyleAlert];
                        
                        //遍历选项数组
                        for (NSDictionary *option in options) {
                            //依次添加选项
                            [_optionsAlert addAction:[UdeskAlertAction actionWithTitle:[option objectForKey:@"text"] style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
                                
                                _optionsAlert = nil;
                                //根据点击的选项 提交到Udesk
                                [UdeskManager survetVoteWithAgentId:agentId withOptionId:[option objectForKey:@"id"] completion:^(id responseObject, NSError *error) {
                                    
                                    BOOL result = error?NO:YES;
                                    if (completion) {
                                        completion(result,error);
                                    }
                                }];
                            }]];
                        }
                        
                        [_optionsAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
                            _optionsAlert = nil;
                        }]];
                        
                        //展示Alert
                        [self presentViewController:_optionsAlert];
                    }
                    else {
                        
                        //没有满意度调查选项
                        [self surveyErrorWithIsShowErrorAlert:isShowErrorAlert error:error completion:completion];
                    }
                    
                }
                else {
                    //没有满意度调查选项
                    [self surveyErrorWithIsShowErrorAlert:isShowErrorAlert error:error completion:completion];
                }
            }
            else {
                NSError *error = [NSError errorWithDomain:@"获取满意度调查" code:3333 userInfo:nil];
                if (completion) {
                    completion(NO,error);
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }];
}

- (void)surveyErrorWithIsShowErrorAlert:(BOOL)isShowErrorAlert
                                  error:(NSError *)error
                             completion:(void(^)(BOOL result, NSError *error))completion {
    
    if (isShowErrorAlert) {
        [self showNotSurvey:completion];
    }
    else {
        if (completion) {
            completion(NO,error);
        }
    }
}

- (void)showNotSurvey:(void(^)(BOOL result, NSError *error))completion {
    
    @try {
        
        //已经弹出不用再弹
        if (_unKnownAlert) {
            return;
        }
        _unKnownAlert = [UdeskAlertController alertControllerWithTitle:@"提示" message:@"没有满意度调查选项内容,请联系管理员添加！" preferredStyle:UDAlertControllerStyleAlert];
        [_unKnownAlert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
            _unKnownAlert = nil;
            
            NSError *error = [NSError errorWithDomain:@"没有满意度调查选项内容" code:3333 userInfo:nil];
            if (completion) {
                completion(NO,error);
            }
        }]];
        
        //展示Alert
        [self presentViewController:_unKnownAlert];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)presentViewController:(UdeskAlertController *)alert {
    
    @try {
        
        if (!alert) return;
        
        if (ud_isIOS7 && [[[UIDevice currentDevice]systemVersion] floatValue] < 8.0) {
            _transitioningDelegate = [[UdeskOverlayTransitioningDelegate alloc] init];
            alert.modalPresentationStyle = UIModalPresentationCustom;
            alert.transitioningDelegate = _transitioningDelegate;
        }
        //展示Alert
        [[UdeskTools currentViewController] presentViewController:alert animated:YES completion:nil];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)checkHasSurveyWithAgentId:(NSString *)agentId
                       completion:(void (^)(NSString *hasSurvey,NSError *error))completion {
    
    if (_optionsAlert==nil) {
        [UdeskManager checkHasSurveyWithAgentId:agentId completion:completion];
    }
}

@end
