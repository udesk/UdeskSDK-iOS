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

//修改图片转向
+ (UIImage *)fixOrientation:(UIImage *)image;
//压缩
+ (UIImage *)imageWithOriginalImage:(UIImage *)image;
//压缩图片 压缩质量
+ (UIImage *)imageWithOriginalImage:(UIImage *)image quality:(CGFloat)quality;
//压缩图片
+ (UIImage *)imageWithOriginalImage:(UIImage *)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
//压缩图片到指定size
+ (UIImage *)imageResize:(UIImage *)image toSize:(CGSize)toSize;
// 计算图片实际大小
+ (CGSize)udImageSize:(UIImage *)image;
// 获取图片的类型
+ (NSString *)contentTypeForImageData:(NSData *)data;

@end
