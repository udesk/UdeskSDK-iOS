//
//  UdeskTextMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskTextMessage.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKConfig.h"
#import "UdeskStringSizeUtil.h"
#import <CoreText/CoreText.h>
#import "UdeskTextCell.h"
#import "UdeskBundleUtils.h"
#import "UDTTTAttributedLabel.h"

/** 聊天气泡和其中的文字水平间距 */
const CGFloat kUDBubbleToTextHorizontalSpacing = 10.0;
/** 聊天气泡和其中的文字垂直间距 */
const CGFloat kUDBubbleToTextVerticalSpacing = 10.0;
/** 聊天气泡和其中的文字垂直间距 */
const CGFloat kUDTextMendSpacing = 2.0;

@interface UdeskTextMessage()

//文本frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect  textFrame;
/** 消息的文字属性 */
@property (nonatomic, strong, readwrite) NSDictionary *cellTextAttributes;
/** 消息的文字 */
@property (nonatomic, copy  , readwrite) NSAttributedString *cellText;

@property (nonatomic, strong) UDTTTAttributedLabel *textLabelForHeightCalculation;

@end

@implementation UdeskTextMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutTextMessage];
    }
    return self;
}

- (void)layoutTextMessage {

    @try {
        
        if (!self.message.content || [NSNull isEqual:self.message.content]) return;
        if ([UdeskSDKUtil isBlankString:self.message.content]) return;
        
        CGSize textSize = CGSizeMake(100, 50);
        CGFloat spacing = ud_isIOS11 ? 0 : kUDTextMendSpacing;
        if (ud_isIOS13) {
            spacing = kUDTextMendSpacing;
        }
        
        if (self.message.messageType == UDMessageContentTypeText ||
            self.message.messageType == UDMessageContentTypeLeaveMsg) {
            
            textSize = [self setAttributedCellText:self.message.content messageFrom:self.message.messageFrom];
            switch (self.message.messageFrom) {
                case UDMessageTypeSending:{
                    
                    [self setSendFrameWithSize:textSize spacing:spacing];
                    break;
                }
                case UDMessageTypeReceiving:{
                    
                    [self setReceiveFrameWithSize:textSize spacing:spacing];
                    break;
                }
                default:
                    break;
            }
        }
        else if (self.message.messageType == UDMessageContentTypeRich) {
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupRichText];
                });
            }
            else {
                [self setupRichText];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.textLabelForHeightCalculation.attributedText = self.cellText;
            CGSize labelSize = [self.textLabelForHeightCalculation sizeThatFits:CGSizeMake(UD_SCREEN_WIDTH>320?235:180, MAXFLOAT)];
            
            if (CGRectGetHeight(self.textFrame) < labelSize.height) {
                if (self.message.messageFrom == UDMessageTypeSending) {
                    [self setSendFrameWithSize:labelSize spacing:spacing];
                }
                else if (self.message.messageFrom == UDMessageTypeReceiving) {
                    [self setReceiveFrameWithSize:labelSize spacing:spacing];
                }
            }
        });
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)setReceiveFrameWithSize:(CGSize)textSize spacing:(CGFloat)spacing {
    
    //接收文字气泡frame
    CGFloat bubbleY = [UdeskSDKUtil isBlankString:self.message.nickName] ? CGRectGetMinY(self.avatarFrame) : CGRectGetMaxY(self.nicknameFrame)+kUDCellBubbleToIndicatorSpacing;
    self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, bubbleY, textSize.width+(kUDBubbleToTextHorizontalSpacing*3), textSize.height+(kUDBubbleToTextVerticalSpacing*2));
    self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing+kUDArrowMarginWidth, kUDBubbleToTextVerticalSpacing+spacing, textSize.width, textSize.height);
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (void)setSendFrameWithSize:(CGSize)textSize spacing:(CGFloat)spacing {
    
    //文本气泡frame
    self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDBubbleToTextHorizontalSpacing*2-kUDAvatarToBubbleSpacing-textSize.width, self.avatarFrame.origin.y, textSize.width+(kUDBubbleToTextHorizontalSpacing*3), textSize.height+(kUDBubbleToTextVerticalSpacing*2));
    //文本frame
    self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing, kUDBubbleToTextVerticalSpacing+spacing, textSize.width, textSize.height);
    //加载中frame
    self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
    //加载失败frame
    self.failureFrame = self.loadingFrame;
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (void)setupRichText {
    
    CGSize richTextSize = [self setRichAttributedCellText:self.message.content messageFrom:self.message.messageFrom];
    //接收文字气泡frame
    CGFloat bubbleY = [UdeskSDKUtil isBlankString:self.message.nickName] ? CGRectGetMinY(self.avatarFrame) : CGRectGetMaxY(self.nicknameFrame)+kUDCellBubbleToIndicatorSpacing;
    self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, bubbleY, richTextSize.width+(kUDBubbleToTextHorizontalSpacing*3), richTextSize.height+(kUDBubbleToTextVerticalSpacing*2));
    //接收文字frame
    CGFloat spacing = ud_isIOS13 ? kUDTextMendSpacing : 0;
    self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing+kUDArrowMarginWidth, kUDBubbleToTextVerticalSpacing+spacing, richTextSize.width, richTextSize.height);
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (void)linkText:(NSString *)content {

    @try {
        
        NSMutableDictionary *richURLDictionary = [NSMutableDictionary dictionary];
        NSMutableArray *richContetnArray = [NSMutableArray array];
        
        for (NSString *linkRegex in [UdeskSDKUtil linkRegexs]) {
            
            NSRange range = [content rangeOfString:linkRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                NSValue *value = [NSValue valueWithRange:range];
                NSString *key = [content substringWithRange:range];
                if (value && key) {
                    [richURLDictionary setValue:value forKey:key];
                    [richContetnArray addObject:key];
                }
            }
        }
        
        self.matchArray = [NSArray arrayWithArray:richContetnArray];
        self.richURLDictionary = [NSDictionary dictionaryWithDictionary:richURLDictionary];
        
        NSMutableDictionary *numberDictionary = [NSMutableDictionary dictionary];
        for (NSString *linkRegex in [UdeskSDKUtil numberRegexs]) {
            
            NSRange range = [content rangeOfString:linkRegex options:NSNumericSearch|NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                NSValue *value = [NSValue valueWithRange:range];
                NSString *key = [content substringWithRange:range];
                if (value && key) {
                    [numberDictionary setValue:value forKey:key];
                }
            }
        }
        self.numberRangeDic = [NSDictionary dictionaryWithDictionary:numberDictionary];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (CGSize)setAttributedCellText:(NSString *)text messageFrom:(UDMessageFromType)messageFrom {
    
    @try {
        
        if ([UdeskSDKUtil isBlankString:text]) {
            return CGSizeMake(50, 50);
        }
        
        NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        contentParagraphStyle.lineSpacing = 6.0f;
        contentParagraphStyle.lineHeightMultiple = 1.0f;
        contentParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        contentParagraphStyle.alignment = NSTextAlignmentLeft;
        NSMutableDictionary *contentAttributes
        = [[NSMutableDictionary alloc]
           initWithDictionary:@{
                                NSParagraphStyleAttributeName : contentParagraphStyle,
                                NSFontAttributeName : [UdeskSDKConfig customConfig].sdkStyle.messageContentFont
                                }];
        if (messageFrom == UDMessageTypeSending) {
            [contentAttributes setObject:(__bridge id)[UdeskSDKConfig customConfig].sdkStyle.customerTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        } else {
            [contentAttributes setObject:(__bridge id)[UdeskSDKConfig customConfig].sdkStyle.agentTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        }
        
        NSDictionary *cellTextAttributes = [[NSDictionary alloc] initWithDictionary:contentAttributes];
        self.cellText = [[NSAttributedString alloc] initWithString:text attributes:cellTextAttributes];
        
        CGSize textSize = [UdeskStringSizeUtil getSizeForAttributedText:self.cellText textWidth:UD_SCREEN_WIDTH>320?235:180];
        
        if ([UdeskSDKUtil stringContainsEmoji:[self.cellText string]]) {
            NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:cellTextAttributes];
            CGFloat oneLineTextHeight = [UdeskStringSizeUtil getHeightForAttributedText:oneLineText textWidth:UD_SCREEN_WIDTH>320?235:180];
            NSInteger textLines = ceil(textSize.height / oneLineTextHeight);
            textSize.height += 8 * textLines;
        }
        
        textSize.height += 2;
        return textSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
    
}

- (CGSize)setRichAttributedCellText:(NSString *)text messageFrom:(UDMessageFromType)messageFrom {
    
    @try {
        
        NSDictionary *dic = @{
                              NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                              NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)
                              };
        
        self.cellText = [[NSMutableAttributedString alloc] initWithData:[text dataUsingEncoding:NSUTF8StringEncoding] options:dic documentAttributes:nil error:nil];
        
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithAttributedString:self.cellText];
        NSRange range = NSMakeRange(0, self.cellText.string.length);
        // 设置字体大小
        [att addAttribute:NSFontAttributeName value:[UdeskSDKConfig customConfig].sdkStyle.messageContentFont range:range];
        // 设置颜色
        if (messageFrom == UDMessageTypeSending) {
            [att addAttribute:NSForegroundColorAttributeName value:[UdeskSDKConfig customConfig].sdkStyle.customerTextColor range:range];
        } else {
            [att addAttribute:NSForegroundColorAttributeName value:[UdeskSDKConfig customConfig].sdkStyle.agentTextColor range:range];
        }

        NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        contentParagraphStyle.lineSpacing = 6.0f;
        contentParagraphStyle.lineHeightMultiple = 1.0f;
        contentParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        contentParagraphStyle.alignment = NSTextAlignmentLeft;
        
        //富文本末尾会有\n，为了不影响正常显示 这里前端过滤掉
        if (att.length) {
            NSAttributedString *last = [att attributedSubstringFromRange:NSMakeRange(att.length - 1, 1)];
            if ([[last string] isEqualToString:@"\n"]) {
                [att replaceCharactersInRange:NSMakeRange(att.length - 1, 1) withString:@""];
            }
        }
        
        self.cellText = att;
        
        CGSize textSize = [UdeskStringSizeUtil getSizeForAttributedText:self.cellText textWidth:UD_SCREEN_WIDTH>320?235:180];
        textSize.height += 2;
        
        return textSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (UDTTTAttributedLabel *)textLabelForHeightCalculation {
    if (!_textLabelForHeightCalculation) {
        _textLabelForHeightCalculation = [UDTTTAttributedLabel new];
        _textLabelForHeightCalculation.numberOfLines = 0;
    }
    return _textLabelForHeightCalculation;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
