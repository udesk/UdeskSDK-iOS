//
//  UdeskImageUtil.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskImageUtil : NSObject

+ (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(CGSize)maxFileSize;

+ (UIImage *)resizeImage:(UIImage *)image maxSize:(CGSize)size;
+ (UIImage *)fixrotation:(UIImage *)image;

@end
