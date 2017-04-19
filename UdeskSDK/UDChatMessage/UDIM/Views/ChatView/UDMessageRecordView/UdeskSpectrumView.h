//
//  UdeskSpectrumView.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskTimerLabel.h"

@interface UdeskSpectrumView : UIView

@property (nonatomic, copy) void (^itemLevelCallback)();

@property (nonatomic) NSUInteger numberOfItems;

@property (nonatomic) UIColor * itemColor;

@property (nonatomic) CGFloat level;

@property (nonatomic) UILabel *timeLabel;

@property (nonatomic) UdeskTimerLabel *stopwatch;

@property (nonatomic) NSString *text;

@end
