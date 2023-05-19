//
//  UdeskBaseCell.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/17.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseCell.h"
#import "UdeskDateUtil.h"
#import "Udesk_YYWebImage.h"
#import "UdeskBundleUtils.h"
#import "UdeskAlertController.h"
#import "UdeskManager.h"
#import "UdeskSDKShow.h"
#import "UdeskMessage+UdeskSDK.h"
#import "UdeskPhotoManager.h"

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
/** 转人工 */
@property (nonatomic, strong) UIButton    *transferButton;
/** 有用 */
@property (nonatomic, strong) UIButton    *usefulButton;
/** 无用 */
@property (nonatomic, strong) UIButton    *uselessButton;

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
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.userInteractionEnabled = YES;
        UDViewRadius(_avatarImageView, 12);
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

- (UIButton *)transferButton {
    
    if (!_transferButton) {
        _transferButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _transferButton.titleLabel.font = [UIFont systemFontOfSize:14];
        UDViewBorderRadius(_transferButton, 16, 1, [UIColor colorWithRed:0.18f  green:0.478f  blue:0.91f alpha:1]);
        [_transferButton setTitleColor:[UIColor colorWithRed:0.18f  green:0.478f  blue:0.91f alpha:1] forState:UIControlStateNormal];
        [_transferButton setTitle:getUDLocalizedString(@"udesk_redirect") forState:UIControlStateNormal];
        [_transferButton addTarget:self action:@selector(tapTransferButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_transferButton];
    }
    return _transferButton;
}

- (UIButton *)usefulButton {
    
    if (!_usefulButton) {
        _usefulButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_usefulButton setImage:[UIImage udDefaultUseful] forState:UIControlStateNormal];
        [_usefulButton setImage:[UIImage udDefaultUsefulSelected] forState:UIControlStateSelected];;
        [_usefulButton addTarget:self action:@selector(tapUsefulButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_usefulButton];
    }
    return _usefulButton;
}

- (UIButton *)uselessButton {
    
    if (!_uselessButton) {
        _uselessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_uselessButton setImage:[UIImage udDefaultUseless] forState:UIControlStateNormal];
        [_uselessButton setImage:[UIImage udDefaultUselessSelected] forState:UIControlStateSelected];;
        [_uselessButton addTarget:self action:@selector(tapUselessButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_uselessButton];
    }
    return _uselessButton;
}

#pragma mark - 消息处理
- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {

    if (!baseMessage || baseMessage == (id)kCFNull) return ;
    self.baseMessage = baseMessage;
    //时间
    self.dateLabel.frame = baseMessage.dateFrame;
    self.dateLabel.text = [[UdeskDateUtil sharedFormatter] udStyleDateForDate:baseMessage.message.timestamp];
    
    //头像位置
    self.avatarImageView.frame = baseMessage.avatarFrame;
    
    //头像图片
    if (![UdeskSDKUtil isBlankString:baseMessage.avatarURL]) {
        [self.avatarImageView udesk_yy_setImageWithURL:[NSURL URLWithString:[baseMessage.avatarURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]] placeholder:baseMessage.avatarImage];
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
            
            self.bubbleImageView.image = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width/3 topCapHeight:bubbleImage.size.height/2];
            
            //客服昵称
            self.nicknameLabel.frame = baseMessage.nicknameFrame;
            self.nicknameLabel.text = [UdeskSDKUtil isBlankString:baseMessage.message.nickName]?@"":baseMessage.message.nickName;
            self.nicknameLabel.textAlignment = NSTextAlignmentLeft;
            
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
            
            self.bubbleImageView.image = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width/3 topCapHeight:bubbleImage.size.height/2];
            
            //客户昵称
            self.nicknameLabel.frame = baseMessage.nicknameFrame;
            self.nicknameLabel.text = [UdeskSDKConfig customConfig].sdkStyle.customerNickname;
            self.nicknameLabel.textAlignment = NSTextAlignmentRight;
            
            break;
        }
            
        default:
            break;
    }
    
    if (baseMessage.message.messageType == UDMessageContentTypeText ||
        baseMessage.message.messageType == UDMessageContentTypeImage ||
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
    
    //转人工
    [self setupAnswerTransfer];
    
    //答案评价
    [self setupAnswerEvaluation];
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
    
    UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:nil message:nil preferredStyle:UdeskAlertControllerStyleActionSheet];
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_cancel") style:UdeskAlertActionStyleCancel handler:nil]];
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_reset_message") style:UdeskAlertActionStyleDefault handler:^(UdeskAlertAction *action) {
        
        self.resetButton.hidden = YES;
        self.sendingIndicator.hidden = NO;
        [self.sendingIndicator startAnimating];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didResendMessage:)]) {
            [self.delegate didResendMessage:self.baseMessage.message];
        }
    }]];
    [[UdeskSDKUtil currentViewController] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 机器人转人工
- (void)setupAnswerTransfer {
    
    if (self.baseMessage.message.showTransfer) {
        if (![UdeskSDKUtil isBlankString:self.baseMessage.message.switchStaffTips]) {
            CGSize size = [UdeskStringSizeUtil sizeWithText:self.baseMessage.message.switchStaffTips font:[UIFont systemFontOfSize:14] size:CGSizeMake(UD_SCREEN_WIDTH-(kUDBubbleToHorizontalEdgeSpacing*2), kUDTransferHeight)];
            CGFloat transferWidth = size.width + (kUDBubbleToHorizontalEdgeSpacing*4);
            self.transferButton.frame = CGRectMake((UD_SCREEN_WIDTH-(kUDBubbleToHorizontalEdgeSpacing*2)-transferWidth)/2, CGRectGetMaxY(self.bubbleImageView.frame)+kUDTransferVerticalEdgeSpacing, transferWidth, kUDTransferHeight);
            [self.transferButton setTitle:self.baseMessage.message.switchStaffTips forState:UIControlStateNormal];
        }
        else {
            self.transferButton.frame = CGRectMake((UD_SCREEN_WIDTH-kUDTransferWidth)/2, CGRectGetMaxY(self.bubbleImageView.frame)+kUDTransferVerticalEdgeSpacing, kUDTransferWidth, kUDTransferHeight);
        }
    }
    else {
        self.transferButton.frame = CGRectZero;
    }
}

- (void)tapTransferButtonAction:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapTransferAgentServer:)]) {
        [self.delegate didTapTransferAgentServer:self.baseMessage.message];
    }
}

