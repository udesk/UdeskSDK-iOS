//
//  YYWebImageManager.h
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/19.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import "Udesk_YYImageCache.h"

@class Udesk_YYWebImageOperation;

NS_ASSUME_NONNULL_BEGIN

/// The options to control image operation.
typedef NS_OPTIONS(NSUInteger, Udesk_YYWebImageOptions) {
    
    /// Show network activity on status bar when download image.
    Udesk_YYWebImageOptionShowNetworkActivity = 1 << 0,
    
    /// Display progressive/interlaced/baseline image during download (same as web browser).
    Udesk_YYWebImageOptionProgressive = 1 << 1,
    
    /// Display blurred progressive JPEG or interlaced PNG image during download.
    /// This will ignore baseline image for better user experience.
    Udesk_YYWebImageOptionProgressiveBlur = 1 << 2,
    
    /// Use NSURLCache instead of YYImageCache.
    Udesk_YYWebImageOptionUseNSURLCache = 1 << 3,
    
    /// Allows untrusted SSL ceriticates.
    Udesk_YYWebImageOptionAllowInvalidSSLCertificates = 1 << 4,
    
    /// Allows background task to download image when app is in background.
    Udesk_YYWebImageOptionAllowBackgroundTask = 1 << 5,
    
    /// Handles cookies stored in NSHTTPCookieStore.
    Udesk_YYWebImageOptionHandleCookies = 1 << 6,
    
    /// Load the image from remote and refresh the image cache.
    Udesk_YYWebImageOptionRefreshImageCache = 1 << 7,
    
    /// Do not load image from/to disk cache.
    Udesk_YYWebImageOptionIgnoreDiskCache = 1 << 8,
    
    /// Do not change the view's image before set a new URL to it.
    Udesk_YYWebImageOptionIgnorePlaceHolder = 1 << 9,
    
    /// Ignore image decoding.
    /// This may used for image downloading without display.
    Udesk_YYWebImageOptionIgnoreImageDecoding = 1 << 10,
    
    /// Ignore multi-frame image decoding.
    /// This will handle the GIF/APNG/WebP/ICO image as single frame image.
    Udesk_YYWebImageOptionIgnoreAnimatedImage = 1 << 11,
    
    /// Set the image to view with a fade animation.
    /// This will add a "fade" animation on image view's layer for better user experience.
    Udesk_YYWebImageOptionSetImageWithFadeAnimation = 1 << 12,
    
    /// Do not set the image to the view when image fetch complete.
    /// You may set the image manually.
    Udesk_YYWebImageOptionAvoidSetImage = 1 << 13,
    
    /// This flag will add the URL to a blacklist (in memory) when the URL fail to be downloaded,
    /// so the library won't keep trying.
    Udesk_YYWebImageOptionIgnoreFailedURL = 1 << 14,
};

/// Indicated where the image came from.
typedef NS_ENUM(NSUInteger, Udesk_YYWebImageFromType) {
    
    /// No value.
    Udesk_YYWebImageFromNone = 0,
    
    /// Fetched from memory cache immediately.
    /// If you called "setImageWithURL:..." and the image is already in memory,
    /// then you will get this value at the same call.
    Udesk_YYWebImageFromMemoryCacheFast,
    
    /// Fetched from memory cache.
    Udesk_YYWebImageFromMemoryCache,
    
    /// Fetched from disk cache.
    Udesk_YYWebImageFromDiskCache,
    
    /// Fetched from remote (web or file path).
    Udesk_YYWebImageFromRemote,
};

/// Indicated image fetch complete stage.
typedef NS_ENUM(NSInteger, Udesk_YYWebImageStage) {
    
    /// Incomplete, progressive image.
    Udesk_YYWebImageStageProgress  = -1,
    
    /// Cancelled.
    Udesk_YYWebImageStageCancelled = 0,
    
    /// Finished (succeed or failed).
    Udesk_YYWebImageStageFinished  = 1,
};


/**
 The block invoked in remote image fetch progress.
 
 @param receivedSize Current received size in bytes.
 @param expectedSize Expected total size in bytes (-1 means unknown).
 */
