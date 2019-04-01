//
//  UdeskTopAskMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

/** 聊天气泡和其中的文字水平间距 */
extern const CGFloat kUDBubbleToTopAskHorizontalSpacing;
/** 聊天气泡和其中的文字垂直间距 */
extern const CGFloat kUDBubbleToTopAskVerticalSpacing;
/** 聊天气泡和其中的文字垂直间距 */
extern const CGFloat kUDCellToTopAskQuestionVerticalSpacing;
/** 聊天气泡和其中的文字水平间距 */
extern const CGFloat kUDCellToTopAskQuestionTagHorizontalSpacing;
/** 聊天气泡和其中的文字垂直间距 */
extern const CGFloat kUDCellToTopAskQuestionTagVerticalSpacing;
/** 项目列表标签Width */
extern const CGFloat kUDTopAskOptionTagWidth;
/** 项目列表标签Height */
extern const CGFloat kUDTopAskOptionTagHeight;
/** 问题文字水平间距 */
extern const CGFloat kUDOptionToTagHorizontalSpacing;

@interface UdeskTopAskMessage : UdeskBaseMessage

@property (nonatomic, copy  , readonly) NSAttributedString *leadingAttributedString;
@property (nonatomic, assign, readonly) CGRect leadingWordFrame;
@property (nonatomic, assign, readonly) CGRect lineFrame;
@property (nonatomic, assign, readonly) CGRect topAskFrame;
@property (nonatomic, strong, readonly) NSArray *topAskTitleHeightArray;
@property (nonatomic, strong, readonly) NSArray *questionHeightArray;

- (void)layoutTopAskMessage;

@end
