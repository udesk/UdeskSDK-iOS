//
//  UDCustomerDataController.h
//  UdeskSDK
//
//  Created by xuchen on 16/3/4.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UDCustomerDataCallBack) (id responseObject, NSError *error);

@interface UDCustomerDataController : NSObject

+ (instancetype)store;

- (void)requestCustomerDataWithCallback:(UDCustomerDataCallBack)callback;

@end
