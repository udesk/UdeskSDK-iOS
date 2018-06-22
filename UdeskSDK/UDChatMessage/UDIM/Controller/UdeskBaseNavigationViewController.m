//
//  UdeskBaseNavigationViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/3.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskBaseNavigationViewController.h"
#import "UdeskSDKConfig.h"

@interface UdeskBaseNavigationViewController ()

@end

@implementation UdeskBaseNavigationViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [UdeskSDKConfig customConfig].orientationMask;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
