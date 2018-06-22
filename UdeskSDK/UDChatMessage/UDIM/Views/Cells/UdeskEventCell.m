//
//  UdeskEventCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/4/25.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskEventCell.h"
#import "UdeskEventMessage.h"
#import "UdeskSDKUtil.h"

@interface UdeskEventCell()

/**  提示信息 */
@property (nonatomic, strong) UdeskEventMessage *eventMessage;
/**  提示信息Label */
@property (nonatomic, strong) UILabel *eventLabel;

@end

@implementation UdeskEventCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    
    [super updateCellWithMessage:baseMessage];
    
    UdeskEventMessage *eventMessage = (UdeskEventMessage *)baseMessage;
    if (!eventMessage || ![eventMessage isKindOfClass:[UdeskEventMessage class]]) return;
    
    if ([UdeskSDKUtil isBlankString:eventMessage.message.content]) {
        return;
    }
    if (!eventMessage.message.timestamp) {
        return;
    }
    
    self.eventLabel.text = eventMessage.message.content;
    self.eventLabel.frame = eventMessage.eventLabelFrame;
}

- (UILabel *)eventLabel {
    
    if (!_eventLabel) {
        _eventLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _eventLabel.textColor = [UIColor colorWithRed:0.6f  green:0.6f  blue:0.6f alpha:1];
        _eventLabel.textAlignment = NSTextAlignmentCenter;
        _eventLabel.font = [UIFont systemFontOfSize:13];
        _eventLabel.layer.masksToBounds = YES;
        _eventLabel.layer.cornerRadius = 3;
        _eventLabel.backgroundColor = [UIColor colorWithRed:0.894f  green:0.894f  blue:0.894f alpha:1];
        [self.contentView addSubview:_eventLabel];
    }
    
    return _eventLabel;
}

@end
