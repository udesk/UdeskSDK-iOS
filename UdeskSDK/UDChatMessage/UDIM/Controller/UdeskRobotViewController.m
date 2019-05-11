//
//  UdeskRobotViewController.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskRobotViewController.h"
#import "UdeskChatViewController.h"
#import "UdeskSDKMacro.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskManager.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKShow.h"
#import "UdeskAgentMenuViewController.h"
#import <WebKit/WebKit.h>
#import "UIView+UdeskSDK.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKAlert.h"
#import "UIBarButtonItem+UdeskSDK.h"

@interface UdeskRobotViewController()<WKUIDelegate,WKNavigationDelegate,UIWebViewDelegate>

@property (nonatomic, strong) WKWebView *robotWkWebView;
@property (nonatomic, strong) UIWebView *robotWebView;

@end

@implementation UdeskRobotViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = self.sdkConfig.sdkStyle.tableViewBackGroundColor;
    
    //更新机器人名称
    [self updateRobotName];
    //更新转人工
    [self updateTransferButton];
    //添加其他参数
    [self appendParameterToRobotURL];
    //创建用户
    [self createCustomer];
    //监听键盘
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setRobotURL:(NSURL *)robotURL {
    if (!robotURL || robotURL == (id)kCFNull) return ;
    if (![robotURL isKindOfClass:[NSURL class]]) return ;
    _robotURL = robotURL;
}

