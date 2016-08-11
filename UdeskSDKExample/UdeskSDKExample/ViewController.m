//
//  ViewController.m
//  UdeskSDKExample
//
//  Created by xuchen on 16/3/12.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "ViewController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskTableViewController.h"
#import "Udesk.h"

@interface ViewController () {

    UIButton *contactUsButton;
}

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
    
    contactUsButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    
    //获取用户自定义字段（根据需求请求，如果没有用到用户自定义字段，这个请求可以删除）
//    [UdeskManager getCustomerFields:^(id responseObject, NSError *error) {
//        
//        NSLog(@"用户自定义字段：%@",responseObject);
//    }];
    
#warning sdk_token参数必填，其它参数可选（有的最好都写上）
    NSString *nick_name = [NSString stringWithFormat:@"sdk用户%u",arc4random()];
    NSString *sdk_token = [NSString stringWithFormat:@"%u",arc4random()];
    NSString *email = [NSString stringWithFormat:@"%u@qq.com",arc4random()];
    NSString *cellphone = [NSString stringWithFormat:@"%u",arc4random()];
    
    
    //添加用户自定义字段 (只有sdk_token是必填参数，其他参数可以不填但不能写空值)
    NSDictionary *parameters = @{
                                 @"user": @{
                                         @"sdk_token": sdk_token,
                                         @"nick_name":nick_name,
                                         @"email":email,
                                         @"cellphone":cellphone,
                                         @"weixin_id":@"xiaoming888",
                                         @"weibo_name":@"xmwb888",
                                         @"qq":@"8888888",
                                         @"description":@"用户描述",
                                         @"customer_field":@{
                                                 @"TextField_390":@"测试测试",
                                                 @"SelectField_455":@[@"1"]
                                                 }
                                         }
                                 };
    
    //创建用户
    [UdeskManager createCustomerWithCustomerInfo:parameters];
}

- (void)faqButtonAction {
    
    UdeskFAQViewController *faq = [[UdeskFAQViewController alloc] init];
    
    [self.navigationController pushViewController:faq animated:YES];
}

- (void)contactUsButtonAction {
    
    //在聊天界面不需要通知
    [contactUsButton setTitle:@"联系我们" forState:0];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UD_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];
    
    UdeskChatViewController *chat = [[UdeskChatViewController alloc] init];
    //咨询对象（根据需求选择显示或着不显示，默认不显示）
//    NSDictionary *product =  @{
//                               @"product_imageUrl":@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa0ec124ef3_1000x750.jpg",
//                               @"product_title":@"测试咨询对象标题测试咨询对象标题！",
//                               @"product_detail":@"¥88888.0",
//                               @"product_url":@"http://www.baidu.com"
//                               
//                               };
//    
//    [chat showProductViewWithDictionary:product];
    
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)robotButtonAction {

    UdeskRobotIMViewController *robot = [[UdeskRobotIMViewController alloc] init];
    
    [self.navigationController pushViewController:robot animated:YES];
}

- (void)otherAPIButtonAction {

    UdeskTableViewController *udTab = [[UdeskTableViewController alloc] init];
    
    [self.navigationController pushViewController:udTab animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUdeskMessage:) name:UD_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)receiveUdeskMessage:(NSNotification *)notif {
    
    [contactUsButton setTitle:[NSString stringWithFormat:@"联系我们(%ld)",[UdeskManager getLocalUnreadeMessagesCount]] forState:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
