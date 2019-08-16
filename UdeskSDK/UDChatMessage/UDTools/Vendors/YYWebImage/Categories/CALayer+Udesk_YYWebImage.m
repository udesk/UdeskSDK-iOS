//
//  CALayer+YYWebImage.m
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "CALayer+Udesk_YYWebImage.h"
#import "Udesk_YYWebImageOperation.h"
#import "Udesk_YYWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface Udesk_CALayer_YYWebImage : NSObject @end
@implementation Udesk_CALayer_YYWebImage @end


static int Udesk_YYWebImageSetterKey;

@implementation CALayer (Udesk_YYWebImage)

- (NSURL *)udesk_yy_imageURL {
    Udesk_YYWebImageSetter *setter = objc_getAssociatedObject(self, &Udesk_YYWebImageSetterKey);
    return setter.imageURL;
}

- (void)setUdesk_yy_imageURL:(NSURL *)imageURL {
    [self udesk_yy_setImageWithURL:imageURL
              placeholder:nil
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self udesk_yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:kNilOptions
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL options:(Udesk_YYWebImageOptions)options {
    [self udesk_yy_setImageWithURL:imageURL
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(Udesk_YYWebImageOptions)options
                completion:(Udesk_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(Udesk_YYWebImageOptions)options
                  progress:(Udesk_YYWebImageProgressBlock)progress
                 transform:(Udesk_YYWebImageTransformBlock)transform
                completion:(Udesk_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(Udesk_YYWebImageOptions)options
                   manager:(Udesk_YYWebImageManager *)manager
                  progress:(Udesk_YYWebImageProgressBlock)progress
                 transform:(Udesk_YYWebImageTransformBlock)transform
                completion:(Udesk_YYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [Udesk_YYWebImageManager sharedManager];
    
    
    Udesk_YYWebImageSetter *setter = objc_getAssociatedObject(self, &Udesk_YYWebImageSetterKey);
    if (!setter) {
        setter = [Udesk_YYWebImageSetter new];
        objc_setAssociatedObject(self, &Udesk_YYWebImageSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _udesk_yy_dispatch_sync_on_main_queue(^{
        if ((options & Udesk_YYWebImageOptionSetImageWithFadeAnimation) &&
            !(options & Udesk_YYWebImageOptionAvoidSetImage)) {
            [self removeAnimationForKey:Udesk_YYWebImageFadeAnimationKey];
        }
        
        if (!imageURL) {
            if (!(options & Udesk_YYWebImageOptionIgnorePlaceHolder)) {
                self.contents = (id)placeholder.CGImage;
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & Udesk_YYWebImageOptionUseNSURLCache) &&
            !(options & Udesk_YYWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:Udesk_YYImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & Udesk_YYWebImageOptionAvoidSetImage)) {
                self.contents = (id)imageFromMemory.CGImage;
            }
            if(completion) completion(imageFromMemory, imageURL, Udesk_YYWebImageFromMemoryCacheFast, Udesk_YYWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & Udesk_YYWebImageOptionIgnorePlaceHolder)) {
            self.contents = (id)placeholder.CGImage;
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([Udesk_YYWebImageSetter setterQueue], ^{
            Udesk_YYWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            Udesk_YYWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, Udesk_YYWebImageFromType from, Udesk_YYWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == Udesk_YYWebImageStageFinished || stage == Udesk_YYWebImageStageProgress) && image && !(options & Udesk_YYWebImageOptionAvoidSetImage);
                BOOL showFade = (options & Udesk_YYWebImageOptionSetImageWithFadeAnimation);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == Udesk_YYWebImageStageFinished ? Udesk_YYWebImageFadeTime : Udesk_YYWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self addAnimation:transition forKey:Udesk_YYWebImageFadeAnimationKey];
                        }
                        self.contents = (id)image.CGImage;
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, Udesk_YYWebImageFromNone, Udesk_YYWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
        
        
    });
}

- (void)udesk_yy_cancelCurrentImageRequest {
    Udesk_YYWebImageSetter *setter = objc_getAssociatedObject(self, &Udesk_YYWebImageSetterKey);
    if (setter) [setter cancel];
}

@end
