//
//  NSTimer+UdeskSDK.h
//
//  Created by Udesk on 3/14/16.
//  Copyright 2016 Random Ideas, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (UdeskSDK)

+ (instancetype)udScheduleTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block;
+ (instancetype)udTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block;

@end
