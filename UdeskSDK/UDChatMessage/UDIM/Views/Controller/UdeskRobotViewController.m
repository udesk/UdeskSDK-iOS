//
//  UdeskRobotViewController.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskRobotViewController.h"
#import "UdeskChatViewController.h"
#import "UdeskFoundationMacro.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskManager.h"
#import "UdeskAlertController.h"
#import "UdeskUtils.h"
#import "UdeskLanguageTool.h"
#import "UdeskSDKManager.h"
#import "UdeskSDKShow.h"
#import "UdeskAgentMenuViewController.h"
#import <WebKit/WebKit.h>

@implementation UdeskRobotViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = self.sdkConfig.sdkStyle.tableViewBackGroundColor;

    [self setRobotLanguage];
    [self createCustomer];
}

- (void)setRobotLanguage {

    if (!self.robotURL) {
        return;
    }
    
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
}

- (void)createCustomer {

    [UdeskManager createCustomerForRobot:^(BOOL success, NSError *error) {
        
        @try {
            
            if (success) {
                
                if (self.sdkSetting) {
                    if (!self.sdkSetting.enableAgent.boolValue) {
                        self.navigationItem.rightBarButtonItems = nil;
                    }
                }
                
                CGRect webViewRect = self.navigationController.navigationBarHidden?CGRectMake(0, 64, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-64):self.view.bounds;
                NSURLRequest *request = [NSURLRequest requestWithURL:self.robotURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
                
                if (ud_isIOS8) {
                    WKWebView *intelligenceWeb = [[WKWebView alloc] initWithFrame:webViewRect];
                    intelligenceWeb.backgroundColor=[UIColor whiteColor];
                    [intelligenceWeb loadRequest:request];
                    
                    [self.view addSubview:intelligenceWeb];
                }
                else {
                    
                    UIWebView *intelligenceWeb = [[UIWebView alloc] initWithFrame:webViewRect];
                    intelligenceWeb.backgroundColor=[UIColor whiteColor];
                    [intelligenceWeb loadRequest:request];
                    
                    [self.view addSubview:intelligenceWeb];
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

//黑名单
- (void)showIsBlacklistedAlert {
    
    UdeskAlertController *blacklisted = [UdeskAlertController alertControllerWithTitle:nil message:getUDLocalizedString(@"udesk_alert_view_blocked_list") preferredStyle:UDAlertControllerStyleAlert];
    
    @udWeakify(self);
    [blacklisted addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
        @udStrongify(self);
        [self dismissChatViewController];
    }]];
    
    [blacklisted addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:nil]];
    [self presentViewController:blacklisted animated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
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

@end
