//
//  UdeskThrottleUtil.h
//  UdeskSDK
//
//  Created by xuchen on 2018/6/7.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UD_THROTTLE_MAIN_QUEUE             (dispatch_get_main_queue())
#define UD_THROTTLE_GLOBAL_QUEUE           (dispatch_get_global_queue(0, 0))

typedef void (^UdeskThrottleBlock) (void);

@interface UdeskThrottleUtil : NSObject

void ud_dispatch_throttle(NSTimeInterval threshold, UdeskThrottleBlock block);

@end
