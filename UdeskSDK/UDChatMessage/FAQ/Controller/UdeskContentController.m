//
//  UdeskContentController.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskContentController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "UdeskGeneral.h"
#import "UdeskManager.h"

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
    
    [self.udNavView changeTitle:getUDLocalizedString(@"问题详情") withColor:UdeskUIConfig.articleContentTitleColor];
    [self setBackButtonColor:UdeskUIConfig.articleBackButtonColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize contentTitleSize = [UdeskGeneral.store textSize:self.ArticlesTitle fontOfSize:[UIFont systemFontOfSize:17] ToSize:CGSizeMake(UD_SCREEN_WIDTH, MAXFLOAT)];
    
    CGFloat faqContentY = self.navigationController.navigationBarHidden?64:0;
    _labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 12+faqContentY, UD_SCREEN_WIDTH-30, contentTitleSize.height)];
    _labelTitle.text = self.ArticlesTitle;
    _labelTitle.hidden = YES;
    _labelTitle.textColor = [UIColor blackColor];
    _labelTitle.numberOfLines = 0;
    [_labelTitle sizeToFit];
    [self.view addSubview:_labelTitle];
    
    [self initLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //设置导航栏颜色
    [self setNavigationBarBackGroundColor:UdeskUIConfig.articleContentNavigationColor];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = UdeskUIConfig.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = UdeskUIConfig.oneSelfNavcigtionColor;
    }
    
}

- (void)backButtonAction {

    [super backButtonAction];
    [self.navigationController popViewControllerAnimated:YES];
}

//加载数据
- (void)initLoad {
    
    [UdeskManager getFaqArticlesContent:self.Article_Id completion:^(id responseObject, NSError *error) {
        
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
    
    CGFloat webY = _labelTitle.frame.origin.y+_labelTitle.frame.size.height+5;
    htmlWebView=[[UIWebView alloc] initWithFrame:CGRectMake(7, webY, UD_SCREEN_WIDTH-14, self.view.frame.size.height-webY)];
    [htmlWebView setScalesPageToFit:YES];
    htmlWebView.backgroundColor = [UIColor whiteColor];
    htmlWebView.delegate = self;
    NSString *newBaseURL = [NSString stringWithFormat:@"http://%@",baseUrl];
    
    NSString *jsString = [NSString stringWithFormat:@"<html> \n"
                          "<head> \n"
                          "<style type=\"text/css\"> \n"
                          "body {font-size: %d;}\n"
                          "</style> \n"
                          "</head> \n"
                          "</html>", 47];
    
    NSString *newString = [NSString stringWithFormat:@"%@%@",jsString,htmlString];
    
    [htmlWebView loadHTMLString:newString baseURL:[NSURL URLWithString:newBaseURL]];
    
    [self.view addSubview:htmlWebView];
    
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
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
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        [[UIApplication sharedApplication] openURL:request.URL];
        
        return NO;
    }
    
    return YES;
}

@end
