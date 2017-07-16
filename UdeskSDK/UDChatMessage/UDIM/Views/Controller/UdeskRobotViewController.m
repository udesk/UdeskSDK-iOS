//
//  UdeskRobotViewController.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskRobotViewController.h"
#import "UdeskChatViewController.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskFoundationMacro.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskManager.h"
#import "UdeskAlertController.h"
#import "UdeskUtils.h"
#import "UdeskLanguageTool.h"
#import "UdeskSDKManager.h"
#import "UdeskSDKShow.h"
#import "UdeskAgentMenuViewController.h"

@interface UdeskRobotViewController ()

@property (nonatomic, strong) UdeskSDKConfig *sdkConfig;
@property (nonatomic, strong) NSURL *robotURL;


@property (nonatomic, strong) UIWebView *sbWebView;

@end

@implementation UdeskRobotViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UdeskSDKConfig sharedConfig].sdkStyle.tableViewBackGroundColor;

    [UdeskManager createCustomerForRobot:^(BOOL success, NSError *error) {
        
        @try {

            if (success) {
                
                if (self.sdkSetting) {
                    if (!self.sdkSetting.enableAgent.boolValue) {
                        self.navigationItem.rightBarButtonItems = nil;
                    }
                }
                
                CGRect webViewRect = self.navigationController.navigationBarHidden?CGRectMake(0, 64, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-64):self.view.bounds;
                UIWebView *intelligenceWeb = [[UIWebView alloc] initWithFrame:webViewRect];
                intelligenceWeb.backgroundColor=[UIColor whiteColor];
                
                NSURL *ticketURL = self.robotURL;
                
                NSURLRequest *request = [NSURLRequest requestWithURL:ticketURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
                [intelligenceWeb loadRequest:request];
                
                [self.view addSubview:intelligenceWeb];
                
                self.sbWebView = intelligenceWeb;
            }
            else {
                
                NSDictionary *userInfo = error.userInfo;
                if ([userInfo objectForKey:@"isBlocked"]) {
                    
                    [self showIsBlacklistedAlert];
                }
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
    
    [blacklisted addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
        
    }]];
    
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

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config
                          withURL:(NSURL *)URL
                      withSetting:(UdeskSetting *)setting {

    self = [super init];
    if (self) {
        
        _sdkSetting = setting;
        _sdkConfig = config;
        
        //设置语言
        NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET];
        //默认是中文
        if (!tmp)
        {
            tmp = CNS;
        }
        
        NSString *language;
        if ([tmp isEqualToString:CNS]) {
            language = @"&language=zh-cn";
        }
        else {
            language = @"&language=en-us";
        }
        
        self.robotURL = [NSURL URLWithString:[URL.absoluteString stringByAppendingString:language]];
        
    }
    return self;

}

- (void)didSelectNavigationRightButton {
    
    @try {
        
        if (self.sdkSetting) {
            
            UdeskSDKShow *show = [[UdeskSDKShow alloc] initWithConfig:self.sdkConfig];
            
            //容错处理
            if (!self.sdkSetting.enableImGroup) {
                [self pushChatViewController:show];
                return;
            }
            
            if (self.sdkSetting.enableImGroup) {
                
                //查看是否有导航栏
                [UdeskManager getAgentNavigationMenu:^(id responseObject, NSError *error) {
                    
                    @try {
                        
                        //查看导航栏错误，直接进入聊天页面
                        if (error) {
                            [self pushChatViewController:show];
                            return ;
                        }
                        
                        if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                            
                            NSArray *result = [responseObject objectForKey:@"result"];
                            //有设置客服导航栏
                            if (result.count) {
                                //如果后台有配置
                                UdeskAgentMenuViewController *agentMenu = [[UdeskAgentMenuViewController alloc] initWithSDKConfig:_sdkConfig menuArray:result withSetting:self.sdkSetting];
                                
                                [show presentOnViewController:self udeskViewController:agentMenu transiteAnimation:UDTransiteAnimationTypePush completion:nil];
                            }
                            else {
                                //没有设置导航栏 直接进入聊天页面
                                [self pushChatViewController:show];
                            }
                        }
                    } @catch (NSException *exception) {
                        NSLog(@"%@",exception);
                    } @finally {
                    }
                }];
                
            }else{
                
                [self pushChatViewController:show];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)pushChatViewController:(UdeskSDKShow *)show {

    UdeskChatViewController *chat = [[UdeskChatViewController alloc] initWithSDKConfig:self.sdkConfig withSettings:self.sdkSetting];
    [show presentOnViewController:self udeskViewController:chat transiteAnimation:UDTransiteAnimationTypePush completion:nil];
}

@end
