//
//  UdeskBaseMessage.m
//  UdeskSDK
//
//  Created by Udesk on 16/9/1.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@implementation UdeskBaseMessage

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {

    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
