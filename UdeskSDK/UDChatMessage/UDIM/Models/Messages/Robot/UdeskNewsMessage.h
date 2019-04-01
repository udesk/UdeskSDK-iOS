//
//  UdeskNewsMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

/** 聊天气泡和其中的文字水平间距 */
extern const  CGFloat kUDBubbleToNewsHorizontalSpacing;
/** 聊天气泡和其中的文字垂直间距 */
extern const  CGFloat kUDBubbleToNewsVerticalSpacing;
/** 项目列表标签Width */
extern const  CGFloat kUDNewsTopAskQuestionVerticalSpacing;
/** 项目列表标签Width */
extern const  CGFloat kUDNewsOptionTagWidth;
/** 项目列表标签Height */
extern const  CGFloat kUDNewsOptionTagHeight;
/** 问题文字水平间距 */
extern const  CGFloat kUDNewsOptionToTagHorizontalSpacing;

@interface UdeskNewsMessage : UdeskBaseMessage

/** 标题Frame */
@property (nonatomic, assign, readonly) CGRect titleFrame;
/** 描述Frame */
@property (nonatomic, assign, readonly) CGRect descFrame;
/** 图片Frame */
@property (nonatomic, assign, readonly) CGRect imgFrame;

@property (nonatomic, assign, readonly) CGRect lineFrame;
@property (nonatomic, assign, readonly) CGRect topAskFrame;
@property (nonatomic, strong, readonly) NSArray *topAskTitleHeightArray;
@property (nonatomic, strong, readonly) NSArray *questionHeightArray;

//标题的文字
@property (nonatomic, copy  , readonly) NSAttributedString *titleAttributedString;
//描述的文字
@property (nonatomic, copy  , readonly) NSAttributedString *descAttributedString;
//描述的文字
@property (nonatomic, copy  , readonly) NSString *imgURL;
//描述的文字
@property (nonatomic, copy  , readonly) NSString *answerURL;

@end
