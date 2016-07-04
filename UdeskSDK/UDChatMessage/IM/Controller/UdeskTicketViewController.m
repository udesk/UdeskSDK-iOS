//
//  UdeskTicketViewController.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskTicketViewController.h"
#import "UdeskManager.h"
#import "UdeskUtils.h"
#import "UdeskTools.h"
#import "UdeskFoundationMacro.h"

@interface UdeskTicketViewController ()

@end

@implementation UdeskTicketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.udNavView changeTitle:getUDLocalizedString(@"提交问题")];
    
    NSString *key = [UdeskManager key];
    NSString *domain = [UdeskManager domain];
    
    if (![UdeskTools isBlankString:key]||[UdeskTools isBlankString:domain]) {
        
        CGRect webViewRect = self.navigationController.navigationBarHidden?CGRectMake(0, 64, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-64):self.view.bounds;
        _ticketWebView = [[UIWebView alloc] initWithFrame:webViewRect];
        _ticketWebView.backgroundColor=[UIColor whiteColor];
        
        NSURL *ticketURL = [UdeskManager getSubmitTicketURL];
        
        [_ticketWebView loadRequest:[NSURLRequest requestWithURL:ticketURL]];
        
        [self.view addSubview:_ticketWebView];
        
        [_ticketWebView stringByEvaluatingJavaScriptFromString:@"ticketCallBack()"];
    }

}

- (void)backButtonAction {

    [super backButtonAction];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = UdeskUIConfig.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = UdeskUIConfig.oneSelfNavcigtionColor;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = UdeskUIConfig.ticketNavigationColor;
    } else {
        self.navigationController.navigationBar.barTintColor = UdeskUIConfig.ticketNavigationColor;
        self.navigationController.navigationBar.tintColor = UdeskUIConfig.ticketBackButtonColor;
    }
    
}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
}

@end
