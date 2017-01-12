//
//  UdeskDateFormatter.m
//  UdeskSDK
//
//  Created by xuchen on 16/6/3.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskDateFormatter.h"
#import "UdeskUtils.h"

@implementation UdeskDateFormatter

+ (UdeskDateFormatter *)sharedFormatter
{
    static UdeskDateFormatter *_sharedFormatter = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [[UdeskDateFormatter alloc] init];
    });
    
    return _sharedFormatter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return self;
}

- (void)dealloc
{
    _dateFormatter = nil;
}

#pragma mark - Formatter

- (NSString *)ud_styleDateForDate:(NSDate *)date
{
    NSString *dateText = nil;
    NSString *timeText = nil;
    
    NSDate *today = [NSDate date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:today options:0];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
    NSDateComponents *yesterdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:yesterday];
    
    if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day) {
        dateText = getUDLocalizedString(@"udesk_today");
    } else if (dateComponents.year == yesterdayComponents.year && dateComponents.month == yesterdayComponents.month && dateComponents.day == yesterdayComponents.day) {
        dateText = getUDLocalizedString(@"udesk_yesterday");
    } else {
        dateText = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    }
    
    timeText = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    
    return timeText;
}

@end
