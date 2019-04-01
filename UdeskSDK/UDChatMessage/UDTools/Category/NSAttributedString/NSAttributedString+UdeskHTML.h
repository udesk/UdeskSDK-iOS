//
//  NSAttributedString+UdeskHTML.h
//  HTMLDemo
//
//  Created by xuchen on 2018/12/18.
//  Copyright © 2018 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (UdeskHTML)

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString customFont:(UIFont *)customFont;

@end
