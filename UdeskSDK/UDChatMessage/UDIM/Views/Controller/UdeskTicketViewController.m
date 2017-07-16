//
//  UdeskTicketViewController.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskTicketViewController.h"
#import "UdeskManager.h"
#import "UdeskUtils.h"
#import "UdeskTools.h"
#import "UdeskFoundationMacro.h"
#import "UdeskSDKConfig.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskLanguageTool.h"
#import "UdeskCustomNavigation.h"
#import "UdeskViewExt.h"

@interface UdeskTicketViewController () 

@property (nonatomic, strong) UdeskSDKConfig *sdkConfig;

@end

@implementation UdeskTicketViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config
{
    self = [super init];
    if (self) {
        _sdkConfig = config;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    @try {
        
        self.view.backgroundColor = _sdkConfig.sdkStyle.tableViewBackGroundColor;
        
        UdeskCustomNavigation *customNav = [[UdeskCustomNavigation alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, 64)];
        if (_sdkConfig.sdkStyle.navigationColor) {
            customNav.backgroundColor = _sdkConfig.sdkStyle.navigationColor;
        }
        if (_sdkConfig.sdkStyle.titleColor) {
            customNav.titleLabel.textColor = _sdkConfig.sdkStyle.titleColor;
        }
        if (_sdkConfig.sdkStyle.navBackButtonColor) {
            [customNav.closeButton setTitleColor:_sdkConfig.sdkStyle.navBackButtonColor forState:UIControlStateNormal];
        }
        
        if (_sdkConfig.ticketTitle) {
            customNav.titleLabel.text = _sdkConfig.ticketTitle;
        }
        else {
            customNav.titleLabel.text = getUDLocalizedString(@"udesk_leave_msg");
        }
        
        [self.view addSubview:customNav];
        
        customNav.closeViewController = ^(){
            [super dismissViewControllerAnimated:YES completion:nil];
        };
        
        
        NSString *key = [UdeskManager key];
        NSString *domain = [UdeskManager domain];
        
        if (![UdeskTools isBlankString:key]||[UdeskTools isBlankString:domain]) {
            
            _ticketWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, customNav.ud_bottom, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-customNav.ud_bottom)];
            _ticketWebView.backgroundColor = [UIColor whiteColor];
            
            NSURL *ticketURL =  [UdeskManager getSubmitTicketURL];
            // 设置语言
            NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET];
            // 默认是中文
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
            
            ticketURL = [NSURL URLWithString:[ticketURL.absoluteString stringByAppendingString:language]];
            
            [_ticketWebView loadRequest:[NSURLRequest requestWithURL:ticketURL]];
            
            [self.view addSubview:_ticketWebView];
            
            [_ticketWebView stringByEvaluatingJavaScriptFromString:@"ticketCallBack()"];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if ( self.presentedViewController)
    {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
}

@end
