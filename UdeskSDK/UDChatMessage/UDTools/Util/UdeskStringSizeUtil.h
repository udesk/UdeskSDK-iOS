//
//  UdeskGeneral.h
//  UdeskSDK
//
//  Created by Udesk on 15/12/21.
//  Copyright © 2015年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskStringSizeUtil : NSObject

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font size:(CGSize)size;
+ (CGSize)sizeWithAttributedText:(NSAttributedString *)attributedText size:(CGSize)size;

@end
