//
//  UIButton+YYWebImage.m
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIButton+YYWebImage.h"
#import "Udesk_YYWebImageOperation.h"
#import "Udesk_YYWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface Udesk_UIButton_YYWebImage : NSObject @end
@implementation Udesk_UIButton_YYWebImage @end

static inline NSNumber *UIControlStateSingle(UIControlState state) {
    if (state & UIControlStateHighlighted) return @(UIControlStateHighlighted);
    if (state & UIControlStateDisabled) return @(UIControlStateDisabled);
    if (state & UIControlStateSelected) return @(UIControlStateSelected);
    return @(UIControlStateNormal);
}

static inline NSArray *UIControlStateMulti(UIControlState state) {
    NSMutableArray *array = [NSMutableArray new];
    if (state & UIControlStateHighlighted) [array addObject:@(UIControlStateHighlighted)];
    if (state & UIControlStateDisabled) [array addObject:@(UIControlStateDisabled)];
    if (state & UIControlStateSelected) [array addObject:@(UIControlStateSelected)];
    if ((state & 0xFF) == 0) [array addObject:@(UIControlStateNormal)];
    return array;
}

static int Udesk_YYWebImageSetterKey;
static int _YYWebImageBackgroundSetterKey;


@interface Udesk_YYWebImageSetterDicForButton : NSObject
- (Udesk_YYWebImageSetter *)setterForState:(NSNumber *)state;
- (Udesk_YYWebImageSetter *)lazySetterForState:(NSNumber *)state;
@end

@implementation Udesk_YYWebImageSetterDicForButton {
    NSMutableDictionary *_dic;
    dispatch_semaphore_t _lock;
}
- (instancetype)init {
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    _dic = [NSMutableDictionary new];
    return self;
}
- (Udesk_YYWebImageSetter *)setterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    Udesk_YYWebImageSetter *setter = _dic[state];
    dispatch_semaphore_signal(_lock);
    return setter;
    
}
- (Udesk_YYWebImageSetter *)lazySetterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    Udesk_YYWebImageSetter *setter = _dic[state];
    if (!setter) {
        setter = [Udesk_YYWebImageSetter new];
        _dic[state] = setter;
    }
    dispatch_semaphore_signal(_lock);
    return setter;
}
@end


@implementation UIButton (YYWebImage)

#pragma mark - image

