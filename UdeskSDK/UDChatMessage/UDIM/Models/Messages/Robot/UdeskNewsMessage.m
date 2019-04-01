//
//  UdeskNewsMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskNewsMessage.h"
#import "UdeskNewsCell.h"
#import "NSAttributedString+UdeskHTML.h"

/** 图文消息图片宽度 */
static CGFloat const kUDNewsImageWidth = 77.0;
/** 图文消息图片高度 */
static CGFloat const kUDNewsImageHeight = 77.0;
/** 标题最大高度 */
static CGFloat const kUDNewsTitleMaxHeight = 40.0;
/** 标题最大高度 */
static CGFloat const kUDNewsDescMaxHeight = 35.0;

/** 聊天气泡和其中的文字水平间距 */
const CGFloat kUDBubbleToNewsHorizontalSpacing = 12.0;
/** 聊天气泡和其中的文字垂直间距 */
const CGFloat kUDBubbleToNewsVerticalSpacing = 10.0;
/** 项目列表标签Width */
const CGFloat kUDNewsTopAskQuestionVerticalSpacing = 3.0;
/** 项目列表标签Width */
const CGFloat kUDNewsOptionTagWidth = 6;
/** 项目列表标签Height */
const CGFloat kUDNewsOptionTagHeight = 6;
/** 问题文字水平间距 */
const CGFloat kUDNewsOptionToTagHorizontalSpacing = 8.0;

@interface UdeskNewsMessage()

/** 标题Frame */
@property (nonatomic, assign, readwrite) CGRect titleFrame;
/** 描述Frame */
@property (nonatomic, assign, readwrite) CGRect descFrame;
/** 图片Frame */
@property (nonatomic, assign, readwrite) CGRect imgFrame;

@property (nonatomic, assign, readwrite) CGRect lineFrame;
@property (nonatomic, assign, readwrite) CGRect topAskFrame;
@property (nonatomic, strong, readwrite) NSArray *topAskTitleHeightArray;
@property (nonatomic, strong, readwrite) NSArray *questionHeightArray;

//标题的文字
@property (nonatomic, copy  , readwrite) NSAttributedString *titleAttributedString;
//描述的文字
@property (nonatomic, copy  , readwrite) NSAttributedString *descAttributedString;
//描述的文字
@property (nonatomic, copy  , readwrite) NSString *imgURL;
//描述的文字
@property (nonatomic, copy  , readwrite) NSString *answerURL;


@end

@implementation UdeskNewsMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        [self layoutNewsMessage];
    }
    return self;
}

- (void)layoutNewsMessage {
    
    if (self.message.messageFrom == UDMessageTypeReceiving) {
        
        self.imgURL = self.message.newsCoverUrl;
        self.titleAttributedString = [NSAttributedString attributedStringFromHTML:self.message.newsContent customFont:[UIFont systemFontOfSize:16]];
        CGSize titleSize = [UdeskStringSizeUtil getSizeForAttributedText:self.titleAttributedString width:[self textMaxWidth] height:kUDNewsTitleMaxHeight];
        
        self.descAttributedString = [NSAttributedString attributedStringFromHTML:self.message.newsDescription customFont:[UIFont systemFontOfSize:12]];
        
        self.titleFrame = CGRectMake(kUDBubbleToNewsHorizontalSpacing, kUDBubbleToNewsVerticalSpacing, [self textMaxWidth], titleSize.height);
        self.descFrame = CGRectMake(kUDBubbleToNewsHorizontalSpacing, CGRectGetMaxY(self.titleFrame), [self textMaxWidth], kUDNewsDescMaxHeight);
        self.imgFrame = CGRectMake([self newsMaxWidth]-kUDBubbleToNewsHorizontalSpacing-kUDNewsImageWidth, kUDBubbleToNewsVerticalSpacing, kUDNewsImageWidth, kUDNewsImageHeight);
        
        //有推荐问题
        CGFloat maxY = CGRectGetMaxY(self.imgFrame);
        if (self.message.topAsk && self.message.topAsk.count && [self.message.topAsk.firstObject isKindOfClass:[UdeskMessageTopAsk class]]) {
            
            CGFloat topAskHeight = 0;
            NSMutableArray *topAskHeightArray = [NSMutableArray array];
            NSMutableArray *questionHeightArray = [NSMutableArray array];
            
            UdeskMessageTopAsk *topAskMessage = self.message.topAsk.firstObject;
                    
            for (UdeskMessageOption *option in topAskMessage.optionsList) {
                NSAttributedString *optionsAttributed = [NSAttributedString attributedStringFromHTML:option.value customFont:[UIFont systemFontOfSize:15]];
                CGFloat optionMaxWidth = [self newsMaxWidth] - kUDBubbleToNewsHorizontalSpacing*3 - kUDNewsOptionTagWidth;
                CGSize optionsSize = [UdeskStringSizeUtil getSizeForAttributedText:optionsAttributed textWidth:optionMaxWidth];
                topAskHeight = topAskHeight+optionsSize.height;
                [questionHeightArray addObject:@(optionsSize.height)];
            }
            
            self.topAskTitleHeightArray = [topAskHeightArray copy];
            self.questionHeightArray = [questionHeightArray copy];
            
            CGFloat linY = CGRectGetMaxY(self.imgFrame) > CGRectGetMaxY(self.descFrame) ? CGRectGetMaxY(self.imgFrame) : CGRectGetMaxY(self.descFrame);
            self.lineFrame = CGRectMake(0, linY+kUDNewsTopAskQuestionVerticalSpacing, [self newsMaxWidth], 1);
            
            CGFloat topAskSpacing = self.message.topAsk.count > 1 ? 0 : kUDBubbleToNewsVerticalSpacing*0.5;
            self.topAskFrame = CGRectMake(3, CGRectGetMaxY(self.lineFrame)+topAskSpacing, [self newsMaxWidth]-6, topAskHeight);
            maxY = CGRectGetMaxY(self.topAskFrame);
        }
        
        self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, [self newsMaxWidth], maxY+kUDBubbleToNewsVerticalSpacing);
        
        //cell高度
        self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin+self.transferHeight;
    }
}

- (CGFloat)newsMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH);
}

- (CGFloat)textMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH)-(kUDBubbleToNewsHorizontalSpacing*3)-kUDNewsImageWidth;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
