//
//  UdeskUtils.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskUtils.h"
#import "UdeskLanguageTool.h"

@implementation UdeskUtils

NSString* getUDBundlePath( NSString * filename)
{
    
    NSBundle * libBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[UdeskLanguageTool class]] pathForResource:@"UdeskBundle" ofType:@"bundle"]];
    
    if ( libBundle && filename ){
        
        NSString * s=[[libBundle resourcePath] stringByAppendingPathComponent : filename];
        
        return s;
    }
    
    return nil ;
}

NSString * getUDLocalizedString( NSString * key) {
    
    return [[UdeskLanguageTool sharedInstance] getStringForKey:key withTable:@"UdeskLocalizable"];
}

@end
