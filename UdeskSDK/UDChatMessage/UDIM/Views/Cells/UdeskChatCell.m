//
//  UdeskChatCell.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/15.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskChatCell.h"
#import "UdeskChatMessage.h"
#import "UdeskLabel.h"
#import "UdeskSDKConfig.h"
#import "UdeskDateFormatter.h"
#import "UdeskConfigurationHelper.h"
#import "UdeskPhotoManeger.h"
#import "UdeskAudioPlayerHelper.h"
#import "UdeskAlertController.h"
#import "UdeskUtils.h"
#import "UdeskTools.h"
#import "UdeskFoundationMacro.h"

#define VoicePlayHasInterrupt @"VoicePlayHasInterrupt"

@interface UdeskChatCell() <UDLabelDelegate,UDAudioPlayerHelperDelegate> {

    UILabel          *dateLabel;//时间
    UIImageView      *avatarImageView;//头像
    UIImageView      *bubbleImageView;//气泡
    UdeskLabel       *contentLabel;//文字
    UIImageView      *contentImageView;//图片
    UIImageView      *animationVoiceImageView;//语音动画
    UdeskChatMessage *_chatMessage;//消息对象
    BOOL              contentVoiceIsPlaying;
}

@end

@implementation UdeskChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //时间
        dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        dateLabel.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.chatTimeColor;
        dateLabel.font = [UdeskSDKConfig sharedConfig].sdkStyle.messageTimeFont;
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:dateLabel];
        
        //头像
        avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UDViewRadius(avatarImageView, 20);
        [self.contentView addSubview:avatarImageView];
        
        //气泡
        bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        bubbleImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:bubbleImageView];
        
        UITapGestureRecognizer *tapBubble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBubbleImageViewAction:)];
        [bubbleImageView addGestureRecognizer:tapBubble];

        //文本消息
        if (!contentLabel) {
            contentLabel = [[UdeskLabel alloc] initWithFrame:CGRectZero];
            contentLabel.numberOfLines = 0;
            contentLabel.udLabelDelegate = self;
            contentLabel.font = [UdeskSDKConfig sharedConfig].sdkStyle.messageContentFont;
            [self.contentView addSubview:contentLabel];
            
            UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressContentLabelAction:)];
            [recognizer setMinimumPressDuration:0.4f];
            [contentLabel addGestureRecognizer:recognizer];
        }
        
        //图片消息
        if (!contentImageView) {
            contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            contentImageView.userInteractionEnabled = YES;
            contentImageView.layer.cornerRadius = 5;
            contentImageView.layer.masksToBounds  = YES;
            contentImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.contentView addSubview:contentImageView];
            //添加图片点击手势
            UITapGestureRecognizer *tapContentImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentImageViewAction:)];
            [contentImageView addGestureRecognizer:tapContentImage];
        }
        
        //语音时长
        if (!_voiceDurationLabel) {
            _voiceDurationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _voiceDurationLabel.font = [UIFont systemFontOfSize:14.f];
            _voiceDurationLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_voiceDurationLabel];
        }
        
        //语音播放动画
        if (!animationVoiceImageView) {
            animationVoiceImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            animationVoiceImageView.animationDuration = 1.0;
            [animationVoiceImageView stopAnimating];
            
            [self.contentView addSubview:animationVoiceImageView];
        }
        
        //发送loding
        if (!_activityIndicatorView) {
            _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _activityIndicatorView.frame = CGRectZero;
            _activityIndicatorView.hidden = YES;
            [self.contentView addSubview:_activityIndicatorView];
        }
        
        //发送失败
        if (!_failureImageView) {
            _failureImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            _failureImageView.userInteractionEnabled = YES;
            [self.contentView addSubview:_failureImageView];
            
            UITapGestureRecognizer *tapFailureImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFailureImageViewAction:)];
            [_failureImageView addGestureRecognizer:tapFailureImage];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVAudioPlayerDidFinishPlay) name:VoicePlayHasInterrupt object:nil];
        contentVoiceIsPlaying = NO;

    }
    return self;
}

- (void)updateCellWithMessage:(id)message {

    if ([message isKindOfClass:[UdeskChatMessage class]]) {
        
        UdeskChatMessage *chatMessage = (UdeskChatMessage *)message;
        [self updateCellWithChatMessage:chatMessage];
    }
}

