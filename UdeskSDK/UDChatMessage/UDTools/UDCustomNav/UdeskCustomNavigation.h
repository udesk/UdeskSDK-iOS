//
//  UdeskCustomNavigation.h
//  UdeskSDK
//
//  Created by Udesk on 2017/3/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskCustomNavigation : UIView

@property (nonatomic, copy) void(^closeViewController)(void);

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;

@end
