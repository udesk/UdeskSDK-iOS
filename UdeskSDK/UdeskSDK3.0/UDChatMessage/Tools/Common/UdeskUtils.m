//
//  UdeskUtils.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskUtils.h"

@implementation UdeskUtils

NSString* getMyBundlePath( NSString * filename)
{
    
    NSBundle * libBundle = MYBUNDLE ;
    
    if ( libBundle && filename ){
        
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        
        return s;
        
    }
    
    return nil ;
}

@end
