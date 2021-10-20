//
//  UdeskBaseMessage.m
//  UdeskSDK
//
//  Created by Udesk on 16/9/1.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"
#import "UdeskDateUtil.h"
#import "NSAttributedString+UdeskHTML.h"

/** 头像距离屏幕水平边沿距离 */
const CGFloat kUDAvatarToHorizontalEdgeSpacing = 12.0;
/** 头像距离屏幕垂直边沿距离 */
const CGFloat kUDAvatarToVerticalEdgeSpacing = 12.0;
/** 头像与聊天气泡之间的距离 */
const CGFloat kUDAvatarToBubbleSpacing = 4.0;
/** 头像与聊天气泡之间的距离 */
const CGFloat kUDNOAvatarToBubbleSpacing = 1;
/** 气泡距离屏幕水平边沿距离 */
const CGFloat kUDBubbleToHorizontalEdgeSpacing = 12.0;
/** 气泡距离屏幕垂直边沿距离 */
const CGFloat kUDBubbleToVerticalEdgeSpacing = 13.0;
/** 聊天气泡和Indicator的间距 */
const CGFloat kUDCellBubbleToIndicatorSpacing = 5.0;
/** 聊天头像大小 */
const CGFloat kUDAvatarDiameter = 24.0;
/** 时间高度 */
const CGFloat kUDChatMessageDateCellHeight = 14.0f;
/** 发送状态大小 */
const CGFloat kUDSendStatusDiameter = 20.0;
/** 发送状态与气泡的距离 */
const CGFloat kUDBubbleToSendStatusSpacing = 10.0;
/** 时间 Y */
const CGFloat kUDChatMessageDateLabelY   = 10.0f;
/** 底部留白 */
const CGFloat kUDCellBottomMargin = 10.0;
/** 底部留白 */
const CGFloat kUDParticularCellBottomMargin = 1;
/** 客服昵称高度 */
const CGFloat kUDAgentNicknameHeight = 16.0;

/** 转人工垂直距离 */
const CGFloat kUDTransferVerticalEdgeSpacing = 16.0;
/** 转人工宽度 */
const CGFloat kUDTransferWidth = 130;
/** 转人工高度 */
const CGFloat kUDTransferHeight = 32.0;

/** 转人工垂直距离 */
const CGFloat kUDUsefulVerticalEdgeSpacing = 8.0;
/** 转人工水平距离 */
const CGFloat kUDUsefulHorizontalEdgeSpacing = 8.0;
/** 转人工宽度 */
const CGFloat kUDUsefulWidth = 32.0;
/** 转人工高度 */
const CGFloat kUDUsefulHeight = 32.0;
/** 有问答评价的消息最小高度 */
const CGFloat kUDAnswerBubbleMinHeight = 75.0;
/** 聊天气泡和其中的文字垂直间距 */
const CGFloat kUDRichMendSpacingOne = 1.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDRichMendSpacingTwo = 5.0;

@interface UdeskBaseMessage()

/** 是否显示时间 */
@property (nonatomic, assign) BOOL       displayTimestamp;
/** date高度 */
@property (nonatomic, assign) CGFloat    dateHeight;
/** 消息发送人昵称 */
@property (nonatomic, copy  ) NSString   *nickName;
/** 聊天气泡图片 */
@property (nonatomic, strong) UIImage    *bubbleImage;
/** 重发图片 */
@property (nonatomic, strong) UIImage    *failureImage;
/** 消息发送人头像 */
@property (nonatomic, copy, readwrite) NSString   *avatarURL;
/** 消息发送人头像 */
@property (nonatomic, strong, readwrite) UIImage  *avatarImage;

@end

@implementation UdeskBaseMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super init];
    if (self) {
        
        _message = message;
        _messageId = message.messageId;
        _displayTimestamp = displayTimestamp;
        
        [self defaultLayout];
    }
    return self;
}

- (void)defaultLayout {
    
    [self layoutDate];
    [self layoutAvatar];
    [self layoutTransfer];
    
    //重发按钮图片
    self.failureImage = [UIImage udDefaultRefreshImage];
    
    _textMaxWidth = (UD_SCREEN_WIDTH>320)?300:200;
    _cellHeight += _dateHeight;
    _cellHeight += kUDCellBottomMargin;
}

//时间
- (void)layoutDate {
    
    _dateHeight = 0;
    NSString *time = [[UdeskDateUtil sharedFormatter] udStyleDateForDate:self.message.timestamp];
    if (time.length == 0) return;
    
    if (_displayTimestamp) {
        
        _dateFrame = CGRectMake(0, kUDChatMessageDateLabelY, UD_SCREEN_WIDTH, kUDChatMessageDateCellHeight);
        _dateHeight = kUDChatMessageDateCellHeight;
    }
}

