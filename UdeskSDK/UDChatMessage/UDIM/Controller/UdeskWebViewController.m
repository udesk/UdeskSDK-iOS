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

@interface UdeskWebViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *udWkWebView;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) NSURL *URL;

@end

@implementation UdeskWebViewController

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super initWithSDKConfig:[UdeskSDKConfig customConfig] setting:nil];
    if (self) {
        _URL = URL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat spacing = 64;
    if (udIsIPhoneXSeries) {
        spacing += 34;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:45];
    
    _udWkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _udWkWebView.backgroundColor = [UIColor whiteColor];
    _udWkWebView.udHeight -= spacing;
    _udWkWebView.UIDelegate = self;
    _udWkWebView.navigationDelegate = self;
    [_udWkWebView loadRequest:request];
    [self.view addSubview:_udWkWebView];
    
    //进度条
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, 10)];
    _progressView.progress = 0.1f;
    _progressView.trackTintColor = [UdeskSDKConfig customConfig].sdkStyle.webViewProgressTrackTintColor;
    _progressView.tintColor = [UdeskSDKConfig customConfig].sdkStyle.webViewProgressTintColor;
    [self.view addSubview:_progressView];
    
    [self.udWkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setProgress:self.udWkWebView.estimatedProgress animated:YES];
        
        if(self.udWkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
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
    
    if (_udWkWebView) {
        _udWkWebView.udHeight = (UD_SCREEN_HEIGHT == keyboardF.origin.y) ? CGRectGetHeight(self.view.bounds) : keyboardF.origin.y;
    }
}

- (void)dealloc {
    
    if (self.udWkWebView) {
        [self.udWkWebView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
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
