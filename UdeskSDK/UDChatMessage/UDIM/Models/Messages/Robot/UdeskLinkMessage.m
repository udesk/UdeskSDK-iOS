//
//  UdeskLinkMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskLinkMessage.h"
#import "UdeskLinkCell.h"

/** 聊天气泡和其中的文字水平间距 */
static CGFloat const kUDBubbleToLinkHorizontalSpacing = 14.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDBubbleToLinkVerticalSpacing = 9.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDLinkMendSpacing = 1.0;

@interface UdeskLinkMessage()

//消息的文字
@property (nonatomic, copy  , readwrite) NSAttributedString *attributedString;
//文本frame
@property (nonatomic, assign, readwrite) CGRect textFrame;

@end

@implementation UdeskLinkMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutLinkTextMessage];
    }
    return self;
}

- (void)layoutLinkTextMessage {
        
    if (!self.message.content || [NSNull isEqual:self.message.content]) return;
    if ([UdeskSDKUtil isBlankString:self.message.content]) return;
    
    if (self.message.messageFrom == UDMessageTypeReceiving) {
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self.message.linkTitle];
        [attString addAttribute:NSForegroundColorAttributeName value:[UdeskSDKConfig customConfig].sdkStyle.linkColor range:NSMakeRange(0, self.message.linkTitle.length)];
        [attString addAttribute:NSFontAttributeName value:[UdeskSDKConfig customConfig].sdkStyle.messageContentFont range:NSMakeRange(0, self.message.linkTitle.length)];
        
        NSString *newURL = [self.message.linkIconUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:newURL] options:0 error:&error];
        if (!error) {
            
            UIImage *image = [UIImage imageWithData:data];
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            attch.image = image;
            attch.bounds = CGRectMake(0, -6, 25, 25);
            //创建带有图片的富文本
            NSAttributedString *imgString = [NSAttributedString attributedStringWithAttachment:attch];
            [attString insertAttributedString:imgString atIndex:0];
        }
        
        self.attributedString = attString;
        
        CGSize textSize = [UdeskStringSizeUtil sizeWithAttributedText:attString size:CGSizeMake([self linkMaxWidth], CGFLOAT_MAX)];
        textSize.height = textSize.height <= 40 ? 40 : textSize.height;
        
        CGFloat bubbleWidth = textSize.width+(kUDBubbleToLinkHorizontalSpacing*2);
        CGFloat bubbleHeight = textSize.height+(kUDBubbleToLinkVerticalSpacing*2);
        CGFloat richTextY = kUDBubbleToLinkVerticalSpacing+kUDLinkMendSpacing;
        
        if (self.message.showUseful) {
            bubbleHeight = bubbleHeight > kUDAnswerBubbleMinHeight ? bubbleHeight : kUDAnswerBubbleMinHeight;
            bubbleWidth = (310.0/375.0) * UD_SCREEN_WIDTH;
            richTextY = (bubbleHeight - textSize.height)/2;
        }
        
        //接收文字气泡frame
        self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, bubbleWidth, bubbleHeight);
        //接收文字frame
        self.textFrame = CGRectMake(kUDBubbleToLinkHorizontalSpacing, richTextY, textSize.width, textSize.height);
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin+self.transferHeight;
}

- (CGFloat)linkMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH)-(kUDBubbleToLinkHorizontalSpacing*2);
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskLinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
