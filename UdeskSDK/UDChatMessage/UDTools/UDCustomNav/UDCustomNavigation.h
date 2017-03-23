//
//  UDCustomNavigation.h
//  Demo
//
//  Created by xuchen on 2017/3/16.
//  Copyright © 2017年 xushichen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UDCustomNavigation : UIView

@property (nonatomic, copy) void(^closeViewController)(void);

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;

@end
