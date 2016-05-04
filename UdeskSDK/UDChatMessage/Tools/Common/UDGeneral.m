//
//  UDGeneral.m
//  UdeskSDK
//
//  Created by xuchen on 15/12/21.
//  Copyright © 2015年 xuchen. All rights reserved.
//

#import "UDGeneral.h"
#import "UDFoundationMacro.h"

@implementation UDGeneral

+ (instancetype)store {

    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
 
    }
    return self;
}

- (CGSize)textSize:(NSString *)text fontOfSize:(UIFont *)font ToSize:(CGSize)toSize {

    CGSize size;
    
    if (ud_isIOS6) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [text sizeWithFont:font constrainedToSize:toSize];
#pragma clang diagnostic pop
    } else {
        size = [text boundingRectWithSize:toSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    }
    
    return size;

}

@end
