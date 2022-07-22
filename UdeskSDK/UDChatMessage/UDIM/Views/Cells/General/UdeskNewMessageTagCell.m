//
//  UdeskNewMessageTagCell.m
//  UdeskSDK
//
//  Created by 姚光辉 on 2022/5/9.
//  Copyright © 2022 Udesk. All rights reserved.
//

#import "UdeskNewMessageTagCell.h"
#import "UdeskNewMessageTag.h"

@interface UdeskNewMessageTagCell()

/**  提示信息Label */
@property (nonatomic, strong) UILabel *newLabel;
@property (nonatomic, strong) UIView *headerLine;
@property (nonatomic, strong) UIView *footerLine;

@end

@implementation UdeskNewMessageTagCell

- (void)updateCellWithMessage:(UdeskNewMessageTag *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskNewMessageTag *newMessage = (UdeskNewMessageTag *)baseMessage;
    if (!newMessage || ![newMessage isKindOfClass:[UdeskNewMessageTag class]]) return;
    
    if ([UdeskSDKUtil isBlankString:newMessage.message.content]) {
        return;
    }
    if (!newMessage.message.timestamp) {
        return;
    }
    self.newLabel.text = newMessage.message.content;
    self.newLabel.frame = newMessage.newLabelFrame;
    
    CGFloat margin = 16;
    CGFloat yFrame = newMessage.newLabelFrame.origin.y + newMessage.newLabelFrame.size.height/2 - 0.5;
    CGFloat lineWidth = newMessage.newLabelFrame.origin.x - margin;
    self.headerLine.frame = CGRectMake(margin, yFrame, lineWidth, 1);
    self.footerLine.frame = CGRectMake(newMessage.newLabelFrame.origin.x + newMessage.newLabelFrame.size.width, yFrame, lineWidth, 1);
}

- (UILabel *)newLabel {
    if (!_newLabel) {
        _newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _newLabel.textColor = [UIColor lightGrayColor];
        _newLabel.textAlignment = NSTextAlignmentCenter;
        _newLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_newLabel];
    }
    return _newLabel;
}

- (UIView *)headerLine {
    if (!_headerLine) {
        _headerLine = [[UIView alloc] initWithFrame:CGRectZero];
        _headerLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_headerLine];
    }
    return _headerLine;
}

- (UIView *)footerLine {
    if (!_footerLine) {
        _footerLine = [[UIView alloc] initWithFrame:CGRectZero];
        _footerLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_footerLine];
    }
    return _footerLine;
}

@end
