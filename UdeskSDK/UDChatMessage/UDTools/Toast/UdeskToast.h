//
//  UdeskToast.h
//  UdeskSDK
//
//  Created by xuchen on 2017/1/13.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskToast : NSObject

+ (void)showToast:(NSString*)message duration:(NSTimeInterval)interval window:(UIView*)window;

@end
