//
//  UdeskTicketViewController.h
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskBaseViewController.h"

@interface UdeskTicketViewController : UdeskBaseViewController <UIWebViewDelegate>

/**
 *  ticket webView
 */
@property (nonatomic,strong ) UIWebView *ticketWebView;


- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config;

@end
