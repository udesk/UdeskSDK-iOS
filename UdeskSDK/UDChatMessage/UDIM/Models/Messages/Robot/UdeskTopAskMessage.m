//
//  UdeskTopAskMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskTopAskMessage.h"
#import "UdeskTopAskCell.h"
#import "NSAttributedString+UdeskHTML.h"

/** 聊天气泡和其中的文字水平间距 */
const CGFloat kUDBubbleToTopAskHorizontalSpacing = 14.0;
/** 聊天气泡和其中的文字垂直间距 */
const CGFloat kUDBubbleToTopAskVerticalSpacing = 10.0;
/** 聊天气泡和其中的文字垂直间距 */
const CGFloat kUDCellToTopAskQuestionVerticalSpacing = 5.0;
/** 聊天气泡和其中的文字水平间距 */
const CGFloat kUDCellToTopAskQuestionTagHorizontalSpacing = 12.0;
/** 聊天气泡和其中的文字垂直间距 */
const CGFloat kUDCellToTopAskQuestionTagVerticalSpacing = 12.0;
/** 项目列表标签Width */
const CGFloat kUDTopAskOptionTagWidth = 6;
/** 项目列表标签Height */
const CGFloat kUDTopAskOptionTagHeight = 6;
/** 问题文字水平间距 */
const CGFloat kUDOptionToTagHorizontalSpacing = 8.0;

@interface UdeskTopAskMessage()

@property (nonatomic, copy  , readwrite) NSAttributedString *leadingAttributedString;
@property (nonatomic, assign, readwrite) CGRect leadingWordFrame;
@property (nonatomic, assign, readwrite) CGRect lineFrame;
@property (nonatomic, assign, readwrite) CGRect topAskFrame;
@property (nonatomic, strong, readwrite) NSArray *topAskTitleHeightArray;
@property (nonatomic, strong, readwrite) NSArray *questionHeightArray;

@end

@implementation UdeskTopAskMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutTopAskMessage];
    }
    return self;
}

- (void)layoutTopAskMessage {
    
    if (!self.message.topAsk || self.message.topAsk == (id)kCFNull) return ;
    
    if (self.message.messageType == UDMessageContentTypeTopAsk && self.message.messageFrom == UDMessageTypeReceiving) {
        
        self.leadingAttributedString = [NSAttributedString attributedStringFromHTML:self.message.answerTitle customFont:[UIFont systemFontOfSize:15]];
        
        CGSize leadingWordSize = [UdeskStringSizeUtil getSizeForAttributedText:self.leadingAttributedString textWidth:[self topAskMaxWidth]-(kUDBubbleToTopAskHorizontalSpacing*2)];
        //引导文字frame
        self.leadingWordFrame = CGRectMake(kUDBubbleToTopAskHorizontalSpacing, kUDBubbleToTopAskVerticalSpacing, leadingWordSize.width, leadingWordSize.height);
        
        CGFloat topAskHeight = 0;
        NSMutableArray *topAskHeightArray = [NSMutableArray array];
        NSMutableArray *questionHeightArray = [NSMutableArray array];
        
        for (UdeskMessageTopAsk *topAskMessage in self.message.topAsk) {
            
            if (self.message.topAsk.count > 1) {
                NSAttributedString *topAskAttributed = [NSAttributedString attributedStringFromHTML:topAskMessage.questionType customFont:[UIFont systemFontOfSize:15]];
                CGFloat width = [self topAskMaxWidth] - kUDBubbleToTopAskHorizontalSpacing*2;
                CGSize topAskSize = [UdeskStringSizeUtil getSizeForAttributedText:topAskAttributed textWidth:width];
                [topAskHeightArray addObject:@(topAskSize.height+5)];
                topAskHeight += topAskSize.height+5;
            }
            
            //展开
            if (topAskMessage.isUnfold || self.message.topAsk.count == 1) {
                
                for (UdeskMessageOption *option in topAskMessage.optionsList) {
                    NSAttributedString *optionsAttributed = [NSAttributedString attributedStringFromHTML:option.value customFont:[UIFont systemFontOfSize:15]];
                    CGFloat optionMaxWidth = [self topAskMaxWidth] - kUDBubbleToTopAskHorizontalSpacing*3 - kUDTopAskOptionTagWidth;
                    CGSize optionsSize = [UdeskStringSizeUtil getSizeForAttributedText:optionsAttributed textWidth:optionMaxWidth];
                    topAskHeight = topAskHeight+optionsSize.height;
                    [questionHeightArray addObject:@(optionsSize.height)];
                }
            }
        }
        
        self.topAskTitleHeightArray = [topAskHeightArray copy];
        self.questionHeightArray = [questionHeightArray copy];
        
        self.lineFrame = CGRectMake(0, CGRectGetMaxY(self.leadingWordFrame), [self topAskMaxWidth], 1);
        
        CGFloat topAskSpacing = self.message.topAsk.count > 1 ? 0 : kUDBubbleToTopAskVerticalSpacing*0.5;
        self.topAskFrame = CGRectMake(3, CGRectGetMaxY(self.lineFrame)+topAskSpacing, [self topAskMaxWidth]-6, topAskHeight);
        self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, [self topAskMaxWidth], CGRectGetMaxY(self.topAskFrame)+kUDBubbleToTopAskVerticalSpacing);
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin+self.transferHeight;
}

- (CGFloat)topAskMaxWidth {
    return (310.0/375.0) * UD_SCREEN_WIDTH;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskTopAskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
