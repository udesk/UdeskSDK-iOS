//
//  UdeskDateUtil.m
//  UdeskSDK
//
//  Created by Udesk on 16/6/3.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskDateUtil.h"
#import "UdeskBundleUtils.h"

@implementation UdeskDateUtil

+ (UdeskDateUtil *)sharedFormatter
{
    static UdeskDateUtil *_sharedFormatter = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [[UdeskDateUtil alloc] init];
    });
    
    return _sharedFormatter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return self;
}

- (void)dealloc {
    _dateFormatter = nil;
}

#pragma mark - Formatter

- (NSString *)udStyleDateForDate:(NSDate *)date {
    
    if (!date) return @"";
    
    NSString *dateText = nil;
    NSString *timeText = nil;
    
    NSDate *today = [NSDate date];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
    
    if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day) {
        dateText = getUDLocalizedString(@"udesk_today");
    } else {
        dateText = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    }
    
    timeText = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    
    return [NSString stringWithFormat:@"%@ %@",dateText,timeText];
}

@end
