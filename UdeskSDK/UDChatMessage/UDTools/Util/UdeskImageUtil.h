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
//压缩图片到指定size
+ (UIImage *)imageResize:(UIImage *)image toSize:(CGSize)toSize;
//压缩
+ (UIImage *)imageWithOriginalImage:(UIImage *)image;
//压缩图片 压缩质量
+ (UIImage *)imageWithOriginalImage:(UIImage *)image quality:(CGFloat)quality;
// 计算图片实际大小
+ (CGSize)udImageSize:(UIImage *)image;
//通过图片Data数据第一个字节 来获取图片扩展名
+ (NSString *)contentTypeForImageData:(NSData *)data;

@end
