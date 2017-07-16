//
//  UdeskEventMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/4/25.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskEventMessage.h"
#import "UdeskMessage.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskFoundationMacro.h"
#import "UdeskEventCell.h"
#import "UdeskTools.h"

/** Event垂直距离 */
static CGFloat const kUDEventToVerticalEdgeSpacing = 10;
/** Event水平距离 */
static CGFloat const kUDEventToHorizontalEdgeSpacing = 8;
/** Event高度 */
static CGFloat const kUDEventHeight = 20;


@interface UdeskEventMessage()

/** 提示文字Frame */
@property (nonatomic, assign, readwrite) CGRect eventLabelFrame;

@end

@implementation UdeskEventMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutEventMessage];
    }
    return self;
}

- (void)layoutEventMessage {

    CGFloat eventWidth = [self getEventContentWidth:self.message.content];
    self.eventLabelFrame = CGRectMake((UD_SCREEN_WIDTH-eventWidth)/2, CGRectGetMaxY(self.dateFrame)+kUDEventToVerticalEdgeSpacing, eventWidth, kUDEventHeight);
    
    self.cellHeight = self.eventLabelFrame.size.height + self.eventLabelFrame.origin.y + kUDEventToVerticalEdgeSpacing;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (CGFloat)getEventContentWidth:(NSString *)eventContent {

    CGSize size = [UdeskStringSizeUtil textSize:eventContent withFont:[UIFont systemFontOfSize:13] withSize:CGSizeMake(UD_SCREEN_WIDTH, kUDEventHeight)];
    return size.width+(kUDEventToHorizontalEdgeSpacing*2);
}

@end
