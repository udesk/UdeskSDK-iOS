//
//  NSTimer+UdeskSDK.m
//
//  Created by Udesk on 3/14/16.
//  Copyright 2016 Random Ideas, LLC. All rights reserved.
//

#import "NSTimer+UdeskSDK.h"

@implementation NSTimer (UdeskSDK)

+ (instancetype)udScheduleTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block
{
    NSTimer *timer = [self udTimerWithTimeInterval:seconds repeats:repeats usingBlock:block];
    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    return timer;
}

+ (instancetype)udTimerWithTimeInterval:(NSTimeInterval)inSeconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block
{
    NSParameterAssert(block != nil);
    CFAbsoluteTime seconds = fmax(inSeconds, 0.0001);
    CFAbsoluteTime interval = repeats ? seconds : 0;
    CFAbsoluteTime fireDate = CFAbsoluteTimeGetCurrent() + seconds;
    return (__bridge_transfer NSTimer *)CFRunLoopTimerCreateWithHandler(NULL, fireDate, interval, 0, 0, (void(^)(CFRunLoopTimerRef))block);
}

@end
