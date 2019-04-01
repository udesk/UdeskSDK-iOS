//
//  UdeskQueueMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2018/11/12.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskQueueMessage : UdeskBaseMessage

@property (nonatomic, assign, readonly) BOOL showLeaveMsgBtn;
@property (nonatomic, copy  , readonly) NSString *titleText;
@property (nonatomic, copy  , readonly) NSString *buttonText;
@property (nonatomic, copy            ) NSString *contentText;

@property (nonatomic, assign, readonly) CGRect backGroundFrame;
@property (nonatomic, assign, readonly) CGRect titleFrame;
@property (nonatomic, assign, readonly) CGRect contentFrame;
@property (nonatomic, assign, readonly) CGRect buttonFrame;

@end
