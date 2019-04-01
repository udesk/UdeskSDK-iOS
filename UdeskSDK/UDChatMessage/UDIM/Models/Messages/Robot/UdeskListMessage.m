//
//  UdeskListMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskListMessage.h"
#import "UdeskListCell.h"
#import "NSAttributedString+UdeskHTML.h"

/** 聊天气泡和其中的文字水平间距 */
static CGFloat const kUDBubbleToListHorizontalSpacing = 14.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDBubbleToListVerticalSpacing = 10.0;
/** 高度 */
const CGFloat kUDListHeight = 44.0;

@interface UdeskListMessage()

@property (nonatomic, copy  , readwrite) NSAttributedString *titleAttributedString;
@property (nonatomic, assign, readwrite) CGRect titleFrame;
@property (nonatomic, assign, readwrite) CGRect lineFrame;
@property (nonatomic, assign, readwrite) CGRect listFrame;

@end

@implementation UdeskListMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutListMessage];
    }
    return self;
}

- (void)layoutListMessage {
    
    if (!self.message.list || self.message.list == (id)kCFNull) return ;
    
    if (self.message.messageFrom == UDMessageTypeReceiving) {
        
        self.titleAttributedString = [NSAttributedString attributedStringFromHTML:self.message.answerTitle customFont:[UIFont systemFontOfSize:15]];
        
        CGSize titleSize = [UdeskStringSizeUtil getSizeForAttributedText:self.titleAttributedString textWidth:[self listMaxWidth]];
        self.titleFrame = CGRectMake(kUDBubbleToListHorizontalSpacing, kUDBubbleToListVerticalSpacing, [self listMaxWidth], titleSize.height);
        self.lineFrame = CGRectMake(0, CGRectGetMaxY(self.titleFrame), [self listMaxWidth]+kUDBubbleToListHorizontalSpacing*2, 1);
        self.listFrame = CGRectMake(kUDBubbleToListHorizontalSpacing, CGRectGetMaxY(self.lineFrame), [self listMaxWidth], self.message.list.count*kUDListHeight+kUDBubbleToListVerticalSpacing);
        
        self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, [self listMaxWidth]+kUDBubbleToListHorizontalSpacing*2, CGRectGetMaxY(self.listFrame)+kUDBubbleToListVerticalSpacing);
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin+self.transferHeight;
}

- (CGFloat)listMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH)-(kUDBubbleToListHorizontalSpacing*2);
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
