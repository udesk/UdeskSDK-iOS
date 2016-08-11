//
//  UdeskRobotIMViewController.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskRobotIMViewController.h"
#import "UdeskChatViewController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "UdeskManager.h"
#import "UdeskAlertController.h"
#import "UdeskAgentNavigationMenu.h"

@interface UdeskRobotIMViewController ()

@end

@implementation UdeskRobotIMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.udNavView changeTitle:getUDLocalizedString(@"智能机器人对话") withColor:UdeskUIConfig.robotTitleColor];
    [self setBackButtonColor:UdeskUIConfig.robotBackButtonColor];

    [UdeskManager createServerCustomerCompletion:^(BOOL success, NSError *error) {
        
        if (success) {
            
            [UdeskManager getRobotURL:^(NSURL *robotUrl) {
                
                if (robotUrl) {
                    
                    CGRect webViewRect = self.navigationController.navigationBarHidden?CGRectMake(0, 64, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-64):self.view.bounds;
                    UIWebView *intelligenceWeb = [[UIWebView alloc] initWithFrame:webViewRect];
                    intelligenceWeb.backgroundColor=[UIColor whiteColor];
                    
                    NSURL *ticketURL = robotUrl;
                    
                    [intelligenceWeb loadRequest:[NSURLRequest requestWithURL:ticketURL]];
                    
                    [self.view addSubview:intelligenceWeb];
                    
                    if ([UdeskManager supportTransfer]) {
                        
                        if (self.navigationController.navigationBarHidden) {
                            [self.udNavView showRightButtonWithName:getUDLocalizedString(@"转人工")];
                        }
                        else {
                            
                            [self transferButton];
                        }

                    }
                    
                } else {
                    
                    UdeskChatViewController *chat = [[UdeskChatViewController alloc] init];
                    
                    [self.navigationController pushViewController:chat animated:NO];
                }
                
            }];
            
        }
        
    }];
    
    //设置返回按钮文字（在A控制器写代码）
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] init];
    barButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = barButtonItem;
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    //设置导航栏颜色
    [self setNavigationBarBackGroundColor:UdeskUIConfig.robotNavigationColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = UdeskUIConfig.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = UdeskUIConfig.oneSelfNavcigtionColor;
    }
}

- (void)backButtonAction {

    [super backButtonAction];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonAction {

    [super rightButtonAction];
    
    [self transferButtonAction];
}

- (void)transferButton {
    
    //取消按钮
    UIButton *informationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    informationButton.frame = CGRectMake(0, 0, 80, 40);
    informationButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [informationButton setTitle:getUDLocalizedString(@"转人工") forState:UIControlStateNormal];
    [informationButton setTitleColor:UdeskUIConfig.robotTransferButtonColor forState:UIControlStateNormal];
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

    [UdeskManager getAgentNavigationMenu:^(id responseObject, NSError *error) {
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
         
            NSArray *result = [responseObject objectForKey:@"result"];
            if (result.count) {
                
                UdeskAgentNavigationMenu *agentMenu = [[UdeskAgentNavigationMenu alloc] initWithMenuArray:result];
                [self.navigationController pushViewController:agentMenu animated:YES];
            }
            else {
            
                UdeskChatViewController *chat = [[UdeskChatViewController alloc] init];
                [self.navigationController pushViewController:chat animated:YES];
            }
        }
        
    }];

}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
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
