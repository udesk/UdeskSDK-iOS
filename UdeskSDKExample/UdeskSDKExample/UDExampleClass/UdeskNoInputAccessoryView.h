//
//  UdeskNoInputAccessoryView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/6/19.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

@interface UdeskNoInputAccessoryView : NSObject

- (void)removeInputAccessoryViewFromWKWebView:(WKWebView *)webView;

@end
