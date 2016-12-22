//
//  UdeskTicketViewController.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UdeskSDKConfig.h"

@interface UdeskTicketViewController : UdeskBaseViewController <UIWebViewDelegate>

/**
 *  ticket webView
 */
@property (nonatomic,strong ) UIWebView *ticketWebView;



#pragma mark - 留言自定义url 重写get方法即可
@property (nonatomic ,copy) NSString *urlStr;

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config;

@end
