//
//  ViewController.m
//  UdeskSDKExample
//
//  Created by xuchen on 16/3/12.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "ViewController.h"
#import "UDChatViewController.h"
#import "UDFaqController.h"
#import "UDRobotIMViewController.h"
#import "UDAgentNavigationMenu.h"
#import "UDFoundationMacro.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UILabel *sdkLabel = [[UILabel alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-100)/2, 0, 100, 44)];
    sdkLabel.text = @"SDK";
    sdkLabel.backgroundColor = [UIColor clearColor];
    sdkLabel.textAlignment = NSTextAlignmentCenter;
    sdkLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = sdkLabel;
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.iMNavigationColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.iMNavigationColor;
    }
    
    [self setNewConfigUdesk];
    
}

- (void)setNewConfigUdesk {
    
    //获取用户自定义字段
    [UDManager getCustomerFields:^(id responseObject, NSError *error) {
        
        NSLog(@"用户自定义字段：%@",responseObject);
    }];
    
#warning sdk_token参数必填，其它参数可选（有的最好都写上）
    NSString *nick_name = [NSString stringWithFormat:@"sdk用户%u",arc4random()];
    NSString *sdk_token = [NSString stringWithFormat:@"%u",arc4random()];
    
    
    NSDictionary *parameters = @{
                                 @"user": @{
                                         @"sdk_token": sdk_token,
                                         @"nick_name": nick_name
                                         }
                                 };
    
    
//        NSDictionary *parameters = @{
//                                     @"user": @{
//                                             @"sdk_token": @"zhangmian8890909090",
//                                             @"nick_name": @"张勉"
//                                             }
//                                     };
    
    //创建用户
    [UDManager createCustomer:parameters completion:^(NSString *customerId, NSError *error) {
        
        NSLog(@"用户ID:%@",customerId);
        
        [UDManager submitCustomerDevicesInfo:^(id responseObject, NSError *error) {
            
            NSLog(@"提交设备信息:%@",responseObject);
        }];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)udeskFaq:(id)sender {
    
    UDFaqController *faq = [[UDFaqController alloc] init];
    
    [self.navigationController pushViewController:faq animated:YES];
    
}

- (IBAction)udeskContactUs:(id)sender {
    
    UDChatViewController *chat = [[UDChatViewController alloc] init];
    
    [self.navigationController pushViewController:chat animated:YES];
}

- (IBAction)udeskRobot:(id)sender {
    
    UDRobotIMViewController *robot = [[UDRobotIMViewController alloc] init];
    
    [self.navigationController pushViewController:robot animated:YES];
}
@end
