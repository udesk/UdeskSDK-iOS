//
//  UdeskRichMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/16.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskRichMessage.h"
#import "UdeskRichCell.h"

/** 聊天气泡和其中的文字水平间距 */
static CGFloat const kUDBubbleToRichHorizontalSpacing = 15.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDBubbleToRichVerticalSpacing = 10.0;

@interface UdeskRichMessage()

//文本frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect  richTextFrame;
/** 消息的文字 */
@property (nonatomic, copy  , readwrite) NSAttributedString *attributedString;

@end

@implementation UdeskRichMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutRichTextMessage];
    }
    return self;
}

- (void)layoutRichTextMessage {
    
    @try {
        
        if (!self.message.content || [NSNull isEqual:self.message.content]) return;
        if ([UdeskSDKUtil isBlankString:self.message.content]) return;
        
        CGFloat spacing = ud_isIOS11 ? 0 : kUDRichMendSpacingOne;
        
        UIFont *textFont = [self preferredRichTextFont];
        self.attributedString = [self getAttributedStringWithText:self.message.content font:textFont];
        CGSize richSize = [self getAttributedStringSizeWithAttr:self.attributedString size:CGSizeMake([self textMaxWidth], CGFLOAT_MAX)];
        switch (self.message.messageFrom) {
            case UDMessageTypeSending:{
                
                CGFloat bubbleWidth = richSize.width+(kUDBubbleToRichHorizontalSpacing*2);
                CGFloat bubbleX = UD_SCREEN_WIDTH-kUDBubbleToHorizontalEdgeSpacing-bubbleWidth;
                
                //文本气泡frame
                self.bubbleFrame = CGRectMake(bubbleX, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, richSize.width+(kUDBubbleToRichHorizontalSpacing*2), richSize.height+(kUDBubbleToRichHorizontalSpacing*2));
                
                //文本frame
                self.richTextFrame = CGRectMake(kUDBubbleToRichHorizontalSpacing, kUDBubbleToRichVerticalSpacing+spacing, richSize.width, richSize.height);
                //加载中frame
                self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
                
                //加载失败frame
                self.failureFrame = self.loadingFrame;
                
                break;
            }
            case UDMessageTypeReceiving:{
                
                CGFloat bubbleWidth = richSize.width+(kUDBubbleToRichHorizontalSpacing*2);
                CGFloat bubbleHeight = richSize.height+(kUDBubbleToRichVerticalSpacing*2);
                CGFloat richTextY = kUDBubbleToRichVerticalSpacing;
                
                if (self.message.showUseful) {
                    bubbleHeight = bubbleHeight > kUDAnswerBubbleMinHeight ? bubbleHeight : kUDAnswerBubbleMinHeight;
                    bubbleWidth = (310.0/375.0) * UD_SCREEN_WIDTH;
                    richTextY = (bubbleHeight - richSize.height)/2;
                }
                
                //接收文字气泡frame
                self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, bubbleWidth, bubbleHeight);
                //接收文字frame
                self.richTextFrame = CGRectMake(kUDBubbleToRichHorizontalSpacing, richTextY, richSize.width, richSize.height);
                
                break;
            }
                
            default:
                break;
        }
        
        //cell高度
        self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin+self.transferHeight;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (CGFloat)textMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH)-(kUDBubbleToRichHorizontalSpacing*2);
}
- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskRichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (UIFont *)preferredRichTextFont
{
    UIFont *messageFont =[UdeskSDKConfig customConfig].sdkStyle.messageContentFont;
    if (!messageFont) {
        return nil;
    }
    UIFont *preferredFont = messageFont;
    
    BOOL fontFix = ![self isLocaleChineseLanguage];
    static NSString *systemFontFamilyName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIFont *sysFont = [UIFont systemFontOfSize:1];
        systemFontFamilyName = sysFont.familyName;
    });
    
    //非中文环境下默认消息字体强制 苹方
    if (fontFix && systemFontFamilyName && [systemFontFamilyName isEqualToString:messageFont.familyName]) {
        UIFontDescriptor *fontDescriptor = [messageFont fontDescriptor];
        NSMutableDictionary<UIFontDescriptorAttributeName, id>  *atts = [[fontDescriptor fontAttributes] mutableCopy];
        [atts setValue:nil forKey:UIFontDescriptorTextStyleAttribute];
        [atts setValue:@"PingFang SC" forKey:UIFontDescriptorFamilyAttribute];
        [atts setValue:@"PingFangSC-Regular" forKey:UIFontDescriptorNameAttribute];
        UIFontDescriptorSymbolicTraits traits = fontDescriptor.symbolicTraits;
        UIFontDescriptor *preferrDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:atts];
        preferrDescriptor = [preferrDescriptor fontDescriptorWithSymbolicTraits:traits];
        
        preferredFont = [UIFont fontWithDescriptor:preferrDescriptor size:messageFont.pointSize];
    }

    return preferredFont;
}

- (BOOL)isLocaleChineseLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *pfLanguageCode = [languages objectAtIndex:0];
    if ([pfLanguageCode isEqualToString:@"zh-Hant"] ||
        [pfLanguageCode hasPrefix:@"zh-Hant"] ||
        [pfLanguageCode hasPrefix:@"yue-Hant"] ||
        [pfLanguageCode isEqualToString:@"zh-HK"] ||
        [pfLanguageCode isEqualToString:@"zh-TW"]||
        [pfLanguageCode isEqualToString:@"zh-Hans"] ||
        [pfLanguageCode hasPrefix:@"yue-Hans"] ||
        [pfLanguageCode hasPrefix:@"zh-Hans"]
        )
    {
        return YES;
    }
    return NO;
}
 
@end