- (void)updateCellWithChatMessage:(UdeskChatMessage *)chatMessage {
    
    _chatMessage = chatMessage;
    if (chatMessage.displayTimestamp) {
        //时间
        dateLabel.text = [[UdeskDateFormatter sharedFormatter] ud_styleDateForDate:chatMessage.date];
        dateLabel.hidden = NO;
    }
    else {
    
        dateLabel.hidden = NO;
    }
    //头像图片
    avatarImageView.image = chatMessage.avatarImage;
    //气泡图片
    bubbleImageView.image = chatMessage.bubbleImage;
    
    //根据发送状态显示loding或者重发按钮
    if (chatMessage.messageStatus == UDMessageSendStatusSending) {
        
        [self.activityIndicatorView startAnimating];
        self.failureImageView.hidden = YES;
        self.voiceDurationLabel.hidden = YES;
    }
    else if (chatMessage.messageStatus == UDMessageSendStatusSuccess) {
    
        [self.activityIndicatorView stopAnimating];
        self.failureImageView.hidden = YES;
        self.voiceDurationLabel.hidden = NO;
    }
    else if (chatMessage.messageStatus == UDMessageSendStatusFailed) {
        
        [self.activityIndicatorView stopAnimating];
        self.failureImageView.hidden = NO;
        self.failureImageView.image = chatMessage.failureImage;
        self.voiceDurationLabel.hidden = YES;
    }

    //文本消息
    if (chatMessage.messageType == UDMessageContentTypeText) {
        
        contentLabel.hidden = NO;
        contentLabel.text = chatMessage.text;
        //移除添加的超链接
        [contentLabel.matchArray removeAllObjects];
        //隐藏
        contentImageView.hidden = YES;
        self.voiceDurationLabel.hidden = YES;
        animationVoiceImageView.hidden = YES;
    }
    //欢迎语
    else if (chatMessage.messageType == UDMessageContentTypeRich) {
    
        contentLabel.hidden = NO;
        contentLabel.text = chatMessage.text;
        
        //设置高亮
        for (NSString *richContent in chatMessage.matchArray) {
            
            [contentLabel.matchArray addObject:richContent];
        }
        
        //隐藏
        contentImageView.hidden = YES;
        self.voiceDurationLabel.hidden = YES;
        animationVoiceImageView.hidden = YES;
    }
    //图片消息
    else if (chatMessage.messageType == UDMessageContentTypeImage) {
        
        contentImageView.hidden = NO;
        contentImageView.image = chatMessage.image;
        
        //隐藏
        contentLabel.hidden = YES;
        self.voiceDurationLabel.hidden = YES;
        animationVoiceImageView.hidden = YES;
    }
    //语音消息
    else if (chatMessage.messageType == UDMessageContentTypeVoice) {
        
        //语音时长
        self.voiceDurationLabel.text = [NSString stringWithFormat:@"%@\'\'", chatMessage.voiceDuration];
        
        //语音播放动画
        animationVoiceImageView.hidden = NO;
        animationVoiceImageView.image = chatMessage.animationVoiceImage;
        animationVoiceImageView.animationImages = chatMessage.animationVoiceImages;
        
        //隐藏
        contentLabel.hidden = YES;
        contentImageView.hidden = YES;
    }
    
    //昵称
    if (chatMessage.messageFrom == UDMessageTypeReceiving) {
        
        contentLabel.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.agentTextColor;
        self.voiceDurationLabel.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.agentVoiceDurationColor;
        self.voiceDurationLabel.textAlignment = NSTextAlignmentLeft;
    }
    else {
        contentLabel.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.customerTextColor;
        self.voiceDurationLabel.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.customerVoiceDurationColor;
        self.voiceDurationLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    if (_chatMessage.displayTimestamp) {
        //时间
        dateLabel.frame = _chatMessage.dateFrame;
        dateLabel.center = CGPointMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) / 2.0, dateLabel.center.y);
        dateLabel.hidden = NO;
    }
    else {
        
        dateLabel.hidden = YES;
    }
    //头像
    avatarImageView.frame = _chatMessage.avatarFrame;
    //气泡
    bubbleImageView.frame = _chatMessage.bubbleImageFrame;
    //发送失败
    self.failureImageView.frame = _chatMessage.failureFrame;
    //发送中
    self.activityIndicatorView.frame = _chatMessage.activityIndicatorFrame;
    //语音播放图片
    animationVoiceImageView.frame = _chatMessage.animationVoiceFrame;
    
    //文本消息
    if (_chatMessage.messageType == UDMessageContentTypeText || _chatMessage.messageType == UDMessageContentTypeRich) {
        
        contentLabel.frame = _chatMessage.textFrame;
    }
    //图片消息
    else if (_chatMessage.messageType == UDMessageContentTypeImage) {
        
        contentImageView.frame = _chatMessage.imageFrame;
        
        UIImageView *ImageView = [[UIImageView alloc] init];
        [ImageView setFrame:contentImageView.frame];
        [ImageView setImage:_chatMessage.bubbleImage];

        CALayer *layer              = ImageView.layer;
        layer.frame                 = (CGRect){{0,0},ImageView.layer.frame.size};
        contentImageView.layer.mask = layer;
        [contentImageView setNeedsDisplay];
    }
    //语音消息
    else if (_chatMessage.messageType == UDMessageContentTypeVoice) {
        
        self.voiceDurationLabel.frame = _chatMessage.voiceDurationFrame;
    }

}

