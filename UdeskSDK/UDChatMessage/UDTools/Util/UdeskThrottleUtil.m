//
//  UdeskThrottleUtil.m
//  UdeskSDK
//
//  Created by xuchen on 2018/6/7.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskThrottleUtil.h"

#define udThreadCallStackSymbol       [NSThread callStackSymbols][1]

@implementation UdeskThrottleUtil

#pragma mark public: general
void ud_dispatch_throttle(NSTimeInterval threshold, UdeskThrottleBlock block) {
    [UdeskThrottleUtil _throttle:threshold queue:UD_THROTTLE_MAIN_QUEUE key:udThreadCallStackSymbol block:block];
}

#pragma mark private: general
+ (NSMutableDictionary *)scheduledSources {
    static NSMutableDictionary *_sources = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _sources = [NSMutableDictionary dictionary];
    });
    return _sources;
}

+ (void)_throttle:(NSTimeInterval)threshold queue:(dispatch_queue_t)queue key:(NSString *)key block:(UdeskThrottleBlock)block {
    
    NSMutableDictionary *scheduledSources = self.scheduledSources;
    
    dispatch_source_t source = scheduledSources[key];
    
    if (source) {
        dispatch_source_cancel(source);
    }
    
    source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(source, dispatch_time(DISPATCH_TIME_NOW, threshold * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(source, ^{
        block();
        dispatch_source_cancel(source);
        [scheduledSources removeObjectForKey:key];
    });
    dispatch_resume(source);
    
    scheduledSources[key] = source;
}

@end
