//
//  UdeskRobotViewController.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskRobotViewController.h"
#import "UdeskChatViewController.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskFoundationMacro.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskManager.h"
#import "UdeskSDKShow.h"
#import "UdeskAlertController.h"
#import "UdeskUtils.h"
#import "UdeskLanguageTool.h"

@interface UdeskRobotViewController ()

@property (nonatomic, strong) UdeskSDKConfig *sdkConfig;
@property (nonatomic, strong) NSURL *robotURL;

@end

@implementation UdeskRobotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    self.view.backgroundColor = [UdeskSDKConfig sharedConfig].sdkStyle.tableViewBackGroundColor;

    [UdeskManager createServerCustomerCompletion:^(BOOL success, NSError *error) {
        
        if (success) {
            
            CGRect webViewRect = self.navigationController.navigationBarHidden?CGRectMake(0, 64, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-64):self.view.bounds;
            UIWebView *intelligenceWeb = [[UIWebView alloc] initWithFrame:webViewRect];
            intelligenceWeb.backgroundColor=[UIColor whiteColor];
            
            NSURL *ticketURL = self.robotURL;
            
            [intelligenceWeb loadRequest:[NSURLRequest requestWithURL:ticketURL]];
            
            [self.view addSubview:intelligenceWeb];
        }
        else {
        
            NSDictionary *userInfo = error.userInfo;
            if ([userInfo objectForKey:@"isBlocked"]) {
             
                [self showIsBlacklistedAlert];
            }
        }
        
    }];
    
    //设置返回按钮文字（在A控制器写代码）
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] init];
    barButtonItem.title = getUDLocalizedString(@"udesk_back");
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
}
//滑动返回
- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat xPercent = translation.x / CGRectGetWidth(self.view.bounds) * 0.7;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [UdeskTransitioningAnimation setInteractive:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [UdeskTransitioningAnimation updateInteractiveTransition:xPercent];
            break;
        default:
            if (xPercent < .25) {
                [UdeskTransitioningAnimation cancelInteractiveTransition];
            } else {
                [UdeskTransitioningAnimation finishInteractiveTransition];
            }
            [UdeskTransitioningAnimation setInteractive:NO];
            break;
    }
    
}
//点击返回
- (void)dismissChatViewController {
    
    if ([UdeskSDKConfig sharedConfig].presentingAnimation == UDTransiteAnimationTypePush) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.view.window.layer addAnimation:[UdeskTransitioningAnimation createDismissingTransiteAnimation:[UdeskSDKConfig sharedConfig].presentingAnimation] forKey:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

//黑名单
- (void)showIsBlacklistedAlert {
    
    UdeskAlertController *blacklisted = [UdeskAlertController alertWithTitle:nil message:getUDLocalizedString(@"udesk_alert_view_blocked_list")];
    
    @udWeakify(self);
    [blacklisted addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") handler:^(UdeskAlertAction * _Nonnull action) {
        @udStrongify(self);
        [self dismissChatViewController];
    }]];
    
    [blacklisted addCloseActionWithTitle:getUDLocalizedString(@"udesk_close") Handler:nil];
    
    [blacklisted showWithSender:nil controller:nil animated:YES completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
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

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config withURL:(NSURL *)URL {

    self = [super init];
    if (self) {
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
        
        _robotURL = [NSURL URLWithString:[URL.absoluteString stringByAppendingString:language]];
        
    }
    return self;
}

- (void)didSelectNavigationRightButton {

    UdeskChatViewController *chat = [[UdeskChatViewController alloc] initWithSDKConfig:_sdkConfig];
    UdeskSDKShow *show = [[UdeskSDKShow alloc] initWithConfig:_sdkConfig];
    [show presentOnViewController:self udeskViewController:chat transiteAnimation:UDTransiteAnimationTypePush];
}

@end
