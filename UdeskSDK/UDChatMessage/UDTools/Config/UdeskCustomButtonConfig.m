//
//  UdeskCustomButtonConfig.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/21.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskCustomButtonConfig.h"

@implementation UdeskCustomButtonConfig

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image type:(UdeskCustomButtonConfigType)type clickBlock:(CustomButtonClickBlock)clickBlock
{
    self = [super init];
    if (self) {
        
        _title = title;
        _image = image;
        _type = type;
        _clickBlock = clickBlock;
    }
    return self;
}

@end
