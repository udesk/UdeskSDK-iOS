//
//  UdeskTextMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskTextMessage.h"
#import "UdeskTextCell.h"
#import "UDTTTAttributedLabel.h"

/** 聊天气泡和其中的文字水平间距 */
static CGFloat const kUDBubbleToTextHorizontalSpacing = 15.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDBubbleToTextVerticalSpacing = 9.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDTextMendSpacing = 1.0;

@interface UdeskTextMessage()

//文本frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect  textFrame;
/** 消息的文字属性 */
@property (nonatomic, strong, readwrite) NSDictionary *cellTextAttributes;
/** 消息的文字 */
@property (nonatomic, copy  , readwrite) NSAttributedString *cellText;
/** 计算高度用的label */
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
        
        CGFloat spacing = ud_isIOS13 ? (kUDTextMendSpacing*2) : kUDTextMendSpacing;
        CGSize textSize = [self setAttributedCellText:self.message.content messageFrom:self.message.messageFrom];
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

        dispatch_async(dispatch_get_main_queue(), ^{

            self.textLabelForHeightCalculation.attributedText = self.cellText;
            CGSize labelSize = [self.textLabelForHeightCalculation sizeThatFits:CGSizeMake(self.textMaxWidth, MAXFLOAT)];

//            if (CGRectGetHeight(self.textFrame) < labelSize.height) {
                if (self.message.messageFrom == UDMessageTypeSending) {
                    [self setSendFrameWithSize:labelSize spacing:spacing];
                }
                else if (self.message.messageFrom == UDMessageTypeReceiving) {
                    [self setReceiveFrameWithSize:labelSize spacing:spacing];
                }
//            }
        });
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)setReceiveFrameWithSize:(CGSize)textSize spacing:(CGFloat)spacing {
    
    CGFloat bubbleSpacing = [self getBubbleSpacing];
    //接收文字气泡frame
    self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+bubbleSpacing, textSize.width+(kUDBubbleToTextHorizontalSpacing*2), textSize.height+(kUDBubbleToTextVerticalSpacing*2));
    //接收文字frame
    self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing, kUDBubbleToTextVerticalSpacing+spacing, textSize.width, textSize.height);
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+(!self.message.bubbleType ? kUDCellBottomMargin : kUDParticularCellBottomMargin);
}

- (void)setSendFrameWithSize:(CGSize)textSize spacing:(CGFloat)spacing {
    CGFloat bubbleWidth = textSize.width+(kUDBubbleToTextHorizontalSpacing*2);
    CGFloat bubbleHeight = textSize.height+(kUDBubbleToTextVerticalSpacing*2);
    CGFloat bubbleX = UD_SCREEN_WIDTH-kUDBubbleToHorizontalEdgeSpacing-bubbleWidth;
    CGFloat bubbleSpacing = [self getBubbleSpacing];
    
    //文本气泡frame
    self.bubbleFrame = CGRectMake(bubbleX, CGRectGetMaxY(self.avatarFrame)+bubbleSpacing, bubbleWidth, bubbleHeight);
    //文本frame
    self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing, kUDBubbleToTextVerticalSpacing+spacing, textSize.width, textSize.height);
    //加载中frame
    self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
    //加载失败frame
    self.failureFrame = self.loadingFrame;
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+(!self.message.bubbleType ? kUDCellBottomMargin : kUDParticularCellBottomMargin);
}

- (CGFloat)getBubbleSpacing {
    
    CGFloat bubbleSpacing = kUDAvatarToBubbleSpacing;
    
    if (self.message.bubbleType &&
        ([self.message.bubbleType rangeOfString:@"Solid04"].location != NSNotFound ||
         [self.message.bubbleType rangeOfString:@"Solid03"].location != NSNotFound)) {
            bubbleSpacing = kUDNOAvatarToBubbleSpacing;
        }
    
    return bubbleSpacing;
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
            return CGSizeMake(100, 20);
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
            [contentAttributes setObject:[UdeskSDKConfig customConfig].sdkStyle.customerTextColor forKey:NSForegroundColorAttributeName];
        } else {
            [contentAttributes setObject:[UdeskSDKConfig customConfig].sdkStyle.agentTextColor forKey:NSForegroundColorAttributeName];
        }
        
        NSDictionary *cellTextAttributes = [[NSDictionary alloc] initWithDictionary:contentAttributes];
        self.cellText = [[NSAttributedString alloc] initWithString:text attributes:cellTextAttributes];
        
        CGSize textSize = [UdeskStringSizeUtil sizeWithAttributedText:self.cellText size:CGSizeMake(self.textMaxWidth, CGFLOAT_MAX)];
        
        if ([UdeskSDKUtil stringContainsEmoji:[self.cellText string]]) {
            NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:cellTextAttributes];
            CGFloat oneLineTextHeight = [UdeskStringSizeUtil sizeWithAttributedText:oneLineText size:CGSizeMake([self textMaxWidth], CGFLOAT_MAX)].height;
            NSInteger textLines = ceil(textSize.height / oneLineTextHeight);
            textSize.height += 8 * textLines;
        }
        
        return textSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
    
}

- (UDTTTAttributedLabel *)textLabelForHeightCalculation {
    if (!_textLabelForHeightCalculation) {
        _textLabelForHeightCalculation = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _textLabelForHeightCalculation.numberOfLines = 0;
    }
    return _textLabelForHeightCalculation;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
