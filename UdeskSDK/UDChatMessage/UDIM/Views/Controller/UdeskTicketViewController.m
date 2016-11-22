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

@interface UdeskTicketViewController ()<UIGestureRecognizerDelegate>

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
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if (_sdkConfig.ticketTitle) {
        self.title = _sdkConfig.ticketTitle;
    }
    else {
        self.title = getUDLocalizedString(@"udesk_leave_msg");
    }
    
    NSString *key = [UdeskManager key];
    NSString *domain = [UdeskManager domain];
    
    if (![UdeskTools isBlankString:key]||[UdeskTools isBlankString:domain]) {
        
        _ticketWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _ticketWebView.backgroundColor = [UIColor whiteColor];
        
        NSURL *ticketURL = [UdeskManager getSubmitTicketURL];
        
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
        
        ticketURL = [NSURL URLWithString:[ticketURL.absoluteString stringByAppendingString:language]];
        
        [_ticketWebView loadRequest:[NSURLRequest requestWithURL:ticketURL]];
        
        [self.view addSubview:_ticketWebView];
        
        [_ticketWebView stringByEvaluatingJavaScriptFromString:@"ticketCallBack()"];
    }

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
    //隐藏键盘
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
}

@end
