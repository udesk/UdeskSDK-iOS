//
//  UdeskNetworkManager.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/18.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskNetworkManager.h"
#import "UdeskReachability.h"
#import "UdeskSDKMacro.h"

@interface UdeskNetworkManager()

/** 网络状态检测 */
@property (nonatomic, strong) UdeskReachability *reachability;
/** 网络切换 */
@property (nonatomic, assign) BOOL netWorkChange;

@end

@implementation UdeskNetworkManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udIMReachabilityChanged:) name:kUdeskReachabilityChangedNotification object:nil];
    }
    return self;
}

//开始检测
- (void)start {
    
    self.reachability = [UdeskReachability reachabilityWithHostName:@"www.baidu.com"];
    [self.reachability startNotifier];
}

//网络状态检测
- (void)udIMReachabilityChanged:(NSNotification *)note {
    
    NSDictionary *userInfo = note.userInfo;
    NSNumber *status = userInfo[kUdeskReachabilityNotificationStatusItem];
    if (!status || status == (id)kCFNull) return ;
    
    @udWeakify(self)
    switch (status.integerValue) {
        case UDReachableViaWiFi:
        case UDReachableViaWWAN:{
            
            @udStrongify(self);
            if (self.netWorkChange) {
                self.netWorkChange = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.connectBlock) {
                        self.connectBlock();
                    }
                });
            }
            break;
        }
            
        case UDNotReachable:{
            
            @udStrongify(self);
            if (!self.netWorkChange) {
                self.netWorkChange = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.disconnectBlock) {
                        self.disconnectBlock();
                    }
                });
            }
        }
            
        default:
            break;
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUdeskReachabilityChangedNotification object:nil];
}

@end
