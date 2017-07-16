//
//  UdeskBaseCell.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/17.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseCell.h"
#import "UdeskSDKConfig.h"
#import "UdeskDateFormatter.h"
#import "UdeskViewExt.h"
#import "UIImage+UdeskSDK.h"
#import "Udesk_YYWebImage.h"

@implementation UdeskBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (UIImageView *)avatarImageView {
    
    if (!_avatarImageView) {
        
        //初始化头像
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.userInteractionEnabled = YES;
        UDViewRadius(_avatarImageView, 20);
        [self.contentView addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (UIImageView *)bubbleImageView {
    
    if (!_bubbleImageView) {
        
        //初始化气泡
        _bubbleImageView = [[UIImageView alloc] init];
        _bubbleImageView.userInteractionEnabled = true;
        [self.contentView addSubview:_bubbleImageView];
    }
    
    return _bubbleImageView;
}

- (UILabel *)dateLabel {
    
    if (!_dateLabel) {
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _dateLabel.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.chatTimeColor;
        _dateLabel.font = [UdeskSDKConfig sharedConfig].sdkStyle.messageTimeFont;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UIButton *)resetButton {
    
    if (!_resetButton) {
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resetButton setImage:[UIImage ud_defaultResetButtonImage] forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(tapResetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_resetButton];
    }
    return _resetButton;
}

- (UIActivityIndicatorView *)sendingIndicator {
    
    if (!_sendingIndicator) {
        _sendingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_sendingIndicator];
    }
    return _sendingIndicator;
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {

    if (!baseMessage || baseMessage == (id)kCFNull) return ;
    self.baseMessage = baseMessage;
    //时间
    self.dateLabel.frame = baseMessage.dateFrame;
    if (baseMessage.message.messageType == UDMessageContentTypeLeave) {
        
        NSDateFormatter *formatter = [UdeskDateFormatter sharedFormatter].dateFormatter;
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        NSString *date = [formatter stringFromDate:baseMessage.message.timestamp];
        self.dateLabel.text = [NSString stringWithFormat:@"——— %@ ———",date];
    }
    else {
        self.dateLabel.text = [[UdeskDateFormatter sharedFormatter] ud_styleDateForDate:baseMessage.message.timestamp];
    }
    
    //头像位置
    self.avatarImageView.frame = baseMessage.avatarFrame;
    //头像图片
    [self.avatarImageView yy_setImageWithURL:[NSURL URLWithString:baseMessage.avatarURL] placeholder:baseMessage.avatarImage];
    
    //气泡
    self.bubbleImageView.frame = baseMessage.bubbleFrame;
    self.sendingIndicator.frame = baseMessage.loadingFrame;
    self.resetButton.frame = baseMessage.failureFrame;
    
    switch (baseMessage.message.messageFrom) {
        case UDMessageTypeReceiving:{
            
            //气泡
            UIImage *bubbleImage = [UdeskSDKConfig sharedConfig].sdkStyle.agentBubbleImage;
            
            if ([UdeskSDKConfig sharedConfig].sdkStyle.agentBubbleColor) {
                bubbleImage = [bubbleImage convertImageColor:[UdeskSDKConfig sharedConfig].sdkStyle.agentBubbleColor];
            }
            
            self.bubbleImageView.image = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width*0.5f topCapHeight:bubbleImage.size.height*0.8f];
            
            break;
        }
        case UDMessageTypeSending:{
         
            //气泡
            UIImage *bubbleImage = [UdeskSDKConfig sharedConfig].sdkStyle.customerBubbleImage;
            if ([UdeskSDKConfig sharedConfig].sdkStyle.customerBubbleColor) {
                bubbleImage = [bubbleImage convertImageColor:[UdeskSDKConfig sharedConfig].sdkStyle.customerBubbleColor];
            }
            self.bubbleImageView.image = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width*0.5f topCapHeight:bubbleImage.size.height*0.8f];
            
            break;
        }
            
        default:
            break;
    }
    
    if (baseMessage.message.messageType == UDMessageContentTypeText ||
        baseMessage.message.messageType == UDMessageContentTypeImage ||
        baseMessage.message.messageType == UDMessageContentTypeVoice ||
        baseMessage.message.messageType == UDMessageContentTypeVideo) {
    
        [self setActivityIndicatorViewFrameWithSendStatus:baseMessage.message.messageStatus];
    }
}

- (void)setActivityIndicatorViewFrameWithSendStatus:(UDMessageSendStatus)sendStatus {
    
    //菊花和重发
    switch (sendStatus) {
        case UDMessageSendStatusFailed:
            self.sendingIndicator.hidden = YES;
            [self.sendingIndicator stopAnimating];
            self.resetButton.hidden = NO;
            break;
        case UDMessageSendStatusSending:
            self.sendingIndicator.hidden = NO;
            [self.sendingIndicator startAnimating];
            self.resetButton.hidden = YES;
            break;
        case UDMessageSendStatusSuccess:
            [self.sendingIndicator stopAnimating];
            self.sendingIndicator.hidden = YES;
            self.resetButton.hidden = YES;
            
            break;
            
        default:
            break;
    }
}

- (void)tapResetButtonAction:(UIButton *)button {

    self.resetButton.hidden = YES;
    self.sendingIndicator.hidden = NO;
    [self.sendingIndicator startAnimating];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(resendMessageInCell:resendMessage:)]) {
        [self.delegate resendMessageInCell:self resendMessage:self.baseMessage.message];
    }
}

@end
