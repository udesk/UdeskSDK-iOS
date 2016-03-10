//
//  UDRobotIMViewController.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDRobotIMViewController.h"
#import "UDChatViewController.h"
#import "UDFoundationMacro.h"
#import "UdeskUtils.h"
#import "UDManager.h"
#import "UDAlertController.h"

@interface UDRobotIMViewController ()

@end

@implementation UDRobotIMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *robotTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    robotTitle.text = getUDLocalizedString(@"智能机器人对话");
    robotTitle.backgroundColor = [UIColor clearColor];
    robotTitle.textColor = Config.robotTitleColor;
    self.navigationItem.titleView = robotTitle;
    
    [UDManager getRobotURL:^(NSURL *robotUrl) {
        
        if (robotUrl) {
            
            UIWebView *intelligenceWeb = [[UIWebView alloc] initWithFrame:self.view.bounds];
            intelligenceWeb.backgroundColor=[UIColor whiteColor];
            
            NSURL *ticketURL = robotUrl;
            
            [intelligenceWeb loadRequest:[NSURLRequest requestWithURL:ticketURL]];
            
            [self.view addSubview:intelligenceWeb];
            
            [self transferButton];
            
        } else {
            
            UDAlertController *leaveOrTicket = [UDAlertController alertWithTitle:nil message:@"没有开通机器人"];
            [leaveOrTicket addCloseActionWithTitle:@"确定" Handler:^(UDAlertAction * _Nonnull action) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [leaveOrTicket showWithSender:nil controller:nil animated:YES completion:NULL];
        }
        
        
    }];
    
    //设置返回按钮文字（在A控制器写代码）
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] init];
    barButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = barButtonItem;
}

- (void)transferButton {
    
    BOOL transfer;
    if ([UDManager supportTransfer]) {
        transfer = YES;
    } else {
        transfer = NO;
    }
    
    //取消按钮
    UIButton * informationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    informationButton.frame = CGRectMake(0, 0, 80, 40);
    informationButton.hidden = !transfer;
    informationButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [informationButton setTitle:getUDLocalizedString(@"转人工") forState:UIControlStateNormal];
    [informationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [informationButton addTarget:self action:@selector(transferButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *otherNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:informationButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    // 调整 leftBarButtonItem 在 iOS7 下面的位置
    if((FUDSystemVersion>=7.0)){
        
        negativeSpacer.width = -20;
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,otherNavigationItem];
    }else
        self.navigationItem.rightBarButtonItem = otherNavigationItem;
}

- (void)transferButtonAction {

    UDChatViewController *chatMsg = [[UDChatViewController alloc] init];
    
    [self.navigationController pushViewController:chatMsg animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    if (_navigationBarHidden) {
        self.navigationController.navigationBarHidden = !_navigationBarHidden;
    }
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.robotNavigationColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.robotNavigationColor;
        self.navigationController.navigationBar.tintColor = Config.robotBackButtonColor;
    }
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = _navigationBarHidden;
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.oneSelfNavcigtionColor;
    }
}

- (void)dealloc
{

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
