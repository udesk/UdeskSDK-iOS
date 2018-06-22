//
//  UdeskBundleUtils.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskBundleUtils : NSObject

//文件地址
NSString *getUDBundlePath(NSString *filename);
//多语言
NSString *getUDLocalizedString(NSString *key);

@end
