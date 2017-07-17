//
//  UdeskTextMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskTextMessage.h"
#import "UdeskTools.h"
#import "UdeskSDKConfig.h"
#import "UdeskStringSizeUtil.h"
#import <CoreText/CoreText.h>
#import "UdeskTextCell.h"

/** 聊天气泡和其中的文字水平间距 */
const CGFloat kUDBubbleToTextHorizontalSpacing = 10.0;
/** 聊天气泡和其中的文字垂直间距 */
const CGFloat kUDBubbleToTextVerticalSpacing = 12.0;

@interface UdeskTextMessage()

//文本frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect  textFrame;
/** 消息的文字属性 */
@property (nonatomic, strong, readwrite) NSDictionary *cellTextAttributes;
/** 消息的文字 */
@property (nonatomic, copy  , readwrite) NSAttributedString *cellText;

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
        if ([UdeskTools isBlankString:self.message.content]) return;
        
        CGSize textSize = CGSizeMake(100, 50);
        
        if (self.message.messageType == UDMessageContentTypeText) {
            [self linkText];
            textSize = [self setAttributedCellText:self.message.content messageFrom:self.message.messageFrom];
            
            switch (self.message.messageFrom) {
                case UDMessageTypeSending:{
                    
                    //文本气泡frame
                    self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDBubbleToTextHorizontalSpacing*2-kUDAvatarToBubbleSpacing-textSize.width, self.avatarFrame.origin.y, textSize.width+(kUDBubbleToTextHorizontalSpacing*3), textSize.height+(kUDBubbleToTextVerticalSpacing*2));
                    //文本frame
                    self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing, kUDBubbleToTextVerticalSpacing, textSize.width, textSize.height);
                    //加载中frame
                    self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
                    
                    //加载失败frame
                    self.failureFrame = self.loadingFrame;
                    
                    break;
                }
                case UDMessageTypeReceiving:{
                    
                    //接收文字气泡frame
                    self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, textSize.width+(kUDBubbleToTextHorizontalSpacing*3), textSize.height+(kUDBubbleToTextVerticalSpacing*2));
                    //接收文字frame
                    self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing+kUDArrowMarginWidth, kUDBubbleToTextVerticalSpacing, textSize.width, textSize.height);
                    
                    break;
                }
                    
                default:
                    break;
            }

            //cell高度
            self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
        }
        else if (self.message.messageType == UDMessageContentTypeRich) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CGSize richTextSize = [self setRichAttributedCellText:self.message.content messageFrom:self.message.messageFrom];
                //接收文字气泡frame
                self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, richTextSize.width+(kUDBubbleToTextHorizontalSpacing*3), richTextSize.height+(kUDBubbleToTextVerticalSpacing*2));
                //接收文字frame
                self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing+kUDArrowMarginWidth, kUDBubbleToTextVerticalSpacing, richTextSize.width, richTextSize.height);
        
                //cell高度
                self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
            });
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
    
}

- (void)linkText {

    @try {
        
        NSMutableDictionary *richURLDictionary = [NSMutableDictionary dictionary];
        NSMutableArray *richContetnArray = [NSMutableArray array];
        
        for (NSString *linkRegex in [UdeskSDKConfig sharedConfig].linkRegexs) {
            
            NSRange range = [self.message.content rangeOfString:linkRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [richURLDictionary setValue:[NSValue valueWithRange:range] forKey:[self.message.content substringWithRange:range]];
                [richContetnArray addObject:[self.message.content substringWithRange:range]];
            }
        }
        
        self.matchArray = [NSArray arrayWithArray:richContetnArray];
        self.richURLDictionary = [NSDictionary dictionaryWithDictionary:richURLDictionary];
        
        NSMutableDictionary *numberDictionary = [NSMutableDictionary dictionary];
        for (NSString *linkRegex in [UdeskSDKConfig sharedConfig].numberRegexs) {
            
            NSRange range = [self.message.content rangeOfString:linkRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [numberDictionary setValue:[NSValue valueWithRange:range] forKey:[self.message.content substringWithRange:range]];
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
        
        if ([UdeskTools isBlankString:text]) {
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
                                NSFontAttributeName : [UdeskSDKConfig sharedConfig].sdkStyle.messageContentFont
                                }];
        if (messageFrom == UDMessageTypeSending) {
            [contentAttributes setObject:(__bridge id)[UdeskSDKConfig sharedConfig].sdkStyle.customerTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        } else {
            [contentAttributes setObject:(__bridge id)[UdeskSDKConfig sharedConfig].sdkStyle.agentTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        }
        
        NSDictionary *cellTextAttributes = [[NSDictionary alloc] initWithDictionary:contentAttributes];
        self.cellText = [[NSAttributedString alloc] initWithString:text attributes:cellTextAttributes];
        
        CGSize textSize = [UdeskStringSizeUtil getSizeForAttributedText:self.cellText textWidth:UD_SCREEN_WIDTH>320?235:180];
        
        if ([UdeskTools stringContainsEmoji:[self.cellText string]]) {
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
        [att addAttribute:NSFontAttributeName value:[UdeskSDKConfig sharedConfig].sdkStyle.messageContentFont range:range];
        // 设置颜色
        if (messageFrom == UDMessageTypeSending) {
            [att addAttribute:NSForegroundColorAttributeName value:[UdeskSDKConfig sharedConfig].sdkStyle.customerTextColor range:range];
        } else {
            [att addAttribute:NSForegroundColorAttributeName value:[UdeskSDKConfig sharedConfig].sdkStyle.agentTextColor range:range];
        }
        //字间距
        [att addAttribute:NSKernAttributeName value:@(2) range:range];
        self.cellText = att;
        
        CGSize textSize = [UdeskStringSizeUtil getSizeForAttributedText:self.cellText textWidth:UD_SCREEN_WIDTH>320?235:180];
        textSize.height += 2;
        
        return textSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
