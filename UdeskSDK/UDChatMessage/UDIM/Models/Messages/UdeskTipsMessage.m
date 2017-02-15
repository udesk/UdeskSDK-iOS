//
//  UdeskTipsMessage.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/12.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskTipsMessage.h"
#import "UdeskMessage.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskFoundationMacro.h"
#import "UdeskTools.h"
#import "UdeskTipsCell.h"

/** Tips垂直距离 */
static CGFloat const kUDTipToVerticalEdgeSpacing = 5;
/** Tips高度 */
static CGFloat const kUDTipHeight = 20;

@interface UdeskTipsMessage()

/** 提示文字Frame */
@property (nonatomic, assign, readwrite) CGRect  tipLabelFrame;

@end

@implementation UdeskTipsMessage

- (instancetype)initWithUdeskMessage:(UdeskMessage *)message
{
    self = [super init];
    if (self) {
        
        if ([UdeskTools isBlankString:message.messageId]) {
            return nil;
        }
        if ([UdeskTools isBlankString:message.content]) {
            return nil;
        }
        
        self.date = message.timestamp;
        
        self.messageId = message.messageId;
        
        self.tipText = message.content;
        
        self.tipLabelFrame = CGRectMake(0, kUDTipToVerticalEdgeSpacing, UD_SCREEN_WIDTH, kUDTipHeight);
        
        self.cellHeight = self.tipLabelFrame.size.height + kUDTipToVerticalEdgeSpacing*2;
        
    }
    return self;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
