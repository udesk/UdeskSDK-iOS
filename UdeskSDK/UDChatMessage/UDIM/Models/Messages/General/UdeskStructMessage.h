//
//  UdeskStructMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/1/17.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import "UdeskBaseMessage.h"
#import "UdeskStructView.h"

@interface UdeskStructButton : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *callbackName;

- (instancetype)initModelWithJSON:(id)json;

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
