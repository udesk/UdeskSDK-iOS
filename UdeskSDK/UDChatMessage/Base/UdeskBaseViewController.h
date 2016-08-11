//
//  UdeskBaseViewController.h
//  UdeskSDK
//
//  Created by xuchen on 16/6/15.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskNavigationView.h"

@interface UdeskBaseViewController : UIViewController

@property (nonatomic, strong)UdeskNavigationView *udNavView;

- (void)backButtonAction;
- (void)rightButtonAction;

- (void)setBackButtonColor:(UIColor *)color;
- (void)setNavigationBarBackGroundColor:(UIColor *)color;

@end
