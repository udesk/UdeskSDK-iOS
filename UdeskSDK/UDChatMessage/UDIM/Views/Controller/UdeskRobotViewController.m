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
#import "UdeskAlertController.h"
#import "UdeskUtils.h"
#import "UdeskLanguageTool.h"
#import "UdeskSDKManager.h"

@interface UdeskRobotViewController ()<UIGestureRecognizerDelegate>

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
            
            //这个函数只有在createServerCustomerCompletion回调成功之后才有用
            if (![UdeskManager supportTransfer]) {
                self.navigationItem.rightBarButtonItems = nil;
            }
    
            CGRect webViewRect = self.navigationController.navigationBarHidden?CGRectMake(0, 64, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-64):self.view.bounds;
            UIWebView *intelligenceWeb = [[UIWebView alloc] initWithFrame:webViewRect];
            intelligenceWeb.backgroundColor=[UIColor whiteColor];
            
            NSURL *ticketURL = self.robotURL;
    
            NSURLRequest *request = [NSURLRequest requestWithURL:ticketURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
            [intelligenceWeb loadRequest:request];
            
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
    popRecognizer.delegate = self;
    [self.view addGestureRecognizer:popRecognizer];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}
//滑动返回
- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat xPercent = translation.x / CGRectGetWidth(self.view.bounds) * 0.9;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [UdeskTransitioningAnimation setInteractive:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [UdeskTransitioningAnimation updateInteractiveTransition:xPercent];
            break;
        default:
            if (xPercent < .45) {
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
            [self dismissViewControllerAnimated:YES completion:^{
            }];
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

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    if (_sdkConfig.transferToMenu) {
        UdeskSDKManager *sdk = [[UdeskSDKManager alloc] initWithSDKStyle:_sdkConfig.sdkStyle];
        [sdk pushUdeskViewControllerWithType:UdeskMenu viewController:self completion:nil];
    }
    else {
        
        UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:_sdkConfig.sdkStyle];
        [chatViewManager pushUdeskViewControllerWithType:UdeskIM viewController:self completion:^{
        }];
    }
}

@end