#pragma mark - UDLabelDelegate
- (void)toucheBenginUDLabel:(UdeskLabel *)udLabel withContext:(NSString *)context {
    
    NSString *httpUrl = context;
    
    if (_chatMessage.messageType == UDMessageContentTypeRich) {
        
        httpUrl = [_chatMessage.richURLDictionary objectForKey:context];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:httpUrl]];
}

//检索文本的正则表达式的字符串
- (NSString *)contentsOfRegexStringWithUDLabel:(UdeskLabel *)udLabel
{
    //需要添加链接字符串的正则表达式：http:// (开发者可以根据自身需求添加正则)
    NSString *regex = @"http(s)?://([A-Za-z0-9._-]+(/)?)*";
    return regex;
}

//长按复制
- (void)longPressContentLabelAction:(UILongPressGestureRecognizer *)longPressGestureRecognizer {

    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
    
    NSArray *popMenuTitles = [[UdeskConfigurationHelper appearance] popMenuTitles];
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < popMenuTitles.count; i ++) {
        NSString *title = popMenuTitles[i];
        SEL action = nil;
        switch (i) {
            case 0: {
                if (_chatMessage.messageType == UDMessageContentTypeText||_chatMessage.messageType == UDMessageContentTypeRich) {
                    action = @selector(copyed:);
                }
                break;
            }
                
            default:
                break;
        }
        if (action) {
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:title action:action];
            if (item) {
                [menuItems addObject:item];
            }
        }
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:menuItems];
    
    CGRect targetRect = [self convertRect:_chatMessage.bubbleImageFrame
                                 fromView:self];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    [menu setMenuVisible:YES animated:YES];
}

//点击气泡（播放语音）
- (void)tapBubbleImageViewAction:(UIGestureRecognizer *)tap {

    if (_chatMessage.messageType == UDMessageContentTypeVoice) {
        UdeskAudioPlayerHelper *playerHelper = [UdeskAudioPlayerHelper shareInstance];

        if (!contentVoiceIsPlaying) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:VoicePlayHasInterrupt object:nil];
            contentVoiceIsPlaying = YES;
            [animationVoiceImageView startAnimating];
            playerHelper.delegate = self;
            [playerHelper playAudioWithVoiceData:_chatMessage.voiceData];
        }
        else {
        
            [self AVAudioPlayerDidFinishPlay];

        }
        
    }
}

- (void)AVAudioPlayerDidFinishPlay {

    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [animationVoiceImageView stopAnimating];
    contentVoiceIsPlaying = NO;
    [[UdeskAudioPlayerHelper shareInstance] stopAudio];

}

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {

    [animationVoiceImageView stopAnimating];
}

//点击图片
- (void)tapContentImageViewAction:(UIGestureRecognizer *)tap {

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didSelectImageCell)]) {
            [self.delegate didSelectImageCell];
        }
    }
    
    UdeskPhotoManeger *photoManeger = [UdeskPhotoManeger maneger];
    NSString *url = _chatMessage.mediaURL?_chatMessage.mediaURL:_chatMessage.messageId;

    [photoManeger showLocalPhoto:contentImageView withMessageURL:url];
}

//点击失败重发图片事件
- (void)tapFailureImageViewAction:(UIGestureRecognizer *)tap {

    UdeskAlertController *againMsgController = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"udesk_resend_msg")];
    [againMsgController addCloseActionWithTitle:getUDLocalizedString(@"udesk_cancel") Handler:NULL];
    [againMsgController addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") handler:^(UdeskAlertAction * _Nonnull action) {
        
        if (![[UdeskTools internetStatus] isEqualToString:@"notReachable"]) {
            
            self.failureImageView.hidden = YES;
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UdeskClickResendMessage object:nil userInfo:@{@"failedMessage":_chatMessage}];
            
        }
        else {
            
            UdeskAlertController *notNetWork = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"udesk_network_interrupt")];
            [notNetWork addCloseActionWithTitle:getUDLocalizedString(@"udesk_cancel") Handler:NULL];
            [notNetWork showWithSender:nil controller:nil animated:YES completion:NULL];
        }
        
    }]];
    
    [againMsgController showWithSender:nil controller:nil animated:YES completion:NULL];
}

#pragma mark - 复制
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copyed:));
}

- (void)copyed:(id)sender {
    
    [[UIPasteboard generalPasteboard] setString:contentLabel.text];
    [self resignFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VoicePlayHasInterrupt object:nil];
}

@end
