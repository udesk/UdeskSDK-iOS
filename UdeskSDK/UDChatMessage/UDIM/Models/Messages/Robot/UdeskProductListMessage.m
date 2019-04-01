//
//  UdeskProductListMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskProductListMessage.h"
#import "UdeskProductListCell.h"
#import "NSAttributedString+UdeskHTML.h"
#import "UdeskBundleUtils.h"

/** 水平间距 */
const CGFloat kUDBubbleToProductListHorizontalSpacing = 14.0;
/** 垂直间距 */
const CGFloat kUDBubbleToProductListVerticalSpacing = 10.0;
/** 垂直间距 */
const CGFloat kUDProductListTitleToInfoVerticalSpacing = 10.0;
/** 垂直间距 */
const CGFloat kUDProductListInfoToInfoVerticalSpacing = 5.0;
/** 垂直间距 */
const CGFloat kUDProductListInfoToInfoHeight = 20.0;
/** 图片宽度 */
const CGFloat kUDProductListImageWidth = 60.0;
/** 图片高度 */
const CGFloat kUDProductListImageHeight = 60.0;
/** 标题最大高度 */
const CGFloat kUDProductListTitleMaxHeight = 40.0;

@interface UdeskProductListMessage()

@property (nonatomic, copy  , readwrite) NSAttributedString *titleAttributedString;
@property (nonatomic, assign, readwrite) CGRect titleFrame;
@property (nonatomic, assign, readwrite) CGRect lineFrame;
@property (nonatomic, assign, readwrite) CGRect listFrame;
@property (nonatomic, assign, readwrite) CGRect lineTwoFrame;
@property (nonatomic, strong, readwrite) NSArray *productHeightArray;
@property (nonatomic, strong, readwrite) NSArray *cellHeightArray;
@property (nonatomic, assign, readwrite) CGRect turnFrame;
@property (nonatomic, copy  , readwrite) NSString *turnTitle;

@end

@implementation UdeskProductListMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutProductListMessage];
    }
    return self;
}

- (void)layoutProductListMessage {
    
    if (!self.message.productList || self.message.productList == (id)kCFNull) return ;
    
    if (self.message.messageFrom == UDMessageTypeReceiving) {
        
        self.titleAttributedString = [NSAttributedString attributedStringFromHTML:self.message.answerTitle customFont:[UIFont systemFontOfSize:15]];
        
        CGSize titleSize = [UdeskStringSizeUtil getSizeForAttributedText:self.titleAttributedString textWidth:[self productListMaxWidth]];
        self.titleFrame = CGRectMake(kUDBubbleToProductListHorizontalSpacing, kUDBubbleToProductListVerticalSpacing, titleSize.width, titleSize.height);
        
        self.lineFrame = CGRectMake(0, CGRectGetMaxY(self.titleFrame), [self productListMaxWidth]+(kUDBubbleToProductListHorizontalSpacing*2), 1);
        
        CGFloat listHeight = 0;
        NSMutableArray *cellHeightArray = [NSMutableArray array];
        
        NSArray *productList = self.message.productList;
        if (self.message.productList.count > self.message.showSize.integerValue) {
            productList = [self.message.productList subarrayWithRange:NSMakeRange(0, self.message.showSize.integerValue)];
        }
        
        for (UdeskMessageProduct *productModel in productList) {
            
            CGFloat textMaxWidth = [self productListMaxWidth]-kUDBubbleToProductListHorizontalSpacing-kUDProductListImageWidth;
            
            NSAttributedString *productTitleAtt = [NSAttributedString attributedStringFromHTML:productModel.name customFont:[UIFont systemFontOfSize:15]];
            CGSize titleSize = [UdeskStringSizeUtil getSizeForAttributedText:productTitleAtt width:textMaxWidth height:kUDProductListTitleMaxHeight];
            CGRect titleFrame = CGRectMake(kUDProductListImageWidth + kUDBubbleToProductListHorizontalSpacing, kUDBubbleToProductListVerticalSpacing, [self productListMaxWidth], titleSize.height);
            
            CGFloat cellMaxY = kUDBubbleToProductListVerticalSpacing + (titleSize.height>kUDProductListImageHeight?:kUDProductListImageHeight);
            if (productModel.infoList && productModel.infoList.count > 0) {
                
                CGFloat firstInfoMaxY = CGRectGetMaxY(titleFrame)+kUDProductListInfoToInfoVerticalSpacing+kUDProductListInfoToInfoHeight;
                if (firstInfoMaxY>cellMaxY) {
                    cellMaxY = firstInfoMaxY;
                }
            }

            if (productModel.infoList && productModel.infoList.count > 2) {
                cellMaxY += (kUDProductListInfoToInfoVerticalSpacing + kUDProductListInfoToInfoHeight);
            }
            
            cellMaxY += kUDBubbleToProductListHorizontalSpacing;
            listHeight += cellMaxY;
            
            [cellHeightArray addObject:@(cellMaxY)];
        }
        
        self.cellHeightArray = cellHeightArray;
        self.listFrame = CGRectMake(1, CGRectGetMaxY(self.lineFrame), CGRectGetWidth(self.lineFrame)-2, listHeight);
        
        CGFloat bubbleMaxY = CGRectGetMaxY(self.listFrame);
        
        //是否开启随便看看
        if (self.message.turnFlag.boolValue) {
            self.lineTwoFrame = CGRectMake(0, CGRectGetMaxY(self.listFrame), CGRectGetWidth(self.lineFrame), 1);
            self.turnFrame = CGRectMake(0, CGRectGetMaxY(self.lineTwoFrame), CGRectGetWidth(self.lineFrame), kUDProductListTitleMaxHeight);
            bubbleMaxY = CGRectGetMaxY(self.turnFrame);
            self.turnTitle = getUDLocalizedString(@"udesk_change_group");
        }
        
        self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, [self productListMaxWidth]+kUDBubbleToProductListHorizontalSpacing*2, bubbleMaxY+kUDBubbleToProductListVerticalSpacing);
        
        self.displayProductArray = productList;
    }
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin+self.transferHeight;
}

- (CGFloat)productListMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH)-(kUDBubbleToProductListHorizontalSpacing*2);
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskProductListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
