//
//  UdeskChatViewController.h
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UdeskChatViewModel.h"

@interface UdeskChatViewController : UdeskBaseViewController

@property (nonatomic, strong) UdeskChatViewModel        *chatViewModel;//viewModel

//更新发送消息的状态
- (void)sendMessageStatus:(BOOL)sendStatus
                  message:(UdeskMessage *)message;

@end
