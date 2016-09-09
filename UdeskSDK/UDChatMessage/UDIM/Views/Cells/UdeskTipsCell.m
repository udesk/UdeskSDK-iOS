//
//  UdeskTipsCell.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/12.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskTipsCell.h"
#import "UdeskTipsMessage.h"

@interface UdeskTipsCell()

/**  提示信息Label */
@property (nonatomic, strong) UILabel          *tipsLabel;
/**  提示信息 */
@property (nonatomic, strong) UdeskTipsMessage *tipsMessage;

@end

@implementation UdeskTipsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateCellWithMessage:(id)message {

    if ([message isKindOfClass:[UdeskTipsMessage class]]) {
        
        UdeskTipsMessage *tipsMessage = (UdeskTipsMessage *)message;
        [self updateCellWithTipsMessage:tipsMessage];
    }
}

- (void)updateCellWithTipsMessage:(UdeskTipsMessage *)tipsMessage {

    _tipsMessage = tipsMessage;
    
    self.tipsLabel.text = tipsMessage.tipText;
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    self.tipsLabel.frame = self.tipsMessage.tipLabelFrame;
    
}

- (UILabel *)tipsLabel {

    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = [UIColor lightGrayColor];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_tipsLabel];
    }
    
    return _tipsLabel;
}

@end
