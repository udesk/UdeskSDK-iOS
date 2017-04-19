//
//  UdeskGeneral.m
//  UdeskSDK
//
//  Created by Udesk on 15/12/21.
//  Copyright © 2015年 Udesk. All rights reserved.
//

#import "UdeskStringSizeUtil.h"
#import "UdeskFoundationMacro.h"
#import <CoreText/CoreText.h>
#import "UdeskTools.h"

@implementation UdeskStringSizeUtil

+ (CGFloat)getHeightForAttributedText:(NSAttributedString *)attributedText
                            textWidth:(CGFloat)textWidth
{
    if ([UdeskTools isBlankString:attributedText.string]) {
        return 50;
    }
    
    CGSize constraint = CGSizeMake(textWidth , CGFLOAT_MAX);
    CGSize title_size;
    CGFloat totalHeight;
    title_size = [attributedText boundingRectWithSize:constraint
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              context:nil].size;
    
    totalHeight = ceil(title_size.height);
    
    return totalHeight;
}

+ (CGSize)getSizeForAttributedText:(NSAttributedString *)attributedText
                         textWidth:(CGFloat)textWidth
{
    if ([UdeskTools isBlankString:attributedText.string]) {
        return CGSizeMake(50, 50);
    }
    
    CGSize constraint = CGSizeMake(textWidth , CGFLOAT_MAX);
    
    CGRect stringRect = [attributedText boundingRectWithSize:constraint
                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                     context:nil];
    
    stringRect.size.height = stringRect.size.height < 30 ? stringRect.size.height = 18 : stringRect.size.height;
    
    return CGRectIntegral(stringRect).size;
}

+ (CGSize)textSize:(NSString *)text withFont:(UIFont *)font withSize:(CGSize)size {

    CGSize newSize = CGSizeMake(50, 50);
    
    if (![UdeskTools isBlankString:text]) {
        
        if (font) {
            
            if (ud_isIOS6) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                newSize = [text sizeWithFont:font constrainedToSize:size];
#pragma clang diagnostic pop
            } else {
                
                CGRect stringRect = [text boundingRectWithSize:CGSizeMake(size.width, CGFLOAT_MAX)
                                                       options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                    attributes:@{ NSFontAttributeName : font }
                                                       context:nil];
                
                CGSize stringSize = CGRectIntegral(stringRect).size;
                
                newSize = stringSize;
            }
        }
    }
    
    return newSize;
}

@end
