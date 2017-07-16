//
//  UdeskResendManager.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/27.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskResendManager.h"
#import "NSTimer+UdeskSDK.h"
#import "UdeskMessage.h"
#import "UdeskManager.h"

@implementation UdeskResendManager

#pragma mark - 重发失败的消息
+ (void)resendFailedMessage:(NSMutableArray *)resendMessageArray
                 completion:(void(^)(UdeskMessage *failedMessage,BOOL sendStatus))completion {
    
    if (resendMessageArray.count) {
        
        [NSTimer ud_scheduleTimerWithTimeInterval:6.0f repeats:YES usingBlock:^(NSTimer *timer) {
            
            @try {
                if (resendMessageArray.count==0) {
                    
                    [timer invalidate];
                    timer = nil;
                }
                else {
                    
                    for (UdeskMessage *resendMessage in resendMessageArray) {
                        
                        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:resendMessage.timestamp];
                        
                        if (fabs (timeInterval) > 60) {
                            
                            if (completion) {
                                completion(resendMessage,NO);
                            }
                            
                            [resendMessageArray removeObject:resendMessage];
                            
                        } else {
                            
                            [UdeskManager sendMessage:resendMessage completion:^(UdeskMessage *message, BOOL sendStatus) {
                                
                                if (completion) {
                                    completion(message,sendStatus);
                                }
                            }];
                        }
                    }
                }
            } @catch (NSException *exception) {
            } @finally {
            }
        }];
    }
}

@end
