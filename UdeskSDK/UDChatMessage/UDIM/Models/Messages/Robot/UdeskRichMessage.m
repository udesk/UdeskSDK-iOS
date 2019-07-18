//
//  UdeskRichMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/16.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskRichMessage.h"
#import "UdeskRichCell.h"
#import "NSAttributedString+UdeskHTML.h"

/** 聊天气泡和其中的文字水平间距 */
static CGFloat const kUDBubbleToRichHorizontalSpacing = 14.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDBubbleToRichVerticalSpacing = 9.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDBubbleToRichVerticalMinSpacing = 6.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDRichMendSpacingOne = 1.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDRichMendSpacingTwo = 5.0;

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
        
        CGSize richSize = [self setRichAttributedCellText:self.message.content];
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
                CGFloat richTextY = ud_isIOS13 ? (kUDBubbleToRichVerticalMinSpacing+kUDRichMendSpacingOne) : kUDBubbleToRichVerticalMinSpacing;
                
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

- (CGSize)setRichAttributedCellText:(NSString *)text {
    
    @try {
        
        if ([UdeskSDKUtil isBlankString:text]) {
            return CGSizeMake(100, 20);
        }
        
        NSAttributedString *attributedString = [NSAttributedString attributedStringFromHTML:text customFont:[UdeskSDKConfig customConfig].sdkStyle.messageContentFont];
        
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
        
        self.attributedString = mAtt;
        
        CGSize textSize = [UdeskStringSizeUtil sizeWithAttributedText:mAtt size:CGSizeMake([self richMaxWidth], CGFLOAT_MAX)];
        
        if ([UdeskSDKUtil stringContainsEmoji:[mAtt string]]) {
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
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (CGFloat)richMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH)-(kUDBubbleToRichHorizontalSpacing*2);
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskRichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
