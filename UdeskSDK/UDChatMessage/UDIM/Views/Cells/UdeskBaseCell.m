//
//  UdeskBaseCell.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/17.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseCell.h"
#import "UdeskSDKConfig.h"
#import "UdeskDateUtil.h"
#import "UIImage+UdeskSDK.h"
#import "Udesk_YYWebImage.h"
#import "UdeskSDKUtil.h"

@interface UdeskBaseCell ()

/** 客户头像 */
@property (nonatomic, strong, readwrite) UIImageView *avatarImageView;
/** 气泡 */
@property (nonatomic, strong, readwrite) UIImageView *bubbleImageView;
/** 客服昵称 */
@property (nonatomic, strong, readwrite) UILabel     *nicknameLabel;
/** 时间 */
@property (nonatomic, strong, readwrite) UILabel     *dateLabel;
/** 重发 */
@property (nonatomic, strong, readwrite) UIButton    *resetButton;
/** 菊花 */
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *sendingIndicator;

@end

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

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.textColor = [UdeskSDKConfig customConfig].sdkStyle.agentNicknameColor;
        _nicknameLabel.font = [UdeskSDKConfig customConfig].sdkStyle.agentNicknameFont;
        [self.contentView addSubview:_nicknameLabel];
    }
    return _nicknameLabel;
}

- (UILabel *)dateLabel {
    
    if (!_dateLabel) {
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _dateLabel.textColor = [UdeskSDKConfig customConfig].sdkStyle.chatTimeColor;
        _dateLabel.font = [UdeskSDKConfig customConfig].sdkStyle.messageTimeFont;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UIButton *)resetButton {
    
    if (!_resetButton) {
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resetButton setImage:[UIImage udDefaultResetButtonImage] forState:UIControlStateNormal];
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
    if (baseMessage.message.messageType == UDMessageContentTypeLeaveEvent ||
        baseMessage.message.messageType == UDMessageContentTypeRollback ||
        baseMessage.message.messageType == UDMessageContentTypeRedirect) {
        
        NSDateFormatter *formatter = [UdeskDateUtil sharedFormatter].dateFormatter;
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        NSString *date = [formatter stringFromDate:baseMessage.message.timestamp];
        self.dateLabel.text = [NSString stringWithFormat:@"——— %@ ———",date];
    }
    else {
        self.dateLabel.text = [[UdeskDateUtil sharedFormatter] udStyleDateForDate:baseMessage.message.timestamp];
    }
    
    //头像位置
    self.avatarImageView.frame = baseMessage.avatarFrame;
    
    //头像图片
    if (![UdeskSDKUtil isBlankString:baseMessage.avatarURL]) {
        [self.avatarImageView udesk_yy_setImageWithURL:[NSURL URLWithString:[baseMessage.avatarURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:baseMessage.avatarImage];
    }
    else {
        self.avatarImageView.image = baseMessage.avatarImage;
    }
    
    //气泡
    self.bubbleImageView.frame = baseMessage.bubbleFrame;
    self.sendingIndicator.frame = baseMessage.loadingFrame;
    self.resetButton.frame = baseMessage.failureFrame;
    
    switch (baseMessage.message.messageFrom) {
        case UDMessageTypeReceiving:{
            
            //气泡
            UIImage *bubbleImage = [UdeskSDKConfig customConfig].sdkStyle.agentBubbleImage;
            UIColor *bubbleColor = [UdeskSDKConfig customConfig].sdkStyle.agentBubbleColor;
            
            if (bubbleColor && [bubbleColor isKindOfClass:[UIColor class]]) {
                bubbleImage = [bubbleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.bubbleImageView.tintColor = bubbleColor;
            }
            
            self.bubbleImageView.image = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width*0.5f topCapHeight:bubbleImage.size.height*0.8f];
            
            //客服昵称
            self.nicknameLabel.frame = baseMessage.nicknameFrame;
            self.nicknameLabel.text = [UdeskSDKUtil isBlankString:baseMessage.message.nickName]?@"":baseMessage.message.nickName;
            
            break;
        }
        case UDMessageTypeSending:{
         
            //气泡
            UIImage *bubbleImage = [UdeskSDKConfig customConfig].sdkStyle.customerBubbleImage;
            UIColor *bubbleColor = [UdeskSDKConfig customConfig].sdkStyle.customerBubbleColor;
            
            if (bubbleColor && [bubbleColor isKindOfClass:[UIColor class]]) {
                bubbleImage = [bubbleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.bubbleImageView.tintColor = bubbleColor;
            }
            
            self.bubbleImageView.image = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width*0.5f topCapHeight:bubbleImage.size.height*0.8f];
            
            self.nicknameLabel.frame = CGRectZero;
            self.nicknameLabel.text = @"";
            
            break;
        }
            
        default:
            break;
    }
    
    if (baseMessage.message.messageType == UDMessageContentTypeText ||
        baseMessage.message.messageType == UDMessageContentTypeImage ||
        baseMessage.message.messageType == UDMessageContentTypeLeaveMsg ||
        baseMessage.message.messageType == UDMessageContentTypeVoice ||
        baseMessage.message.messageType == UDMessageContentTypeVideo ||
        baseMessage.message.messageType == UDMessageContentTypeGoods) {
    
        [self updateMessageSendStatus:baseMessage.message.messageStatus];
    }
    else {
        self.sendingIndicator.hidden = YES;
        [self.sendingIndicator stopAnimating];
        self.resetButton.hidden = YES;
    }
}

- (void)updateMessageSendStatus:(UDMessageSendStatus)sendStatus {
    
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
        case UDMessageSendStatusOffSending:
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didResendMessage:)]) {
        [self.delegate didResendMessage:self.baseMessage.message];
    }
}

@end
