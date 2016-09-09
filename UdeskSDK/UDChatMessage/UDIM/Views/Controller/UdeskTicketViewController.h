//
//  UdeskTicketViewController.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskSDKConfig.h"

@interface UdeskTicketViewController : UIViewController<UIWebViewDelegate>

/**
 *  ticket webView
 */
@property (nonatomic,strong ) UIWebView *ticketWebView;

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config;

@end
