//
//  UdeskHistoryMessage.m
//  UdeskSDK
//
//  Created by 姚光辉 on 2022/5/9.
//  Copyright © 2022 Udesk. All rights reserved.
//

#import "UdeskNewMessageTag.h"
#import "UdeskNewMessageTagCell.h"

/** New垂直距离 */
static CGFloat const kUDNewToVerticalEdgeSpacing = 10;
/** New水平距离 */
static CGFloat const kUDNewToHorizontalEdgeSpacing = 8;
/** New高度 */
static CGFloat const kUDNewHeight = 30;

@interface UdeskNewMessageTag()

/** 提示文字Frame */
@property (nonatomic, assign, readwrite) CGRect newLabelFrame;

@end

@implementation UdeskNewMessageTag

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutEventMessage];
    }
    return self;
}

- (void)layoutEventMessage {

    CGFloat newWidth = [self getEventContentWidth:self.message.content];
    self.newLabelFrame = CGRectMake((UD_SCREEN_WIDTH-newWidth)/2, CGRectGetMaxY(self.dateFrame)+kUDNewToVerticalEdgeSpacing, newWidth, kUDNewHeight);
    
    self.cellHeight = self.newLabelFrame.size.height + self.newLabelFrame.origin.y + kUDNewToVerticalEdgeSpacing;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskNewMessageTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (CGFloat)getEventContentWidth:(NSString *)eventContent {

    CGSize size = [UdeskStringSizeUtil sizeWithText:eventContent font:[UIFont systemFontOfSize:13] size:CGSizeMake(UD_SCREEN_WIDTH, kUDNewHeight)];
    return size.width+(kUDNewToHorizontalEdgeSpacing*2);
}

@end
