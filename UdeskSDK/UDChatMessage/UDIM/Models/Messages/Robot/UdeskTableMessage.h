//
//  UdeskTableMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

/** 水平间距 */
extern const CGFloat kUDBubbleToTableHorizontalSpacing;
/** 垂直间距 */
extern const CGFloat kUDBubbleToTableVerticalSpacing;
/** 高度 */
extern const CGFloat kUDSingleTableHeight;

@interface UdeskTableMessage : UdeskBaseMessage

@property (nonatomic, copy  , readonly) NSAttributedString *titleAttributedString;
@property (nonatomic, assign, readonly) CGRect titleFrame;
@property (nonatomic, assign, readonly) CGRect lineFrame;
@property (nonatomic, assign, readonly) CGRect tableFrame;
@property (nonatomic, assign, readonly) CGFloat singleTableWidth;

@end