//转人工
- (void)layoutTransfer {
    
    if ([self.message.switchStaffType isEqualToString:@"1"]) {
        _transferHeight = kUDTransferHeight + kUDTransferVerticalEdgeSpacing;
    }
}

//头像
- (void)layoutAvatar {
    
    //布局
    BOOL showAvatar = [self checkAvatarDisplayWithBubbleType:self.message.bubbleType];
    //文本消息的头像需要根据气泡的规则选择显示
    if (self.message.messageType == UDMessageContentTypeText && !showAvatar) {
        return;
    }
    
    switch (self.message.messageFrom) {
        case UDMessageTypeReceiving:
            
            //用户头像frame
            self.avatarFrame = CGRectMake(kUDAvatarToHorizontalEdgeSpacing, CGRectGetMaxY(self.dateFrame)+kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
            if (![UdeskSDKUtil isBlankString:self.message.nickName]) {
                self.nicknameFrame = CGRectMake(CGRectGetMaxX(self.avatarFrame)+kUDAvatarToBubbleSpacing, CGRectGetMinY(self.avatarFrame)+(kUDAvatarDiameter-kUDAgentNicknameHeight)/2, UD_SCREEN_WIDTH>320?235:180, kUDAgentNicknameHeight);
            }
            self.avatarImage = [UIImage udDefaultAgentImage];
            self.avatarURL = self.message.avatar;
            break;
        case UDMessageTypeSending:
            
            //用户头像frame
            self.avatarFrame = CGRectMake(UD_SCREEN_WIDTH-kUDAvatarToHorizontalEdgeSpacing-kUDAvatarDiameter, CGRectGetMaxY(self.dateFrame)+kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
            if (![UdeskSDKUtil isBlankString:[UdeskSDKConfig customConfig].sdkStyle.customerNickname]) {
                CGFloat nicknameWidth = UD_SCREEN_WIDTH>320?235:180;
                self.nicknameFrame = CGRectMake(CGRectGetMinX(self.avatarFrame)-kUDAvatarToBubbleSpacing-nicknameWidth, CGRectGetMinY(self.avatarFrame)+(kUDAvatarDiameter-kUDAgentNicknameHeight)/2, nicknameWidth, kUDAgentNicknameHeight);
            }
            self.avatarImage = [UdeskSDKConfig customConfig].sdkStyle.customerAvatarImage;
            self.avatarURL = [UdeskSDKConfig customConfig].sdkStyle.customerAvatarURL;
            break;
            
        default:
            break;
    }
}

- (BOOL)checkAvatarDisplayWithBubbleType:(NSString *)bubbleType {
    
    if (!bubbleType) {
        return YES;
    }
    
    if ([bubbleType isEqualToString:@"udChatBubbleSendingSolid02.png"] ||
        [bubbleType isEqualToString:@"udChatBubbleReceivingSolid02.png"]) {
        return YES;
    }
    
    return NO;
}

- (NSAttributedString *)getAttributedStringWithText:(NSString *)text font:(UIFont *)font {
    
    if ([UdeskSDKUtil isBlankString:text]) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    
    NSAttributedString *attributedString = [NSAttributedString attributedStringFromHTML:text customFont:font];
    
    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    contentParagraphStyle.lineSpacing = 6.0f;
    contentParagraphStyle.lineHeightMultiple = 1.0f;
    contentParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    contentParagraphStyle.alignment = NSTextAlignmentLeft;
    
    NSMutableAttributedString *mAtt = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    [mAtt addAttribute:NSParagraphStyleAttributeName value:contentParagraphStyle range:NSMakeRange(0, attributedString.length)];
    
    //富文本末尾会有\n，为了不影响正常显示 这里前端过滤掉
    if (attributedString.length) {
        NSAttributedString *last = [mAtt attributedSubstringFromRange:NSMakeRange(mAtt.length - 1, 1)];
        if ([[last string] isEqualToString:@"\n"]) {
            [mAtt replaceCharactersInRange:NSMakeRange(mAtt.length - 1, 1) withString:@""];
        }
    }
    
    return mAtt;
}

- (CGSize)getAttributedStringSizeWithAttr:(NSAttributedString *)attributedString size:(CGSize)size {
 
    CGSize textSize = [UdeskStringSizeUtil sizeWithAttributedText:attributedString size:size];
    
    if ([UdeskSDKUtil stringContainsEmoji:[attributedString string]]) {
        textSize.width += kUDRichMendSpacingTwo;
    }
    
    __block CGFloat space = 0;
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        
        if (value && [value isKindOfClass:[NSTextAttachment class]]){
            space = kUDRichMendSpacingTwo * 2;
        }
    }];
    
    textSize.height = ceil(textSize.height+space) + kUDRichMendSpacingOne;
    
    return textSize;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {

    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
