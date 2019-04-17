//
//  UdeskProductMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskProductMessage.h"
#import "UdeskProductCell.h"
#import "NSAttributedString+UdeskHTML.h"
#import "UIColor+UdeskSDK.h"

/** 水平间距 */
static CGFloat const kUDBubbleToProductHorizontalSpacing = 14.0;
/** 垂直间距 */
static CGFloat const kUDBubbleToProductVerticalSpacing = 14.0;
/** 垂直间距 */
static CGFloat const kUDInfoToInfoVerticalSpacing = 6.0;
/** 垂直间距 */
static CGFloat const kUDInfoToInfoHeight = 20.0;
/** 图片宽度 */
static CGFloat const kUDProductImageWidth = 60.0;
/** 图片高度 */
static CGFloat const kUDProductImageHeight = 60.0;
/** 标题最大高度 */
static CGFloat const kUDProductTitleMaxHeight = 40.0;

@interface UdeskProductMessage()

@property (nonatomic, assign, readwrite) CGRect titleFrame;
@property (nonatomic, assign, readwrite) CGRect imageFrame;
@property (nonatomic, assign, readwrite) CGRect firstInfoFrame;
@property (nonatomic, assign, readwrite) CGRect secondInfoFrame;
@property (nonatomic, assign, readwrite) CGRect thirdInfoFrame;

@property (nonatomic, copy  , readwrite) NSURL *imgURL;
@property (nonatomic, copy  , readwrite) NSAttributedString *titleAttributedString;
@property (nonatomic, copy  , readwrite) NSAttributedString *firstAttributedString;
@property (nonatomic, copy  , readwrite) NSAttributedString *secondAttributedString;
@property (nonatomic, copy  , readwrite) NSAttributedString *thirdAttributedString;

@end

@implementation UdeskProductMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutProductMessage];
    }
    return self;
}

- (void)layoutProductMessage {
    
    if (!self.message.replyProduct || self.message.replyProduct == (id)kCFNull) return ;
    
    if (self.message.messageFrom == UDMessageTypeSending) {
        
        self.imgURL = [NSURL URLWithString:self.message.replyProduct.imageURL];
        self.imageFrame = CGRectMake(kUDBubbleToProductHorizontalSpacing, kUDBubbleToProductVerticalSpacing, kUDProductImageWidth, kUDProductImageHeight);
        
        CGFloat textMaxWidth = [self productMaxWidth]-kUDBubbleToProductHorizontalSpacing-kUDProductImageWidth;
        
        self.titleAttributedString = [NSAttributedString attributedStringFromHTML:self.message.replyProduct.name customFont:[UIFont systemFontOfSize:15]];
        CGSize titleSize = [UdeskStringSizeUtil sizeWithAttributedText:self.titleAttributedString size:CGSizeMake(textMaxWidth, kUDProductTitleMaxHeight)];
        self.titleFrame = CGRectMake(CGRectGetMaxX(self.imageFrame)+kUDBubbleToProductHorizontalSpacing, kUDBubbleToProductVerticalSpacing, textMaxWidth, titleSize.height);
        
        CGFloat bubbleMaxY = CGRectGetMaxY(self.imageFrame);
        if (self.message.replyProduct.infoList && self.message.replyProduct.infoList.count > 0) {
            self.firstInfoFrame = CGRectMake(CGRectGetMinX(self.titleFrame), CGRectGetMaxY(self.titleFrame)+kUDInfoToInfoVerticalSpacing, textMaxWidth/2, kUDInfoToInfoHeight);

            if (CGRectGetMaxY(self.firstInfoFrame) > bubbleMaxY) {
                bubbleMaxY = CGRectGetMaxY(self.firstInfoFrame);
            }
            
            UdeskMessageProductInfo *model = self.message.replyProduct.infoList[0];
            self.firstAttributedString = [[NSAttributedString alloc] initWithString:model.info attributes:[self productInfoAttributes:model]];
            
        }
        if (self.message.replyProduct.infoList && self.message.replyProduct.infoList.count > 1) {
            self.secondInfoFrame = CGRectMake(CGRectGetMaxX(self.firstInfoFrame), CGRectGetMaxY(self.titleFrame)+kUDInfoToInfoVerticalSpacing, textMaxWidth/2, kUDInfoToInfoHeight);
            
            UdeskMessageProductInfo *model = self.message.replyProduct.infoList[1];
            self.secondAttributedString = [[NSAttributedString alloc] initWithString:model.info attributes:[self productInfoAttributes:model]];
        }
        if (self.message.replyProduct.infoList && self.message.replyProduct.infoList.count > 2) {
            self.thirdInfoFrame = CGRectMake(CGRectGetMinX(self.titleFrame), CGRectGetMaxY(self.secondInfoFrame)+ kUDInfoToInfoVerticalSpacing, textMaxWidth, kUDInfoToInfoHeight);
            bubbleMaxY = CGRectGetMaxY(self.thirdInfoFrame);
            
            UdeskMessageProductInfo *model = self.message.replyProduct.infoList[2];
            self.thirdAttributedString = [[NSAttributedString alloc] initWithString:model.info attributes:[self productInfoAttributes:model]];
        }
        
        CGFloat bubbleX = UD_SCREEN_WIDTH-kUDBubbleToHorizontalEdgeSpacing-[self productMaxWidth]-(kUDBubbleToProductHorizontalSpacing*2);
        self.bubbleFrame = CGRectMake(bubbleX, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, [self productMaxWidth]+kUDBubbleToProductHorizontalSpacing*2, bubbleMaxY+kUDBubbleToProductVerticalSpacing);
    }
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin+self.transferHeight;
}

- (NSDictionary *)productInfoAttributes:(UdeskMessageProductInfo *)model {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (model.boldFlag) {
        [dic setObject:[UIFont boldSystemFontOfSize:12] forKey:NSFontAttributeName];
    }
    
    if (model.color) {
        [dic setObject:[UIColor udColorWithHexString:model.color] forKey:NSForegroundColorAttributeName];
    }
    
    return dic;
}

- (CGFloat)productMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH)-(kUDBubbleToProductHorizontalSpacing*2);
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
