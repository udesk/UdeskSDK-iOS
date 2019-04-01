//
//  UdeskProductListMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

/** 水平间距 */
extern const CGFloat kUDBubbleToProductListHorizontalSpacing;
/** 垂直间距 */
extern const CGFloat kUDBubbleToProductListVerticalSpacing;
/** 垂直间距 */
extern const CGFloat kUDProductListTitleToInfoVerticalSpacing;
/** 垂直间距 */
extern const CGFloat kUDProductListInfoToInfoVerticalSpacing;
/** 垂直间距 */
extern const CGFloat kUDProductListInfoToInfoHeight;
/** 图片宽度 */
extern const CGFloat kUDProductListImageWidth;
/** 图片高度 */
extern const CGFloat kUDProductListImageHeight;
/** 标题最大高度 */
extern const CGFloat kUDProductListTitleMaxHeight;

@interface UdeskProductListMessage : UdeskBaseMessage

@property (nonatomic, copy  , readonly) NSAttributedString *titleAttributedString;
@property (nonatomic, assign, readonly) CGRect titleFrame;
@property (nonatomic, assign, readonly) CGRect lineFrame;
@property (nonatomic, assign, readonly) CGRect listFrame;
@property (nonatomic, assign, readonly) CGRect lineTwoFrame;
@property (nonatomic, strong, readonly) NSArray *cellHeightArray;
@property (nonatomic, assign, readonly) CGRect turnFrame;
@property (nonatomic, copy  , readonly) NSString *turnTitle;

@property (nonatomic, strong) NSArray *displayProductArray;

- (void)layoutProductListMessage;

@end