- (void)appendParameterToRobotURL {
    
    @try {
     
        //设置语言
        NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET];
        //默认是中文
        if (!tmp) {
            tmp = @"zh-Hans";
        }
        
        NSString *language;
        if ([tmp isEqualToString:@"zh-Hans"]) {
            language = @"&language=zh-cn";
        }
        else {
            language = @"&language=en-us";
        }
        
        self.robotURL = [NSURL URLWithString:[self.robotURL.absoluteString stringByAppendingString:language]];
        
        //modelKey
        if (![UdeskSDKUtil isBlankString:[UdeskSDKConfig customConfig].robotModelKey]) {
            NSString *parameter = [NSString stringWithFormat:@"&robot_modelKey=%@",[UdeskSDKConfig customConfig].robotModelKey];
            NSString *robotURL = [self.robotURL.absoluteString stringByAppendingString:parameter];
            self.robotURL = [NSURL URLWithString:[robotURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        //客户信息
        if (![UdeskSDKUtil isBlankString:[UdeskSDKConfig customConfig].robotCustomerInfo]) {
            NSString *parameter = [NSString stringWithFormat:@"&%@",[UdeskSDKConfig customConfig].robotCustomerInfo];
            NSString *robotURL = [self.robotURL.absoluteString stringByAppendingString:parameter];
            self.robotURL = [NSURL URLWithString:[robotURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//更新机器人名称
- (void)updateRobotName {
    
    @try {
     
        if (self.sdkSetting && self.sdkSetting.robotName && ![UdeskSDKUtil isBlankString:self.sdkSetting.robotName]) {
            self.navigationItem.title = self.sdkSetting.robotName;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//更新转人工按钮
- (void)updateTransferButton {
    
    @try {
     
        if (self.sdkSetting) {
            if (!self.sdkSetting.enableAgent.boolValue) {
                self.navigationItem.rightBarButtonItems = nil;
            }
            else {
                //设置了客服发送多少条消息之后才展示转人工按钮
                if (self.sdkSetting.showRobotTimes.integerValue) {
                    self.navigationItem.rightBarButtonItems = nil;
                }
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//创建用户
- (void)createCustomer {

    [UdeskManager createCustomerForRobot:^(NSError *error) {
        
        @try {
            
            if (!error) {
                
                CGFloat spacing = 0;
                if (udIsIPhoneXSeries) {
                    spacing = 34;
                }
                
                CGRect webViewRect = self.navigationController.navigationBarHidden?CGRectMake(0, 64, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-64):self.view.bounds;
                NSURLRequest *request = [NSURLRequest requestWithURL:self.robotURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
                
                if (ud_isIOS8) {

                    _robotWkWebView = [[WKWebView alloc] initWithFrame:webViewRect];
                    _robotWkWebView.UIDelegate = self;
                    _robotWkWebView.navigationDelegate = self;
                    _robotWkWebView.udHeight -= spacing;
                    _robotWkWebView.backgroundColor = [UIColor whiteColor];
                    [_robotWkWebView loadRequest:request];
                    [self.view addSubview:_robotWkWebView];
                }
                else {

                    _robotWebView = [[UIWebView alloc] initWithFrame:webViewRect];
                    _robotWebView.udHeight -= spacing;
                    _robotWebView.backgroundColor=[UIColor whiteColor];
                    _robotWebView.delegate = self;
                    [_robotWebView loadRequest:request];
                    [self.view addSubview:_robotWebView];
                }
            }
            else {
                
                NSDictionary *userInfo = error.userInfo;
                if ([userInfo objectForKey:@"isBlocked"]) {
                    [self showIsBlacklistedAlert];
                }
                NSLog(@"UdeskSDK:%@",error);
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    else if (navigationType == UIWebViewNavigationTypeOther) {
        //显示转人工
        if ([request.URL.absoluteString rangeOfString:@"udesk_notice_type=show_transfer"].location != NSNotFound) {
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem udRightItemWithTitle:getUDLocalizedString(@"udesk_redirect") target:self action:@selector(didSelectNavigationRightButton)];
        }
        else if ([request.URL.absoluteString rangeOfString:@"udesk_notice_type=go_chat"].location != NSNotFound) {
            [self didSelectNavigationRightButton];
            return NO;
        }
        else if ([request.URL.absoluteString rangeOfString:@"udesk_notice_type=auto_transfer"].location != NSNotFound) {
            [self didSelectNavigationRightButton];
            return NO;
        }
    }
    return YES;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    }
    else if (navigationAction.navigationType == WKNavigationTypeOther) {
        //显示转人工
        if ([navigationAction.request.URL.absoluteString rangeOfString:@"udesk_notice_type=show_transfer"].location != NSNotFound) {
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem udRightItemWithTitle:getUDLocalizedString(@"udesk_redirect") target:self action:@selector(didSelectNavigationRightButton)];
        }
        else if ([navigationAction.request.URL.absoluteString rangeOfString:@"udesk_notice_type=go_chat"].location != NSNotFound) {
            [self didSelectNavigationRightButton];
        }
        else if ([navigationAction.request.URL.absoluteString rangeOfString:@"udesk_notice_type=auto_transfer"].location != NSNotFound) {
            [self didSelectNavigationRightButton];
        }
    }
    
    if ([navigationAction.request.URL.absoluteString rangeOfString:@"udesk_notice_type=go_chat"].location != NSNotFound ||
        [navigationAction.request.URL.absoluteString rangeOfString:@"udesk_notice_type=auto_transfer"].location != NSNotFound ||
        navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

//黑名单
- (void)showIsBlacklistedAlert {
    
    [UdeskSDKAlert showBlacklisted:getUDLocalizedString(@"udesk_alert_view_blocked_list") handler:^{
        [self dismissChatViewController];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didSelectNavigationRightButton {
    
    @try {
        
        if (!self.sdkSetting) {
            return;
        }
        
        UdeskSDKShow *show = [[UdeskSDKShow alloc] initWithConfig:self.sdkConfig];
        //容错处理
        if (!self.sdkSetting.enableImGroup) {
            [self pushChatViewController:show];
            return;
        }
        
        if (self.sdkSetting.enableImGroup.boolValue) {
            
            //查看是否有导航栏
            [UdeskManager getAgentNavigationMenu:^(id responseObject, NSError *error) {
                
                @try {
                    
                    //查看导航栏错误，直接进入聊天页面
                    if (error) {
                        [self pushChatViewController:show];
                        return ;
                    }
                    
                    if ([[responseObject objectForKey:@"code"] integerValue] != 1000) {
                        [self pushChatViewController:show];
                        return ;
                    }
                    
                    //数据返回正确
                    NSArray *result = [responseObject objectForKey:@"result"];
                    //有设置客服导航栏
                    if (result.count) {
                        //如果后台有配置
                        UdeskAgentMenuViewController *agentMenu = [[UdeskAgentMenuViewController alloc] initWithSDKConfig:self.sdkConfig setting:self.sdkSetting];
                        agentMenu.menuDataSource = result;
                        [show presentOnViewController:self udeskViewController:agentMenu transiteAnimation:UDTransiteAnimationTypePush completion:nil];
                    }
                    else {
                        //没有设置导航栏 直接进入聊天页面
                        [self pushChatViewController:show];
                    }
                    
                } @catch (NSException *exception) {
                    NSLog(@"%@",exception);
                } @finally {
                }
            }];
            
        }
        else {
            [self pushChatViewController:show];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)pushChatViewController:(UdeskSDKShow *)show {

    UdeskChatViewController *chat = [[UdeskChatViewController alloc] initWithSDKConfig:self.sdkConfig setting:self.sdkSetting];
    [show presentOnViewController:self udeskViewController:chat transiteAnimation:UDTransiteAnimationTypePush completion:nil];
}

#pragma mark - 如果使用第三键盘，会导致键盘把输入框遮挡，使用此方法解决
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self updateWebViewFrameWithKeyboardF:keyboardF];
    }];
}

- (void)updateWebViewFrameWithKeyboardF:(CGRect)keyboardF {
    
    if (ud_isIOS8) {
        
        if (_robotWkWebView) {
            _robotWkWebView.udHeight = (UD_SCREEN_HEIGHT == keyboardF.origin.y) ? CGRectGetHeight(self.view.bounds) : keyboardF.origin.y;
        }
    }
    else {
        
        if (_robotWebView) {
            _robotWebView.udHeight = (UD_SCREEN_HEIGHT == keyboardF.origin.y) ? CGRectGetHeight(self.view.bounds) : keyboardF.origin.y;
        }
    }
}

@end