- (void)_yy_setImageWithURL:(NSURL *)imageURL
             forSingleState:(NSNumber *)state
                placeholder:(UIImage *)placeholder
                    options:(YYWebImageOptions)options
                    manager:(Udesk_YYWebImageManager *)manager
                   progress:(YYWebImageProgressBlock)progress
                  transform:(YYWebImageTransformBlock)transform
                 completion:(YYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [Udesk_YYWebImageManager sharedManager];
    
    Udesk_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &Udesk_YYWebImageSetterKey);
    if (!dic) {
        dic = [Udesk_YYWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &Udesk_YYWebImageSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    Udesk_YYWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _yy_dispatch_sync_on_main_queue(^{
        if (!imageURL) {
            if (!(options & YYWebImageOptionIgnorePlaceHolder)) {
                [self setImage:placeholder forState:state.integerValue];
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & YYWebImageOptionUseNSURLCache) &&
            !(options & YYWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:YYImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & YYWebImageOptionAvoidSetImage)) {
                [self setImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, YYWebImageFromMemoryCacheFast, YYWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & YYWebImageOptionIgnorePlaceHolder)) {
            [self setImage:placeholder forState:state.integerValue];
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([Udesk_YYWebImageSetter setterQueue], ^{
            YYWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            YYWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == YYWebImageStageFinished || stage == YYWebImageStageProgress) && image && !(options & YYWebImageOptionAvoidSetImage);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setImage:image forState:state.integerValue];
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, YYWebImageFromNone, YYWebImageStageCancelled, nil);
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

- (void)_yy_cancelImageRequestForSingleState:(NSNumber *)state {
    Udesk_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &Udesk_YYWebImageSetterKey);
    Udesk_YYWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)yy_imageURLForState:(UIControlState)state {
    Udesk_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &Udesk_YYWebImageSetterKey);
    Udesk_YYWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder {
    [self yy_setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
                   options:(YYWebImageOptions)options {
    [self yy_setImageWithURL:imageURL
                    forState:state
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(YYWebImageOptions)options
                completion:(YYWebImageCompletionBlock)completion {
    [self yy_setImageWithURL:imageURL
                    forState:state
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(YYWebImageOptions)options
                  progress:(YYWebImageProgressBlock)progress
                 transform:(YYWebImageTransformBlock)transform
                completion:(YYWebImageCompletionBlock)completion {
    [self yy_setImageWithURL:imageURL
                    forState:state
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(YYWebImageOptions)options
                   manager:(Udesk_YYWebImageManager *)manager
                  progress:(YYWebImageProgressBlock)progress
                 transform:(YYWebImageTransformBlock)transform
                completion:(YYWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _yy_setImageWithURL:imageURL
                   forSingleState:num
                      placeholder:placeholder
                          options:options
                          manager:manager
                         progress:progress
                        transform:transform
                       completion:completion];
    }
}

- (void)yy_cancelImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _yy_cancelImageRequestForSingleState:num];
    }
}


#pragma mark - background image

- (void)_yy_setBackgroundImageWithURL:(NSURL *)imageURL
                       forSingleState:(NSNumber *)state
                          placeholder:(UIImage *)placeholder
                              options:(YYWebImageOptions)options
                              manager:(Udesk_YYWebImageManager *)manager
                             progress:(YYWebImageProgressBlock)progress
                            transform:(YYWebImageTransformBlock)transform
                           completion:(YYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [Udesk_YYWebImageManager sharedManager];
    
    Udesk_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_YYWebImageBackgroundSetterKey);
    if (!dic) {
        dic = [Udesk_YYWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_YYWebImageBackgroundSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    Udesk_YYWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _yy_dispatch_sync_on_main_queue(^{
        if (!imageURL) {
            if (!(options & YYWebImageOptionIgnorePlaceHolder)) {
                [self setBackgroundImage:placeholder forState:state.integerValue];
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & YYWebImageOptionUseNSURLCache) &&
            !(options & YYWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:YYImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & YYWebImageOptionAvoidSetImage)) {
                [self setBackgroundImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, YYWebImageFromMemoryCacheFast, YYWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & YYWebImageOptionIgnorePlaceHolder)) {
            [self setBackgroundImage:placeholder forState:state.integerValue];
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([Udesk_YYWebImageSetter setterQueue], ^{
            YYWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            YYWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == YYWebImageStageFinished || stage == YYWebImageStageProgress) && image && !(options & YYWebImageOptionAvoidSetImage);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setBackgroundImage:image forState:state.integerValue];
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, YYWebImageFromNone, YYWebImageStageCancelled, nil);
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

- (void)_yy_cancelBackgroundImageRequestForSingleState:(NSNumber *)state {
    Udesk_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_YYWebImageBackgroundSetterKey);
    Udesk_YYWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)yy_backgroundImageURLForState:(UIControlState)state {
    Udesk_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_YYWebImageBackgroundSetterKey);
    Udesk_YYWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder {
    [self yy_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:kNilOptions
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:nil];
}

- (void)yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                             options:(YYWebImageOptions)options {
    [self yy_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:nil
                               options:options
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:nil];
}

- (void)yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(YYWebImageOptions)options
                          completion:(YYWebImageCompletionBlock)completion {
    [self yy_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:options
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:completion];
}

- (void)yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(YYWebImageOptions)options
                            progress:(YYWebImageProgressBlock)progress
                           transform:(YYWebImageTransformBlock)transform
                          completion:(YYWebImageCompletionBlock)completion {
    [self yy_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:options
                               manager:nil
                              progress:progress
                             transform:transform
                            completion:completion];
}

- (void)yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(YYWebImageOptions)options
                             manager:(Udesk_YYWebImageManager *)manager
                            progress:(YYWebImageProgressBlock)progress
                           transform:(YYWebImageTransformBlock)transform
                          completion:(YYWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _yy_setBackgroundImageWithURL:imageURL
                             forSingleState:num
                                placeholder:placeholder
                                    options:options
                                    manager:manager
                                   progress:progress
                                  transform:transform
                                 completion:completion];
    }
}

- (void)yy_cancelBackgroundImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _yy_cancelBackgroundImageRequestForSingleState:num];
    }
}

@end
