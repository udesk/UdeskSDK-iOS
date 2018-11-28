//
//  UdeskStructMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/1/17.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import "UdeskBaseMessage.h"
#import "UdeskBaseModel.h"
#import "UdeskStructView.h"

/** 边距 */
static CGFloat const kUDStructPadding = 10.0;
static CGFloat const kUDStructImageHeight = 150.0;
static CGFloat const kUDStructViewWidth = 250.0;

@interface UdeskStructButton : UdeskBaseModel

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *callback_name;

@end

@interface UdeskStructMessage : UdeskBaseMessage

@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, copy  ) NSString *udDescription;
@property (nonatomic, copy  ) NSString *imgURL;
@property (nonatomic, strong) NSArray  *buttons;

@property (nonatomic, strong          ) UdeskStructView *structContentView;

/** 结构化消息图片 */
@property (nonatomic, strong          ) UIImage    *structImage;
/** 结构消息Point */
@property (nonatomic, assign, readonly) CGPoint    structPoint;

@end
