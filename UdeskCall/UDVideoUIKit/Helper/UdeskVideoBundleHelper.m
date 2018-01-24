//
//  UdeskVideoBundleHelper.m
//  UdeskSDK
//
//  Created by xuchen on 2017/11/29.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVideoBundleHelper.h"
#import "UdeskVideoLanguageHelper.h"

@implementation UdeskVideoBundleHelper

NSString *UVCBundlePath(NSString *filename)
{
    
    NSBundle * libBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[UdeskVideoLanguageHelper class]] pathForResource:@"UdeskVideoBundle" ofType:@"bundle"]];
    
    if ( libBundle && filename ){
        
        NSString * s = [[libBundle resourcePath] stringByAppendingPathComponent : filename];
        
        return s;
    }
    
    return nil ;
}

NSString *UVCLocalizedString(NSString *key) {
    
    return [[UdeskVideoLanguageHelper shared] getStringForKey:key withTable:@"UdeskVideoLocalizable"];
}


@end
