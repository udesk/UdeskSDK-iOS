//
//  YYWebImage.h
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

#if __has_include(<YYWebImage/YYWebImage.h>)
FOUNDATION_EXPORT double YYWebImageVersionNumber;
FOUNDATION_EXPORT const unsigned char YYWebImageVersionString[];
#import <YYWebImage/Udesk_YYImageCache.h>
#import <YYWebImage/Udesk_YYWebImageOperation.h>
#import <YYWebImage/Udesk_YYWebImageManager.h>
#import <YYWebImage/UIImage+YYWebImage.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIButton+YYWebImage.h>
#import <YYWebImage/CALayer+YYWebImage.h>
#import <YYWebImage/MKAnnotationView+YYWebImage.h>
#else
#import "Udesk_YYImageCache.h"
#import "Udesk_YYWebImageOperation.h"
#import "Udesk_YYWebImageManager.h"
#import "UIImage+YYWebImage.h"
#import "UIImageView+YYWebImage.h"
#import "UIButton+YYWebImage.h"
#import "CALayer+YYWebImage.h"
#import "MKAnnotationView+YYWebImage.h"
#endif

#if __has_include(<YYImage/YYImage.h>)
#import <YYImage/Udesk_YYImage.h>
#elif __has_include(<YYWebImage/YYImage.h>)
#import <YYWebImage/Udesk_YYImage.h>
#import <YYWebImage/Udesk_YYFrameImage.h>
#import <YYWebImage/Udesk_YYSpriteSheetImage.h>
#import <YYWebImage/Udesk_YYImageCoder.h>
#import <YYWebImage/Udesk_YYAnimatedImageView.h>
#else
#import "Udesk_YYImage.h"
#import "Udesk_YYFrameImage.h"
#import "Udesk_YYSpriteSheetImage.h"
#import "Udesk_YYImageCoder.h"
#import "Udesk_YYAnimatedImageView.h"
#endif

#if __has_include(<YYCache/YYCache.h>)
#import <YYCache/Udesk_YYCache.h>
#elif __has_include(<YYWebImage/YYCache.h>)
#import <YYWebImage/Udesk_YYCache.h>
#import <YYWebImage/Udesk_YYMemoryCache.h>
#import <YYWebImage/Udesk_YYDiskCache.h>
#import <YYWebImage/Udesk_YYKVStorage.h>
#else
#import "Udesk_YYCache.h"
#import "Udesk_YYMemoryCache.h"
#import "Udesk_YYDiskCache.h"
#import "Udesk_YYKVStorage.h"
#endif

