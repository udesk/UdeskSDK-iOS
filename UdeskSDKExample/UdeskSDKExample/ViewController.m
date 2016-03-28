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
#import "UDTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.title = @"SDK";
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = UDRGBACOLOR(275.0f, 275.0f, 275.0f, 1);
    
    UIImageView *udeskImageView = [[UIImageView alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-220)/2, 00, 220, 140)];
    udeskImageView.image = [UIImage imageNamed:@"udesk.jpg"];
    
    [self.view addSubview:udeskImageView];
    
    UIButton *faqButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faqButton.frame = CGRectMake((UD_SCREEN_WIDTH-130)/2, udeskImageView.frame.origin.y + udeskImageView.frame.size.height, 130, 40);
    [faqButton setTitle:@"帮助中心" forState:0];
    faqButton.backgroundColor = UDRGBCOLOR(31, 166, 255);
    UDViewRadius(faqButton, 3);
    [faqButton addTarget:self action:@selector(faqButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:faqButton];
    
    UIButton *contactUsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    contactUsButton.frame = CGRectMake((UD_SCREEN_WIDTH-130)/2, faqButton.frame.origin.y + faqButton.frame.size.height+20, 130, 40);
    [contactUsButton setTitle:@"联系我们" forState:0];
    contactUsButton.backgroundColor = UDRGBCOLOR(31, 166, 255);
    UDViewRadius(contactUsButton, 3);
    [contactUsButton addTarget:self action:@selector(contactUsButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:contactUsButton];
    
    UIButton *robotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    robotButton.frame = CGRectMake((UD_SCREEN_WIDTH-130)/2, contactUsButton.frame.origin.y + contactUsButton.frame.size.height+20, 130, 40);
    [robotButton setTitle:@"机器人" forState:0];
    robotButton.backgroundColor = UDRGBCOLOR(31, 166, 255);
    UDViewRadius(robotButton, 3);
    [robotButton addTarget:self action:@selector(robotButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:robotButton];
    
    UIButton *otherAPIButton = [UIButton buttonWithType:UIButtonTypeCustom];
    otherAPIButton.frame = CGRectMake((UD_SCREEN_WIDTH-130)/2, robotButton.frame.origin.y + robotButton.frame.size.height+20, 130, 40);
    [otherAPIButton setTitle:@"其它API" forState:0];
    otherAPIButton.backgroundColor = UDRGBCOLOR(31, 166, 255);
    UDViewRadius(otherAPIButton, 3);
    [otherAPIButton addTarget:self action:@selector(otherAPIButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherAPIButton];
    
    
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
    
    
//    NSDictionary *parameters = @{
//                                 @"user": @{
//                                         @"sdk_token": sdk_token,
//                                         @"nick_name": nick_name,
//                                         @"cellphone":@"18888888888",
//                                         @"weixin_id":@"xiaoming888",
//                                         @"weibo_name":@"xmwb888",
//                                         @"qq":@"8888888",
//                                         @"email":@"xiaoming@qq.com",
//                                         @"description":@"用户描述",
//                                         }
//                                 };
    
    
   NSDictionary *parameters = @{
                                     @"user": @{
                                             @"sdk_token": @"zhangmian8890909090",
                                             @"nick_name": @"张勉"
                                             }
                                     };
    
    //创建用户
    [UDManager createCustomer:parameters completion:^(NSString *customerId, NSError *error) {
        
        NSLog(@"用户ID:%@",customerId);
        
        [UDManager submitCustomerDevicesInfo:^(id responseObject, NSError *error) {
            
            NSLog(@"提交设备信息:%@",responseObject);
        }];
        
    }];
    
}

- (void)faqButtonAction {
    
    UDFaqController *faq = [[UDFaqController alloc] init];
    
    [self.navigationController pushViewController:faq animated:YES];
    
}

- (void)contactUsButtonAction {
    
    UDChatViewController *chat = [[UDChatViewController alloc] init];
    
    [self.navigationController pushViewController:chat animated:YES];
    
}

- (void)robotButtonAction {
    
    UDRobotIMViewController *robot = [[UDRobotIMViewController alloc] init];
    
    [self.navigationController pushViewController:robot animated:YES];
    
}

- (void)otherAPIButtonAction {

    UDTableViewController *udTab = [[UDTableViewController alloc] init];
    
    [self.navigationController pushViewController:udTab animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.iMNavigationColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.iMNavigationColor;
        self.navigationController.navigationBar.tintColor = Config.iMBackButtonColor;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.oneSelfNavcigtionColor;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
