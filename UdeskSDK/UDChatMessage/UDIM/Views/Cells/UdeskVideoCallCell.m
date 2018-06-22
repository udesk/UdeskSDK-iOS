//
//  UdeskVideoCallCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/12/6.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVideoCallCell.h"
#import "UdeskVideoCallMessage.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKConfig.h"

@interface UdeskVideoCallCell()

@property (nonatomic, strong) UILabel *videoCallLabel;

@end

@implementation UdeskVideoCallCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initTextLabel];
    }
    return self;
}

- (void)initTextLabel {
    
    _videoCallLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _videoCallLabel.numberOfLines = 0;
    _videoCallLabel.textAlignment = NSTextAlignmentLeft;
    _videoCallLabel.userInteractionEnabled = true;
    _videoCallLabel.backgroundColor = [UIColor clearColor];
    _videoCallLabel.font = [UdeskSDKConfig customConfig].sdkStyle.messageContentFont;
    
    [self.bubbleImageView addSubview:_videoCallLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBubbleImageViewAction:)];
    [self.bubbleImageView addGestureRecognizer:tap];
}

//点击重播
- (void)tapBubbleImageViewAction:(UIGestureRecognizer *)tap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapUdeskVideoCallMessage:)]) {
        [self.delegate didTapUdeskVideoCallMessage:self.baseMessage.message];
    }
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    
    [super updateCellWithMessage:baseMessage];
    
    UdeskVideoCallMessage *callMessage = (UdeskVideoCallMessage *)baseMessage;
    if (!callMessage || ![callMessage isKindOfClass:[UdeskVideoCallMessage class]]) return;
    
    if ([UdeskSDKUtil isBlankString:callMessage.message.content]) {
        self.videoCallLabel.text = @"";
    }
    else {
        self.videoCallLabel.attributedText = callMessage.cellText;
    }
    
    //设置frame
    self.videoCallLabel.frame = callMessage.textFrame;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
