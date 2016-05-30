//
//  UdeskGeneral.h
//  UdeskSDK
//
//  Created by xuchen on 15/12/21.
//  Copyright © 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskGeneral : NSObject

+ (instancetype)store;

/**
 *  获取文字Size(适配版本)
 *
 *  @param text   文字
 *  @param font   文字字体大小
 *  @param toSize 需要的大小
 *
 *  @return 文字的Size
 */
- (CGSize)textSize:(NSString *)text fontOfSize:(UIFont *)font ToSize:(CGSize)toSize;

@end
