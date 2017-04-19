//
//  NSTimer+UdeskSDK.h
//
//  Created by Udesk on 3/14/16.
//  Copyright 2016 Random Ideas, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (UdeskSDK)

/** Creates a new @c NSTimer object using the specified handler, schedules it on
 * the current run loop, and returns it.
 *
 * @param seconds For a repeating timer, the seconds between firings of the
 * timer. If seconds is less than or equal to @c 0.0, @c 0.1 is used instead.
 * @param repeats If @c YES, the timer will repeatedly reschedule itself until
 * invalidated. If @c NO, the timer will be invalidated after it fires.
 * @param block The code unit to execute when the timer fires.
 * @return A new @c NSTimer object, configured according to the specified parameters.
 */
+ (instancetype)ud_scheduleTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block;

/** Creates and returns a new @c NSTimer object using the specified handler.
 *
 * You must add the new timer to a run loop, using @c addTimer:forMode:. Upon
 * firing, the timer fires the block. If the timer is configured to repeat,
 * there is no need to subsequently re-add the timer to the run loop.
 *
 * @param seconds For a repeating timer, the seconds between firings of the
 * timer. If seconds is less than or equal to @c 0.0, @c 0.1 is used instead.
 * @param repeats If @c YES, the timer will repeatedly reschedule itself until
 * invalidated. If @c NO, the timer will be invalidated after it fires.
 * @param block The code unit to execute when the timer fires.
 * @return A new @c NSTimer object, configured according to the specified parameters.
 */
+ (instancetype)ud_timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block;

@end
