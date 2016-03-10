//
//  ViewController.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/29.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "ViewController.h"
#import "UDChatViewController.h"
#import "UDFaqController.h"
#import "UDRobotIMViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"设置";
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = UDRGBACOLOR(275.0f, 275.0f, 275.0f, 1);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-170)/2, 10, 170, 40)];
    label.text = @"欢迎使用Udesk SDK";
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-280)/2, label.frame.origin.y + label.frame.size.height, 280, 40)];
    label1.text = @"以下是展示Udesk SDK功能的按钮";
    label1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label1];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake((UD_SCREEN_WIDTH-130)/2, label1.frame.origin.y + label1.frame.size.height+10, 130, 40);
    [button1 setTitle:@"帮助中心" forState:0];
    [button1 setTitleColor:[UIColor blackColor] forState:0];
    button1.layer.cornerRadius = 3;
    button1.layer.masksToBounds = YES;
    button1.layer.borderWidth = 1.2;
    button1.layer.borderColor = [UIColor blackColor].CGColor;
    [button1 addTarget:self action:@selector(buttonAction1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake((UD_SCREEN_WIDTH-130)/2, button1.frame.origin.y + button1.frame.size.height+20, 130, 40);
    [button2 setTitle:@"联系我们" forState:0];
    [button2 setTitleColor:[UIColor blackColor] forState:0];
    button2.layer.cornerRadius = 3;
    button2.layer.masksToBounds = YES;
    button2.layer.borderWidth = 1.2;
    button2.layer.borderColor = [UIColor blackColor].CGColor;
    [button2 addTarget:self action:@selector(buttonAction2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake((UD_SCREEN_WIDTH-130)/2, button2.frame.origin.y + button2.frame.size.height+20, 130, 40);
    [button3 setTitle:@"机器人" forState:0];
    [button3 setTitleColor:[UIColor blackColor] forState:0];
    button3.layer.cornerRadius = 3;
    button3.layer.masksToBounds = YES;
    button3.layer.borderWidth = 1.2;
    button3.layer.borderColor = [UIColor blackColor].CGColor;
    [button3 addTarget:self action:@selector(buttonAction3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    [self setNewConfigUdesk];
}

- (void)setNewConfigUdesk {
    
    //获取用户自定义字段
    [UDManager getCustomerFields:^(id responseObject, NSError *error) {
        
        //NSLog(@"用户自定义字段：%@",responseObject);
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
    
    
//    NSDictionary *parameters = @{
//                                 @"user": @{
//                                         @"sdk_token": @"testsdktokenencrypt",
//                                         @"nick_name": @"测试"
//                                         }
//                                 };
    
    //创建用户
    [UDManager createCustomer:parameters completion:^(NSString *customerId, NSError *error) {
        
        NSLog(@"用户ID:%@",customerId);
        
        [UDManager submitCustomerDevicesInfo:^(id responseObject, NSError *error) {
            
            NSLog(@"提交设备信息:%@",responseObject);
        }];
        
    }];
    
}

- (void)buttonAction1 {
    
    UDFaqController *faq = [[UDFaqController alloc] init];
    
    [self.navigationController pushViewController:faq animated:YES];
    
}

- (void)buttonAction2 {
    
    UDChatViewController *chat = [[UDChatViewController alloc] init];
    
    [self.navigationController pushViewController:chat animated:YES];
    
}

- (void)buttonAction3 {
    
    UDRobotIMViewController *robot = [[UDRobotIMViewController alloc] init];
    
    [self.navigationController pushViewController:robot animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