typedef void(^Udesk_YYWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

/**
 The block invoked before remote image fetch finished to do additional image process.
 
 @discussion This block will be invoked before `YYWebImageCompletionBlock` to give
 you a chance to do additional image process (such as resize or crop). If there's
 no need to transform the image, just return the `image` parameter.
 
 @example You can clip the image, blur it and add rounded corners with these code:
    ^(UIImage *image, NSURL *url) {
        // Maybe you need to create an @autoreleasepool to limit memory cost.
        image = [image yy_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeScaleAspectFill];
        image = [image yy_imageByBlurRadius:20 tintColor:nil tintMode:kCGBlendModeNormal saturation:1.2 maskImage:nil];
        image = [image yy_imageByRoundCornerRadius:5];
        return image;
    }
 
 @param image The image fetched from url.
 @param url   The image url (remote or local file path).
 @return The transformed image.
 */
typedef UIImage * _Nullable (^Udesk_YYWebImageTransformBlock)(UIImage *image, NSURL *url);

/**
 The block invoked when image fetch finished or cancelled.
 
 @param image       The image.
 @param url         The image url (remote or local file path).
 @param from        Where the image came from.
 @param error       Error during image fetching.
 */
typedef void (^Udesk_YYWebImageCompletionBlock)(UIImage * _Nullable image,
                                                NSURL *url,
                                                Udesk_YYWebImageFromType from,
                                                Udesk_YYWebImageStage stage,
                                                NSError * _Nullable error);




/**
 A manager to create and manage web image operation.
 */
@interface Udesk_YYWebImageManager : NSObject

/**
 Returns global YYWebImageManager instance.
 
 @return YYWebImageManager shared instance.
 */
+ (instancetype)sharedManager;

/**
 Creates a manager with an image cache and operation queue.
 
 @param cache  Image cache used by manager (pass nil to avoid image cache).
 @param queue  The operation queue on which image operations are scheduled and run
                (pass nil to make the new operation start immediately without queue).
 @return A new manager.
 */
- (instancetype)initWithCache:(nullable Udesk_YYImageCache *)cache
                        queue:(nullable NSOperationQueue *)queue NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 Creates and returns a new image operation, the operation will start immediately.
 
 @param url        The image url (remote or local file path).
 @param options    The options to control image operation.
 @param progress   Progress block which will be invoked on background thread (pass nil to avoid).
 @param transform  Transform block which will be invoked on background thread  (pass nil to avoid).
 @param completion Completion block which will be invoked on background thread  (pass nil to avoid).
 @return A new image operation.
 */
- (nullable Udesk_YYWebImageOperation *)requestImageWithURL:(NSURL *)url
                                              options:(Udesk_YYWebImageOptions)options
                                             progress:(nullable Udesk_YYWebImageProgressBlock)progress
                                            transform:(nullable Udesk_YYWebImageTransformBlock)transform
                                           completion:(nullable Udesk_YYWebImageCompletionBlock)completion;

/**
 The image cache used by image operation. 
 You can set it to nil to avoid image cache.
 */
@property (nullable, nonatomic, strong) Udesk_YYImageCache *cache;

/**
 The operation queue on which image operations are scheduled and run.
 You can set it to nil to make the new operation start immediately without queue.
 
 You can use this queue to control maximum number of concurrent operations, to obtain 
 the status of the current operations, or to cancel all operations in this manager.
 */
@property (nullable, nonatomic, strong) NSOperationQueue *queue;

/**
 The shared transform block to process image. Default is nil.
 
 When called `requestImageWithURL:options:progress:transform:completion` and
 the `transform` is nil, this block will be used.
 */
@property (nullable, nonatomic, copy) Udesk_YYWebImageTransformBlock sharedTransformBlock;

/**
 The image request timeout interval in seconds. Default is 15.
 */
@property (nonatomic) NSTimeInterval timeout;

/**
 The username used by NSURLCredential, default is nil.
 */
@property (nullable, nonatomic, copy) NSString *username;

/**
 The password used by NSURLCredential, default is nil.
 */
@property (nullable, nonatomic, copy) NSString *password;

/**
 The image HTTP request header. Default is "Accept:image/webp,image/\*;q=0.8".
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

/**
 A block which will be invoked for each image HTTP request to do additional
 HTTP header process. Default is nil.
 
 Use this block to add or remove HTTP header field for a specified URL.
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *(^headersFilter)(NSURL *url, NSDictionary<NSString *, NSString *> * _Nullable header);

/**
 A block which will be invoked for each image operation. Default is nil.
 
 Use this block to provide a custom image cache key for a specified URL.
 */
@property (nullable, nonatomic, copy) NSString *(^cacheKeyFilter)(NSURL *url);

/**
 Returns the HTTP headers for a specified URL.
 
 @param url A specified URL.
 @return HTTP headers.
 */
- (nullable NSDictionary<NSString *, NSString *> *)headersForURL:(NSURL *)url;

/**
 Returns the cache key for a specified URL.
 
 @param url A specified URL
 @return Cache key used in YYImageCache.
 */
- (NSString *)cacheKeyForURL:(NSURL *)url;


/**
 Increments the number of active network requests.
 If this number was zero before incrementing, this will start animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
+ (void)incrementNetworkActivityCount;

/**
 Decrements the number of active network requests.
 If this number becomes zero after decrementing, this will stop animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
+ (void)decrementNetworkActivityCount;

/**
 Get current number of active network requests.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
+ (NSInteger)currentNetworkActivityCount;

@end

NS_ASSUME_NONNULL_END
