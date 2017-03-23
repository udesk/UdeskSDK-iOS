//
//  UdeskAgentSurvey.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskAgentSurvey.h"
#import "UdeskAlertController.h"
#import "UdeskManager.h"
#import "UdeskUtils.h"
#import "UDOverlayTransitioningDelegate.h"
#import "UdeskFoundationMacro.h"

@implementation UdeskAgentSurvey {

    UdeskAlertController *_optionsAlert;
    UDOverlayTransitioningDelegate *_transitioningDelegate;
}

+ (instancetype)store {

    return [[self alloc] init];
}

- (void)showAgentSurveyAlertViewWithAgentId:(NSString *)agentId
                                 completion:(void(^)())completion {

    if (_optionsAlert==nil) {
        
        [UdeskManager getSurveyOptions:^(id responseObject, NSError *error) {
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                
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
                                    
                                    if (completion) {
                                        completion();
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
                        [self showNotSurvey];
                    }
                    
                }
                else {
                    [self showNotSurvey];
                }
                
            }
            
        }];
    }

}

- (void)showNotSurvey {
    
    UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:@"错误" message:@"没有满意度调查选项内容,请联系管理员添加！" preferredStyle:UDAlertControllerStyleAlert];
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
        
    }]];
    
    //展示Alert
    [self presentViewController:_optionsAlert];
}

- (void)presentViewController:(UdeskAlertController *)alert {

    if (ud_isIOS7 && [[[UIDevice currentDevice]systemVersion] floatValue] < 8.0) {
        _transitioningDelegate = [[UDOverlayTransitioningDelegate alloc] init];
        alert.modalPresentationStyle = UIModalPresentationCustom;
        alert.transitioningDelegate = _transitioningDelegate;
    }
    //展示Alert
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)checkHasSurveyWithAgentId:(NSString *)agentId
                       completion:(void (^)(NSString *hasSurvey))completion {

    [UdeskManager checkHasSurveyWithAgentId:agentId completion:completion];
}

- (UIViewController *)currentViewController
{
    UIWindow *keyWindow  = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController)
    {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = [(UINavigationController *)vc visibleViewController];
        }
        else if ([vc isKindOfClass:[UITabBarController class]])
        {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}

@end
