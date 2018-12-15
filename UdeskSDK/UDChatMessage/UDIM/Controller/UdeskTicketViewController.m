//
//  UdeskTicketViewController.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskTicketViewController.h"
#import "UdeskManager.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKMacro.h"
#import "UdeskCustomNavigation.h"
#import "UIView+UdeskSDK.h"
#import <WebKit/WebKit.h>

@interface UdeskTicketViewController ()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>

@end

@implementation UdeskTicketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    @try {
        
        self.view.backgroundColor = self.sdkConfig.sdkStyle.tableViewBackGroundColor;
        
        UdeskCustomNavigation *customNav = [[UdeskCustomNavigation alloc] init];
        if (self.sdkConfig.sdkStyle.navigationColor) {
            customNav.backgroundColor = self.sdkConfig.sdkStyle.navigationColor;
        }
        if (self.sdkConfig.sdkStyle.titleColor) {
            customNav.titleLabel.textColor = self.sdkConfig.sdkStyle.titleColor;
        }
        if (self.sdkConfig.sdkStyle.navBackButtonColor) {
            [customNav.closeButton setTitleColor:self.sdkConfig.sdkStyle.navBackButtonColor forState:UIControlStateNormal];
        }
        
        if (self.sdkConfig.ticketTitle) {
            customNav.titleLabel.text = self.sdkConfig.ticketTitle;
        }
        else {
            customNav.titleLabel.text = getUDLocalizedString(@"udesk_leave_msg");
        }
        
        [self.view addSubview:customNav];
        
        customNav.closeButtonActionBlock = ^(){
            [super dismissViewControllerAnimated:YES completion:nil];
        };
        
        
        NSString *key = [UdeskManager key];
        NSString *domain = [UdeskManager domain];
        
        if (![UdeskSDKUtil isBlankString:key]||[UdeskSDKUtil isBlankString:domain]) {
            
            NSURL *ticketURL =  [UdeskManager getSubmitTicketURL];
            // 设置语言
            NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET];
            // 默认是中文
            if (!tmp)
            {
                tmp = @"zh-Hans";
            }
            
            NSString *language;
            if ([tmp isEqualToString:@"zh-Hans"]) {
                language = @"&language=zh-cn";
            }
            else {
                language = @"&language=en-us";
            }
            
            if ([ticketURL isKindOfClass:[NSURL class]]) {
                NSString *url = [ticketURL.absoluteString stringByAppendingString:language];
                ticketURL = [NSURL URLWithString:url];
            }
            else {
                ticketURL = [NSURL URLWithString:@"https://www.udesk.cn"];
            }
            
            if (ud_isIOS8) {
                WKWebView *ticketWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, customNav.udBottom, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-customNav.udBottom)];
                ticketWebView.UIDelegate = self;
                ticketWebView.navigationDelegate = self;
                ticketWebView.backgroundColor = [UIColor whiteColor];
                [ticketWebView loadRequest:[NSURLRequest requestWithURL:ticketURL]];
                [self.view addSubview:ticketWebView];
            }
            else {
            
                UIWebView *ticketWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, customNav.udBottom, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-customNav.udBottom)];
                ticketWebView.backgroundColor = [UIColor whiteColor];
                ticketWebView.delegate = self;
                [ticketWebView loadRequest:[NSURLRequest requestWithURL:ticketURL]];
                [self.view addSubview:ticketWebView];
            }
            
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (self.presentedViewController)
    {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    decisionHandler(WKNavigationActionPolicyAllow);
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [UdeskSDKConfig customConfig].orientationMask;
}

@end
