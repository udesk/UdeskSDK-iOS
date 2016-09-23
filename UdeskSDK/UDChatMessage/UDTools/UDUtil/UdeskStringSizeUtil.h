//
//  UdeskGeneral.h
//  UdeskSDK
//
//  Created by xuchen on 15/12/21.
//  Copyright © 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskStringSizeUtil : NSObject

+ (CGSize)textSize:(NSString *)text withFont:(UIFont *)font withSize:(CGSize)size;

+ (float)getAttributedStringHeightWithString:(NSString *)text
                                  WidthValue:(float)width
                                        font:(UIFont*)font;

+ (CGFloat)getHeightForAttributedText:(NSAttributedString *)attributedText
                            textWidth:(CGFloat)textWidth;

+ (CGFloat)getWidthForAttributedText:(NSAttributedString *)attributedText
                          textHeight:(CGFloat)textHeight;

@end
