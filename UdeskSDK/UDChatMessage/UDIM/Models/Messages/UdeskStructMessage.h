//
//  UdeskStructMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/1/17.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import "UdeskBaseMessage.h"
#import "UdeskBaseModel.h"

/** 边距 */
static CGFloat const kUDStructPadding = 10.0;
static CGFloat const kUDStructImageHeight = 150.0;
static CGFloat const kUDStructViewWidth = 250.0;

@interface UdeskStructButton : UdeskBaseModel

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *value;

@end

@interface UdeskStructMessage : UdeskBaseMessage

@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, copy  ) NSString *udDescription;
@property (nonatomic, copy  ) NSString *imgURL;
@property (nonatomic, strong) NSArray  *buttons;

/** 消息发送人头像 */
@property (nonatomic, strong          ) UIImage    *avatarImage;
/** 结构化消息图片 */
@property (nonatomic, strong          ) UIImage    *structImage;
/** 时间frame */
@property (nonatomic, assign, readonly) CGRect     dateFrame;
/** 头像frame */
@property (nonatomic, assign, readonly) CGRect     avatarFrame;
/** 结构消息Point */
@property (nonatomic, assign, readonly) CGPoint    structPoint;

- (instancetype)initWithUdeskMessage:(UdeskMessage *)message;

@end
