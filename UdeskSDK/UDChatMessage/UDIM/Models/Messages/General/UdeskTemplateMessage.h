//
//  UdeskTemplateMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2019/6/5.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskTemplateButtonMessage : UdeskBaseMessage

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect lineFrame;

@end

@interface UdeskTemplateMessage : UdeskBaseMessage

@property (nonatomic, copy  , readonly) NSAttributedString *titleAttributedString;
@property (nonatomic, copy  , readonly) NSAttributedString *contentAttributedString;
@property (nonatomic, assign, readonly) CGRect titleFrame;
@property (nonatomic, assign, readonly) CGRect lineOneFrame;
@property (nonatomic, assign, readonly) CGRect contentFrame;
@property (nonatomic, assign, readonly) CGRect lineTwoFrame;
@property (nonatomic, assign, readonly) CGRect buttonsFrame;
@property (nonatomic, strong, readonly) NSArray *buttonsArray;

@end
