//
//  UdeskAgentSurvey.h
//  UdeskSDK
//
//  Created by xuchen on 16/8/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskAgentSurvey : NSObject

+ (instancetype)store;

- (void)showAgentSurveyAlertViewWithAgentId:(NSString *)agentId
                                 completion:(void(^)())completion;

@end
