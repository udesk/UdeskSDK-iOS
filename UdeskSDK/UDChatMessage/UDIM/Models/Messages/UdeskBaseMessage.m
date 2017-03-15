//
//  UdeskBaseMessage.m
//  UdeskSDK
//
//  Created by xuchen on 16/9/1.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseMessage.h"

@implementation UdeskBaseMessage

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {

    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
