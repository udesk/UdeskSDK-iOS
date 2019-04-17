//
//  UdeskGeneral.m
//  UdeskSDK
//
//  Created by Udesk on 15/12/21.
//  Copyright © 2015年 Udesk. All rights reserved.
//

#import "UdeskStringSizeUtil.h"
#import "UdeskSDKMacro.h"
#import "UdeskSDKUtil.h"

@implementation UdeskStringSizeUtil

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font size:(CGSize)size {

    CGSize newSize = CGSizeMake(50, 50);
    
    if (![UdeskSDKUtil isBlankString:text]) {
        
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

+ (CGSize)sizeWithAttributedText:(NSAttributedString *)attributedText size:(CGSize)size {
    
    if ([UdeskSDKUtil isBlankString:attributedText.string]) {
        return CGSizeMake(100, 50);
    }
    
    CGSize constraint = CGSizeMake(size.width , size.height);
    
    CGRect stringRect = [attributedText boundingRectWithSize:constraint
                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                     context:nil];
    
    stringRect.size.height = stringRect.size.height < 30 ? stringRect.size.height = 20 : stringRect.size.height;
    
    return CGSizeMake(stringRect.size.width, stringRect.size.height+2);
}

@end
