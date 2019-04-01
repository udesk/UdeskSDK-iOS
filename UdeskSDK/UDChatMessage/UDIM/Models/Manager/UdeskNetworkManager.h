//
//  UdeskNetworkManager.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/18.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskNetworkManager : NSObject

@property (nonatomic, copy) void(^connectBlock)(void);
@property (nonatomic, copy) void(^disconnectBlock)(void);

//开始检测
- (void)start;

@end
