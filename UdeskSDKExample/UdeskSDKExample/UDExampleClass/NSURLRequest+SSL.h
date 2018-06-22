//
//  NSURLRequest+SSL.h
//  UdeskSDK
//
//  Created by xuchen on 2018/2/7.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (SSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;

@end
