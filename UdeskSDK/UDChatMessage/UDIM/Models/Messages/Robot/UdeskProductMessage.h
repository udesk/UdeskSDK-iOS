//
//  UdeskProductMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskProductMessage : UdeskBaseMessage

@property (nonatomic, assign, readonly) CGRect titleFrame;
@property (nonatomic, assign, readonly) CGRect imageFrame;
@property (nonatomic, assign, readonly) CGRect firstInfoFrame;
@property (nonatomic, assign, readonly) CGRect secondInfoFrame;
@property (nonatomic, assign, readonly) CGRect thirdInfoFrame;

@property (nonatomic, copy  , readonly) NSURL *imgURL;
@property (nonatomic, copy  , readonly) NSAttributedString *titleAttributedString;
@property (nonatomic, copy  , readonly) NSAttributedString *firstAttributedString;
@property (nonatomic, copy  , readonly) NSAttributedString *secondAttributedString;
@property (nonatomic, copy  , readonly) NSAttributedString *thirdAttributedString;

@end
