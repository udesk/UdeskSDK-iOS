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

@implementation UdeskAgentSurvey {

    UdeskAlertController *_optionsAlert;
}

+ (instancetype)store {

    return [[self alloc] init];
}

- (void)showAgentSurveyAlertViewWithAgentId:(NSString *)agentId
                                 completion:(void(^)())completion {

    if (_optionsAlert==nil) {
        
        [UdeskManager getSurveyOptions:^(id responseObject, NSError *error) {
            //解析数据
            NSDictionary *result = [responseObject objectForKey:@"result"];
            NSString *title = [result objectForKey:@"title"];
            NSString *desc = [result objectForKey:@"desc"];
            NSArray *options = [result objectForKey:@"options"];
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                //根据返回的信息填充Alert数据
                _optionsAlert = [UdeskAlertController alertWithTitle:title message:desc];
                [_optionsAlert addCloseActionWithTitle:getUDLocalizedString(@"udesk_close") Handler:^(UdeskAlertAction * _Nonnull action) {
                    _optionsAlert = nil;
                }];
                //遍历选项数组
                for (NSDictionary *option in options) {
                    //依次添加选项
                    [_optionsAlert addAction:[UdeskAlertAction actionWithTitle:[option objectForKey:@"text"] handler:^(UdeskAlertAction * _Nonnull action) {
                        
                        _optionsAlert = nil;
                        //根据点击的选项 提交到Udesk
                        [UdeskManager survetVoteWithAgentId:agentId withOptionId:[option objectForKey:@"id"] completion:^(id responseObject, NSError *error) {
                            
                            if (completion) {
                                completion();
                            }
                            
                        }];
                        
                    }]];
                }
                //展示Alert
                [_optionsAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            }
            
        }];
    }

}
@end
