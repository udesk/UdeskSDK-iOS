//
//  UdeskSmallVideoNavigationController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSmallVideoNavigationController.h"

@interface UdeskSmallVideoNavigationController ()

@end

@implementation UdeskSmallVideoNavigationController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
