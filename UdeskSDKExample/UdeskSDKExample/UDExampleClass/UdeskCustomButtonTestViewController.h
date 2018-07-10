//
//  UdeskCustomButtonTestViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/23.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskProductOrdersViewController.h"
@class UdeskChatViewController;

@interface UdeskCustomButtonTestViewController : UITableViewController

+ (void)sendOrderWithType:(UdeskOrderSendType)sendType viewController:(UdeskChatViewController *)viewController goodsModel:(UdeskGoodsModel *)goodsModel;

@end
