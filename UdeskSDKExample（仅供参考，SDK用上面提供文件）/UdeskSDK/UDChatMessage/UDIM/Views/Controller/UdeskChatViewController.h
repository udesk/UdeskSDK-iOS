//
//  UdeskChatViewController.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"

@class UDStatus;
@interface UdeskChatViewController : UdeskBaseViewController

@property (nonatomic, strong) UDStatus *status;

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config;


@end
