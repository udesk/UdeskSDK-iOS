//
//  UdeskSDKShow.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/26.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskSDKConfig.h"

@interface UdeskSDKShow : NSObject

- (instancetype)initWithConfig:(UdeskSDKConfig *)sdkConfig;

- (void)presentOnViewController:(UIViewController *)rootViewController
            udeskViewController:(id)udeskViewController
              transiteAnimation:(UDTransiteAnimationType)animation
                     completion:(void (^)(void))completion;

@end
