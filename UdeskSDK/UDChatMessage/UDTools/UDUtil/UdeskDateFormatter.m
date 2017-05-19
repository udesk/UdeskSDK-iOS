//
//  UdeskDateFormatter.m
//  UdeskSDK
//
//  Created by Udesk on 16/6/3.
//  Copyright © 2016年 Udesk. All rights reserved.
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
    
    NSString *timeText = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    
    return timeText;
}

@end
