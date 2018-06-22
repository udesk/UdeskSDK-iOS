//
//  UdeskBundleUtils.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBundleUtils.h"
#import "UdeskLanguageConfig.h"

@implementation UdeskBundleUtils

NSString *getUDBundlePath(NSString *filename) {
    
    NSBundle *libBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[UdeskLanguageConfig class]] pathForResource:@"UdeskBundle" ofType:@"bundle"]];
    
    if (libBundle && filename) {
        
        NSString *s = [[libBundle resourcePath] stringByAppendingPathComponent:filename];
        return s;
    }
    
    return nil;
}

NSString *getUDLocalizedString(NSString *key) {
    
    return [[UdeskLanguageConfig sharedConfig] getStringForKey:key withTable:@"UdeskLocalizable"];
}

@end
