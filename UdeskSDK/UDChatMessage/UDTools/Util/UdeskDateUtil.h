//
//  UdeskDateUtil.h
//  UdeskSDK
//
//  Created by Udesk on 16/6/3.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskDateUtil : NSObject

@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

+ (UdeskDateUtil *)sharedFormatter;

- (NSString *)udStyleDateForDate:(NSDate *)date;

@end
