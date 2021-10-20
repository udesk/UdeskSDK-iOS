//
//  UDAgentWebViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2017/4/19.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UDAgentWebViewController.h"
#import "UdeskSDKMacro.h"
#import <WebKit/WebKit.h>

@interface UDAgentWebViewController ()

@end

@implementation UDAgentWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (ud_isIOS8) {

        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url?:@"http://udesksdk.udesk.cn/im_client"]]];
        [self.view addSubview:webView];

    }
    else {
    
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url?:@"http://udesksdk.udesk.cn/im_client"]]];
        [self.view addSubview:webView];
    }
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
