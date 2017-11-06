//
//  UdeskResendManager.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/27.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskResendManager.h"
#import "NSTimer+UdeskSDK.h"
#import "UdeskManager.h"

@implementation UdeskResendManager

#pragma mark - 重发失败的消息
+ (void)resendFailedMessage:(NSMutableArray *)resendMessageArray
                   progress:(void(^)(NSString *messageId,float percent))progress
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
                            
                            if (resendMessage.messageType == UDMessageContentTypeVideo) {
                            
                                [UdeskManager sendVideoMessage:resendMessage videoName:resendMessage.content progress:^(NSString *key, float percent) {
                                    
                                    if ([resendMessageArray containsObject:resendMessage]) {
                                        [resendMessageArray removeObject:resendMessage];
                                    }
                                    
                                    if (progress) {
                                        progress(resendMessage.messageId,percent);
                                    }
                                    
                                } cancellationSignal:^BOOL{
                                    return NO;
                                } completion:completion];
                            }
                            else {
                                [UdeskManager sendMessage:resendMessage completion:completion];
                            }
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
