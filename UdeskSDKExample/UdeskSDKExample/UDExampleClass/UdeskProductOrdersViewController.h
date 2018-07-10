//
//  UdeskProductOrdersViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskGoodsModel;

typedef NS_ENUM(NSUInteger, UdeskOrderSendType) {
    UdeskOrderSendTypeText,
    UdeskOrderSendTypeImage,
    UdeskOrderSendTypeGIF,
    UdeskOrderSendTypeVoice,
    UdeskOrderSendTypeVideo,
    UdeskOrderSendTypeLocation,
    UdeskOrderSendTypeGoods,
};

@interface UdeskProductOrdersViewController : UITableViewController

@property (nonatomic, copy) void(^didSendOrderBlock)(UdeskOrderSendType sendType,UdeskGoodsModel *goodsModel);

@end