#pragma mark - 机器人消息 有用/无用
- (void)setupAnswerEvaluation {
    
    if (self.baseMessage.message.showUseful) {
        [self updateAnswerEvaluation:self.baseMessage.message.answerEvaluation];
    }
    else {
        self.usefulButton.frame = CGRectZero;
        self.uselessButton.frame = CGRectZero;
    }
}

- (void)tapUsefulButtonAction:(UIButton *)button {
    
    [self updateAnswerSurvey:button useful:YES];
}

- (void)tapUselessButtonAction:(UIButton *)button {
    
    [self updateAnswerSurvey:button useful:NO];
}

- (void)updateAnswerSurvey:(UIButton *)button useful:(BOOL)useful {
    
    if (self.usefulButton.selected || self.uselessButton.selected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(aswerHasSurvey)]) {
            [self.delegate aswerHasSurvey];
        }
        return ;
    }
    
    NSString *orgEvaluation = self.baseMessage.message.answerEvaluation;
    self.baseMessage.message.answerEvaluation = useful?@"1":@"2";
    
    [UdeskManager answerSurvey:self.baseMessage.message completion:^(NSError *error) {
        if (!error) {
            button.selected = YES;
            [self updateAnswerEvaluation:self.baseMessage.message.answerEvaluation];
        }
        else {
            self.baseMessage.message.answerEvaluation = orgEvaluation;
        }
    }];
}

