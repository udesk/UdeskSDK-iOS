//
//  UdeskCustomLocationViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2017/9/5.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskLocationModel;

@interface UdeskCustomLocationViewController : UIViewController

@property (nonatomic, strong) UdeskLocationModel *locationModel;
@property (nonatomic, copy) void(^sendLocationBlock)(UdeskLocationModel *model);

- (instancetype)initWithHasSend:(BOOL)hasSend;

@end
