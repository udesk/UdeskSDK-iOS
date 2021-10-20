//
//  UdeskTableMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskTableMessage.h"
#import "UdeskTableCell.h"
#import "NSAttributedString+UdeskHTML.h"

/** 水平间距 */
const CGFloat kUDBubbleToTableHorizontalSpacing = 14.0;
/** 垂直间距 */
const CGFloat kUDBubbleToTableVerticalSpacing = 14.0;
/** 垂直间距 */
const CGFloat kUDBubbleToTitleVerticalSpacing = 10.0;
/** 高度 */
const CGFloat kUDSingleTableHeight = 40.0;

@interface UdeskTableMessage ()

@property (nonatomic, copy  , readwrite) NSAttributedString *titleAttributedString;
@property (nonatomic, assign, readwrite) CGRect titleFrame;
@property (nonatomic, assign, readwrite) CGRect lineFrame;
@property (nonatomic, assign, readwrite) CGRect tableFrame;
@property (nonatomic, assign, readwrite) CGFloat singleTableWidth;

@end

@implementation UdeskTableMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutTableMessage];
    }
    return self;
}

- (void)layoutTableMessage {
    
    if (!self.message.table || self.message.table == (id)kCFNull) return ;
    
    if (self.message.messageFrom == UDMessageTypeReceiving) {
        
        self.titleAttributedString = [NSAttributedString attributedStringFromHTML:self.message.answerTitle customFont:[UIFont systemFontOfSize:15]];
        
        CGSize titleSize = [UdeskStringSizeUtil sizeWithAttributedText:self.titleAttributedString size:CGSizeMake([self tableMaxWidth], CGFLOAT_MAX)];
        self.titleFrame = CGRectMake(kUDBubbleToTableHorizontalSpacing, kUDBubbleToTitleVerticalSpacing, [self tableMaxWidth], titleSize.height);
        self.lineFrame = CGRectMake(0, CGRectGetMaxY(self.titleFrame), [self tableMaxWidth]+(kUDBubbleToTableHorizontalSpacing*2), 1);
        
        CGFloat height = 0;
        if (self.message.rowNumber) {
            height = self.message.rowNumber.integerValue * kUDSingleTableHeight + (kUDBubbleToTableVerticalSpacing*2);
        }
        
        self.singleTableWidth = 0;
        if (self.message.columnNumber) {
            self.singleTableWidth = ([self tableMaxWidth]-(self.message.columnNumber.integerValue*kUDBubbleToTableHorizontalSpacing-kUDBubbleToTableHorizontalSpacing))/self.message.columnNumber.integerValue;
        }
        
        self.tableFrame = CGRectMake(kUDBubbleToTableHorizontalSpacing, CGRectGetMaxY(self.lineFrame)+kUDBubbleToTitleVerticalSpacing, [self tableMaxWidth], height);
        
        self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, [self tableMaxWidth]+kUDBubbleToTableHorizontalSpacing*2, CGRectGetMaxY(self.tableFrame)+kUDBubbleToTableVerticalSpacing);
    }
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin+self.transferHeight;
}

- (CGFloat)tableMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH)-(kUDBubbleToTableHorizontalSpacing*2);
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
