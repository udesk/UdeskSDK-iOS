//
//  UdeskVideoUtil.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/16.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UdeskVideoUtil : NSObject

//获取优化后的视频转向信息
+ (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset;
//视频时间
+ (NSString *)videoTimeFromDurationSecond:(NSInteger)duration;

+ (NSInteger)videoDurationWithURL:(NSString *)url;
+ (UIImage *)videoPreViewImageWithURL:(NSString *)url;
+ (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
+ (UIImage *)convertSampleBufferRefToUIImage:(CMSampleBufferRef)sampleBufferRef;

@end