- (void)updateAnswerEvaluation:(NSString *)answerEvaluation {
    
    if ([answerEvaluation isEqualToString:@"1"]) {
        
        self.usefulButton.hidden = NO;
        self.uselessButton.hidden = YES;
        self.usefulButton.selected = YES;
        self.uselessButton.selected = NO;
        self.usefulButton.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame)+kUDUsefulHorizontalEdgeSpacing, CGRectGetMaxY(self.bubbleImageView.frame)-kUDUsefulHeight, kUDUsefulWidth, kUDUsefulHeight);
    }
    else if ([answerEvaluation isEqualToString:@"2"]) {
        
        self.uselessButton.hidden = NO;
        self.usefulButton.hidden = YES;
        self.uselessButton.selected = YES;
        self.usefulButton.selected = NO;
        self.uselessButton.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame)+kUDUsefulHorizontalEdgeSpacing, CGRectGetMaxY(self.bubbleImageView.frame)-kUDUsefulHeight, kUDUsefulWidth, kUDUsefulHeight);
    }
    else {
        
        self.uselessButton.hidden = NO;
        self.usefulButton.hidden = NO;
        self.uselessButton.selected = NO;
        self.usefulButton.selected = NO;
        self.uselessButton.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame)+kUDUsefulHorizontalEdgeSpacing, CGRectGetMaxY(self.bubbleImageView.frame)-kUDUsefulHeight, kUDUsefulWidth, kUDUsefulHeight);
        self.usefulButton.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame)+kUDUsefulHorizontalEdgeSpacing, CGRectGetMinY(self.uselessButton.frame)-kUDUsefulHeight-kUDUsefulVerticalEdgeSpacing, kUDUsefulWidth, kUDUsefulHeight);
    }
}

#pragma mark - 富文本事件处理
- (BOOL)udRichTextView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if ([URL.absoluteString hasPrefix:@"sms:"] || [URL.absoluteString hasPrefix:@"tel:"]) {
        
        NSString *phoneNumber = [URL.absoluteString componentsSeparatedByString:@":"].lastObject;
        [self callPhoneNumber:phoneNumber];
        return NO;
    }
    else if ([URL.absoluteString hasPrefix:@"img:"]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChatImageView)]) {
            [self.delegate didTapChatImageView];
        }
        
        NSString *url = [URL.absoluteString componentsSeparatedByString:@"img:"].lastObject;
        url = [url stringByRemovingPercentEncoding];
        UdeskPhotoManager *photoManeger = [UdeskPhotoManager maneger];
        [photoManeger showLocalPhoto:(UIImageView *)self.bubbleImageView withMessageURL:url];
        return NO;
    }
    else if([URL.absoluteString hasPrefix:@"gotochat:"]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapTransferAgentServer:)]) {
            [self.delegate didTapTransferAgentServer:self.baseMessage.message];
        }
    }
    else if ([URL.absoluteString hasPrefix:@"data-type:"]) {
        
        if (textView.text.length >= (characterRange.location+characterRange.length)) {
            NSString *content = [[textView.text substringWithRange:characterRange] stringByReplacingOccurrencesOfString:@"\n" withString:@""];;
            [self flowMessageWithText:content flowContent:URL.absoluteString];
        }
        return NO;
    }
    else if ([URL.absoluteString hasPrefix:@"data-message-type:"]) {
        
        NSString *content = [[[URL.absoluteString stringByRemovingPercentEncoding] componentsSeparatedByString:@"data-content:"] lastObject];
        UdeskMessage *message = [[UdeskMessage alloc] initWithText:content];
        message.sendType = UDMessageSendTypeRobot;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSendRobotMessage:)]) {
            [self.delegate didSendRobotMessage:message];
        }
    }
    else if ([URL.absoluteString hasPrefix:@"x-apple-data-detectors:"]) {
        //点击日历等系统服务暂不支持跳转
        return NO;
    }
    
    else {
        
        if (textView.text.length >= (characterRange.location+characterRange.length)) {
            NSURL *url = [NSURL URLWithString:[textView.text substringWithRange:characterRange]];
            if (!url) {
                url = URL;
            }
            
            NSRange range = [UdeskSDKUtil linkRegexsMatch:url.absoluteString];
            if (range.location == NSNotFound) {
                url = URL;
            }
            
            [self udOpenURL:url];
        }
        else {
            [self udOpenURL:URL];
        }
        return NO;
    }
    
    return YES;
}

