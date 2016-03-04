//
//  UDCustomerDataController.m
//  UdeskSDK
//
//  Created by xuchen on 16/3/4.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDCustomerDataController.h"
#import "UDManager.h"

@implementation UDCustomerDataController

+ (instancetype)store {

    return [[self alloc] init];
}

- (void)requestCustomerDataWithCallback:(UDCustomerDataCallBack)callback {

    [UDManager getCustomerLoginInfo:^(NSDictionary *loginInfoDic, NSError *error) {
        
        
        
    }];
}

@end
