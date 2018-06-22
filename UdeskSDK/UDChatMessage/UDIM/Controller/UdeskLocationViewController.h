//
//  UdeskLocationViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2017/8/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskLocationModel.h"

@class UdeskSDKConfig;
@class UdeskLocationModel;

@interface UdeskLocationViewController : UIViewController

@property (nonatomic, strong) UdeskLocationModel *locationModel;
@property (nonatomic, copy) void(^sendLocationBlock)(UdeskLocationModel *model);

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config hasSend:(BOOL)hasSend;

@end
