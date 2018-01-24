//
//  UdeskVideoBundleHelper.h
//  UdeskSDK
//
//  Created by xuchen on 2017/11/29.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskVideoBundleHelper : NSObject

#define UDBUNDLE_NAME @ "UdeskVideoBundle.bundle"

#define UDBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: UDBUNDLE_NAME]

#define UDBUNDLE [NSBundle bundleWithPath: UDBUNDLE_PATH]

NSString *UVCBundlePath(NSString *filename);

NSString *UVCLocalizedString(NSString *key);


@end
