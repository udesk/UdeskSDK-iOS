//
//  UdeskContentController.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskContentController.h"
#import "UdeskSDKMacro.h"
#import "UdeskBundleUtils.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskManager.h"
#import "UdeskSDKConfig.h"
#import "UdeskTransitioningAnimation.h"

@interface UdeskContentController (){
    
    UILabel *_labelTitle;
    BOOL isLoadingFinished;
    UIWebView *htmlWebView;
    NSString *_htmlContent;

}

@end

@implementation UdeskContentController


- (instancetype)init
{
    self = [super init];
    if (self) {
        //隐藏标签栏
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UdeskSDKConfig customConfig].sdkStyle.tableViewBackGroundColor;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if ([UdeskSDKConfig customConfig].articleTitle) {
        self.title = [UdeskSDKConfig customConfig].articleTitle;
    }
    else {
        self.title = getUDLocalizedString(@"udesk_faq_details_title");
    }
    
    CGSize contentTitleSize = [UdeskStringSizeUtil textSize:self.articlesTitle withFont:[UIFont systemFontOfSize:17] withSize:CGSizeMake(UD_SCREEN_WIDTH, MAXFLOAT)];
    
    CGFloat faqContentY = self.navigationController.navigationBarHidden?64:0;
    _labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 12+faqContentY, UD_SCREEN_WIDTH-30, contentTitleSize.height)];
    _labelTitle.text = self.articlesTitle;
    _labelTitle.hidden = YES;
    _labelTitle.textColor = [UIColor blackColor];
    _labelTitle.numberOfLines = 0;
    [_labelTitle sizeToFit];
    [self.view addSubview:_labelTitle];
    
    [self initLoad];

    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
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
    
    if ([UdeskSDKConfig customConfig].presentingAnimation == UDTransiteAnimationTypePush) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.view.window.layer addAnimation:[UdeskTransitioningAnimation createDismissingTransiteAnimation:[UdeskSDKConfig customConfig].presentingAnimation] forKey:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

//加载数据
- (void)initLoad {
    
    [UdeskManager getFaqArticlesContent:self.articleId completion:^(id responseObject, NSError *error) {
        
        if (!error) {
            
            NSDictionary *contents = [responseObject objectForKey:@"contents"];
            
            NSString *content = [contents objectForKey:@"content"];
            _htmlContent = content;
            //加载html内容
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self loadHtmlContent:content baseUrl:[UdeskManager domain]];
            });
            
            _labelTitle.hidden = NO;
        }
    }];
    
}

- (void)loadHtmlContent:(NSString *)htmlString baseUrl:(NSString *)baseUrl {
    
    @try {
        
        CGFloat webY = _labelTitle.frame.origin.y+_labelTitle.frame.size.height+5;
        htmlWebView=[[UIWebView alloc] initWithFrame:CGRectMake(7, webY, UD_SCREEN_WIDTH-14, self.view.frame.size.height-webY)];
        htmlWebView.backgroundColor = [UIColor whiteColor];
        htmlWebView.delegate = self;
        NSString *newBaseURL = [NSString stringWithFormat:@"http://%@",baseUrl];
        
        [htmlWebView loadHTMLString:htmlString baseURL:[NSURL URLWithString:newBaseURL]];
        
        [self.view addSubview:htmlWebView];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    @try {
        
        for (UIView *_aView in [htmlWebView subviews])
        {
            if ([_aView isKindOfClass:[UIScrollView class]])
            {
                [(UIScrollView *)_aView setShowsVerticalScrollIndicator:NO];
                //右侧的滚动条
                [(UIScrollView *)_aView setShowsHorizontalScrollIndicator:NO];
                [(UIScrollView *)_aView setAlwaysBounceHorizontal:NO];//禁止左右滑动
                //下侧的滚动条
                for (UIView *_inScrollview in _aView.subviews)
                {
                    if ([_inScrollview isKindOfClass:[UIImageView class]])
                    {
                        _inScrollview.hidden = YES;  //上下滚动出边界时的黑色的图片
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        [[UIApplication sharedApplication] openURL:request.URL];
        
        return NO;
    }
    
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
}

@end
