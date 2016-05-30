//
//  UdeskChatViewController.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskChatViewController : UIViewController
/**
 *  客服组id
 */
@property (nonatomic, strong) NSString             *group_id;
/**
 *  客服id
 */
@property (nonatomic, strong) NSString             *agent_id;

@end
