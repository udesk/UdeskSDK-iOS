//
//  UdeskWebViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2019/3/4.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskWebViewController.h"
#import <WebKit/WebKit.h>
#import "UdeskSDKMacro.h"
#import "UIView+UdeskSDK.h"

@interface UdeskWebViewController ()

@property (nonatomic, strong) WKWebView *robotWkWebView;
@property (nonatomic, strong) UIWebView *robotWebView;

@property (nonatomic, strong) NSURL *URL;

@end

@implementation UdeskWebViewController

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        _URL = URL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:45];
    
    if (ud_isIOS8) {
        _robotWkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _robotWkWebView.backgroundColor = [UIColor whiteColor];
        [_robotWkWebView loadRequest:request];
        [self.view addSubview:_robotWkWebView];
    }
    else {
        _robotWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _robotWebView.backgroundColor = [UIColor whiteColor];
        [_robotWebView loadRequest:request];
        [self.view addSubview:_robotWebView];
    }
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
