//
//  NSURLRequest+SSL.m
//  UdeskSDK
//
//  Created by xuchen on 2018/2/7.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "NSURLRequest+SSL.h"

@implementation NSURLRequest (SSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host {
    return YES;
}



+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host {
    
}

@end