- (void)callPhoneNumber:(NSString *)phoneNumber {
    
    UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@\n%@",phoneNumber,getUDLocalizedString(@"udesk_phone_number_tip")] message:nil preferredStyle:UdeskAlertControllerStyleActionSheet];
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_cancel") style:UdeskAlertActionStyleCancel handler:nil]];
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_call") style:UdeskAlertActionStyleDefault handler:^(UdeskAlertAction *action) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]]];
    }]];
    
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_copy") style:UdeskAlertActionStyleDefault handler:^(UdeskAlertAction *action) {
        
        [UIPasteboard generalPasteboard].string = phoneNumber;
    }]];
    
    [[UdeskSDKUtil currentViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)flowMessageWithText:(NSString *)text flowContent:(NSString *)flowContent {
    if (!flowContent || flowContent == (id)kCFNull) return ;
    
    @try {
        
        NSArray *array = [flowContent componentsSeparatedByString:@";"];
        NSString *dataType = [array.firstObject componentsSeparatedByString:@":"].lastObject;
        NSString *dataId = [array.lastObject componentsSeparatedByString:@":"].lastObject;
        
        UdeskMessage *flowMessage = [[UdeskMessage alloc] initWithText:text];
        flowMessage.logId = self.baseMessage.message.logId;
        flowMessage.sendType = UDMessageSendTypeHit;
        
        if ([dataType isEqualToString:@"1"]) {
            flowMessage.robotType = @"1";
            flowMessage.robotQuestionId = dataId;
            flowMessage.robotQueryType = @"8";
        }
        else if ([dataType isEqualToString:@"2"]) {
            flowMessage.robotType = @"2";
            flowMessage.flowId = dataId;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSendRobotMessage:)]) {
            [self.delegate didSendRobotMessage:flowMessage];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)udOpenURL:(NSURL *)URL {
    
    //用户设置了点击链接回调
    if ([UdeskSDKConfig customConfig].actionConfig.linkClickBlock) {
        [UdeskSDKConfig customConfig].actionConfig.linkClickBlock([UdeskSDKUtil currentViewController],URL);
        return ;
    }
    
    if ([URL.absoluteString rangeOfString:@"://"].location == NSNotFound) {
        [UdeskSDKShow pushWebViewOnViewController:[UdeskSDKUtil currentViewController] URL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URL.absoluteString]]];
    } else {
        [UdeskSDKShow pushWebViewOnViewController:[UdeskSDKUtil currentViewController] URL:URL];
    }
}

#pragma mark - 机器人点击消息
- (void)didSelectRobotHitMessageAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section >= self.baseMessage.message.topAsk.count) return;
    UdeskMessageTopAsk *messageTopAsk = self.baseMessage.message.topAsk[indexPath.section];
    
    if (indexPath.row >= messageTopAsk.optionsList.count) return;
    UdeskMessageOption *option = messageTopAsk.optionsList[indexPath.row];
    
    UdeskMessage *questionMessage = [[UdeskMessage alloc] initWithText:option.value];
    questionMessage.robotQuestionId = option.valueId;
    questionMessage.robotQuestion = option.value;
    questionMessage.robotQueryType = self.baseMessage.message.isFaq ? @"6" : @"7";
    questionMessage.sendType = UDMessageSendTypeHit;
    questionMessage.robotType = @"1";
    questionMessage.logId = self.baseMessage.message.logId;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendRobotMessage:)]) {
        [self.delegate didSendRobotMessage:questionMessage];
    }
}

@end
