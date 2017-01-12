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
#import "UdeskSDKConfig.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskLanguageTool.h"
#import "UDStatus.h"

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

    self.view.backgroundColor = _sdkConfig.sdkStyle.tableViewBackGroundColor;
    

    
    if (_sdkConfig.ticketTitle) {
        self.title = _sdkConfig.ticketTitle;
    }
    else {
        self.title = getUDLocalizedString(@"udesk_leave_msg");
    }
    
    NSString *key = [UdeskManager key];
    NSString *domain = [UdeskManager domain];
    
    if (![UdeskTools isBlankString:key]||[UdeskTools isBlankString:domain]) {
        
        CGRect webViewRect = self.navigationController.navigationBarHidden?CGRectMake(0, 64, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-64):self.view.bounds;
        _ticketWebView = [[UIWebView alloc] initWithFrame:webViewRect];
        _ticketWebView.backgroundColor = [UIColor whiteColor];

        NSURL *ticketURL = nil;
        if (_sdkConfig.url) {
            ticketURL = [NSURL URLWithString:_sdkConfig.url];
        }else{
            ticketURL =  [UdeskManager getSubmitTicketURL];
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
        }


        [_ticketWebView loadRequest:[NSURLRequest requestWithURL:ticketURL]];
        
        [self.view addSubview:_ticketWebView];
        
        [_ticketWebView stringByEvaluatingJavaScriptFromString:@"ticketCallBack()"];
    }

}

@end
