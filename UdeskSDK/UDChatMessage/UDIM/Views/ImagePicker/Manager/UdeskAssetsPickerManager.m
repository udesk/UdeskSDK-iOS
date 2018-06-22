//
//  UdeskAssetsPickerManager.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAssetsPickerManager.h"
#import "UdeskVideoUtil.h"
#import "UdeskImageUtil.h"

@interface UdeskAssetsPickerManager()

@property (nonatomic, strong, readwrite) NSArray<UdeskAssetModel *> *assetArray;

@end

@implementation UdeskAssetsPickerManager

- (void)assetsFromFetchResult:(PHFetchResult *)result allowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<UdeskAssetModel *> *assetArray))completion {
    
    if (!result || result == (id)kCFNull) return ;
    if (![result isKindOfClass:[PHFetchResult class]]) return ;
    
    NSMutableArray *photoArr = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UdeskAssetModel *model = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo];
            if (model) {
                [photoArr addObject:model];
            }
        }];
        
        self.assetArray = photoArr;
        if (completion) completion(photoArr);
    }
}

- (UdeskAssetModel *)assetModelWithAsset:(PHAsset *)asset allowPickingVideo:(BOOL)allowPickingVideo {
    
    if (!asset || asset == (id)kCFNull) return nil;
    if (![asset isKindOfClass:[PHAsset class]]) return nil;
    
    UdeskAssetModel *model;
    UdeskAssetModelMediaType type = [self getAssetType:asset];
    if (!allowPickingVideo && type == UdeskAssetModelMediaTypeVideo) return nil;
    
    NSString *timeLength = type == UdeskAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",asset.duration] : @"";
    timeLength = [UdeskVideoUtil videoTimeFromDurationSecond:timeLength.integerValue];
    model = [UdeskAssetModel modelWithAsset:asset type:type timeLength:timeLength];
    
    return model;
}

- (UdeskAssetModelMediaType)getAssetType:(PHAsset *)asset {
    UdeskAssetModelMediaType type = UdeskAssetModelMediaTypePhoto;
    if (!asset || asset == (id)kCFNull) return type;
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        if (phAsset.mediaType == PHAssetMediaTypeVideo) {
            type = UdeskAssetModelMediaTypeVideo;
        }
        else if (phAsset.mediaType == PHAssetMediaTypeImage) {
            
            if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                type = UdeskAssetModelMediaTypePhotoGif;
            }
        }
    }
    return type;
}

//获取原图
- (void)fetchOriginalPhotoWithAssets:(NSArray<PHAsset *> *)assets completion:(void (^)(NSArray<UIImage *> *images))completion {
    
    [self fetchSendPhotoWithAssets:assets isOriginal:YES quality:1 completion:completion];
}

//获取压缩图
- (void)fetchCompressPhotoWithAssets:(NSArray<PHAsset *> *)assets quality:(CGFloat)quality completion:(void (^)(NSArray<UIImage *> *images))completion {
    
    [self fetchSendPhotoWithAssets:assets isOriginal:NO quality:quality completion:completion];
}

- (void)fetchSendPhotoWithAssets:(NSArray<PHAsset *> *)assets isOriginal:(BOOL)isOriginal quality:(CGFloat)quality completion:(void (^)(NSArray<UIImage *> *images))completion {
    
    if (!assets || assets == (id)kCFNull) return ;
    if (![assets isKindOfClass:[NSArray class]]) return ;
    if (![assets.firstObject isKindOfClass:[PHAsset class]]) return ;
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    NSMutableArray *array = [NSMutableArray array];
    for (PHAsset *asset in assets) {
        
        [UdeskAssetsPickerManager fetchOriginalDataWithAsset:asset completion:^(NSData *imageData) {
            if (imageData) {
                UIImage *result = [UIImage imageWithData:imageData];
                if (result) {
                    result = [UdeskImageUtil fixOrientation:result];
                    //压缩图片
                    if (!isOriginal) {
                        UIImage *image = [UdeskImageUtil imageWithOriginalImage:result quality:quality];
                        if (image) {
                            result = image;
                        }
                    }
                    if (result) {
                        [array addObject:result];
                    }
                    if (array.count == assets.count) {
                        if (completion) completion(array);
                    }
                }
            }
        }];
    }
}

//获取原图GifImages
- (void)fetchOriginalGifPhotoWithAssets:(NSArray<PHAsset *> *)assets completion:(void (^)(NSArray<NSData *> *gifs))completion {
    
    if (!assets || assets == (id)kCFNull) return ;
    if (![assets isKindOfClass:[NSArray class]]) return ;
    if (![assets.firstObject isKindOfClass:[PHAsset class]]) return ;
    
    NSMutableArray *array = [NSMutableArray array];
    for (PHAsset *asset in assets) {
        [UdeskAssetsPickerManager fetchOriginalDataWithAsset:asset completion:^(NSData *imageData) {
            if (imageData) {
                [array addObject:imageData];
            }
            if (array.count == assets.count) {
                if (completion) completion(array);
            }
        }];
    }
}

//获取压缩Video
- (void)fetchCompressVideoWithAssets:(NSArray<PHAsset *> *)assets completion:(void (^)(NSArray<NSString *> *paths))completion {
    
    if (!assets || assets == (id)kCFNull) return ;
    if (![assets isKindOfClass:[NSArray class]]) return ;
    
    NSMutableArray *pathArray = [NSMutableArray array];
    for (PHAsset *asset in assets) {
        [self fetchVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetHighestQuality success:^(NSString *outputPath) {
            
            if (outputPath) {
                [pathArray addObject:outputPath];
            }
            
            if (pathArray.count == assets.count) {
                if (completion) completion(pathArray);
            }
            
        } failure:^(NSString *errorMessage, NSError *error) {
            NSLog(@"%@",error);
            if (completion) completion(nil);
        }];
    }
}

- (void)fetchVideoOutputPathWithAsset:(PHAsset *)asset presetName:(NSString *)presetName success:(void (^)(NSString *outputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure {
    
    if (!asset || asset == (id)kCFNull) return ;
    if (![asset isKindOfClass:[PHAsset class]]) return ;
    
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        
        AVURLAsset *videoAsset = (AVURLAsset*)avasset;
        [self startExportVideoWithVideoAsset:videoAsset presetName:presetName success:success failure:failure];
    }];
}

- (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset presetName:(NSString *)presetName success:(void (^)(NSString *outputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure {
    
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    
    if ([presets containsObject:presetName]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:presetName];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"];
        NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        // NSLog(@"video outputPath = %@",outputPath);
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        
        // Optimize for network use.
        session.shouldOptimizeForNetworkUse = true;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            if (failure) {
                failure(@"该视频类型暂不支持导出", nil);
            }
            NSLog(@"UdeskSDK：视频类型暂不支持导出");
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        AVMutableVideoComposition *videoComposition = [UdeskVideoUtil fixedCompositionWithAsset:videoAsset];
        if (videoComposition.renderSize.width) {
            // 修正视频转向
            session.videoComposition = videoComposition;
        }
        
        // Begin to export video to the output path asynchronously.
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (session.status) {
                    case AVAssetExportSessionStatusUnknown: {
                        NSLog(@"UdeskSDK：AVAssetExportSessionStatusUnknown");
                    }  break;
                    case AVAssetExportSessionStatusWaiting: {
                        NSLog(@"UdeskSDK：AVAssetExportSessionStatusWaiting");
                    }  break;
                    case AVAssetExportSessionStatusExporting: {
                        NSLog(@"UdeskSDK：AVAssetExportSessionStatusExporting");
                    }  break;
                    case AVAssetExportSessionStatusCompleted: {
                        NSLog(@"UdeskSDK：AVAssetExportSessionStatusCompleted");
                        if (success) {
                            success(outputPath);
                        }
                    }  break;
                    case AVAssetExportSessionStatusFailed: {
                        NSLog(@"UdeskSDK：AVAssetExportSessionStatusFailed");
                        if (failure) {
                            failure(@"视频导出失败", session.error);
                        }
                    }  break;
                    case AVAssetExportSessionStatusCancelled: {
                        NSLog(@"UdeskSDK：AVAssetExportSessionStatusCancelled");
                        if (failure) {
                            failure(@"导出任务已被取消", nil);
                        }
                    }  break;
                    default: break;
                }
            });
        }];
    } else {
        if (failure) {
            NSString *errorMessage = [NSString stringWithFormat:@"当前设备不支持该预设:%@", presetName];
            failure(errorMessage, nil);
        }
    }
}

//获取原图
+ (void)fetchOriginalDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData))completion {
    
    if (!asset || asset == (id)kCFNull) return ;
    if (![asset isKindOfClass:[PHAsset class]]) return ;
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            if (completion) completion(imageData);
        }
    }];
}

+ (void)fetchPreviewPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion {
    
    if (!asset || asset == (id)kCFNull) return ;
    if (![asset isKindOfClass:[PHAsset class]]) return ;
    
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = [UIScreen mainScreen].bounds.size.width * ([UIScreen mainScreen].bounds.size.width > 700 ? 1.5 : 2) * 1.5;
    
    // 超宽图片
    if (aspectRatio > 1.8) {
        pixelWidth = pixelWidth * aspectRatio;
    }
    // 超高图片
    if (aspectRatio < 0.2) {
        pixelWidth = pixelWidth * 0.5;
    }
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    [UdeskAssetsPickerManager fetchPhotoWithAsset:asset imageSize:imageSize completion:completion];
}

+ (void)fetchPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion {
    
    [UdeskAssetsPickerManager fetchPhotoWithAsset:asset imageSize:CGSizeMake(250, 250) completion:completion];
}

+ (void)fetchPhotoWithAsset:(PHAsset *)asset imageSize:(CGSize)imageSize completion:(void (^)(UIImage *image))completion {
    
    if (!asset || asset == (id)kCFNull) return ;
    if (![asset isKindOfClass:[PHAsset class]]) return ;
    
    __block UIImage *image;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result) {
            image = result;
        }
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            result = [UdeskImageUtil fixOrientation:result];
            if (completion) completion(result);
        }
    }];
}

//获取视频
+ (void)fetchVideoWithAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem *playerItem))completion {
    [self fetchVideoWithAsset:asset progressHandler:nil completion:completion];
}

+ (void)fetchVideoWithAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *playerItem))completion {
    
    if (!asset || asset == (id)kCFNull) return ;
    if (![asset isKindOfClass:[PHAsset class]]) return ;
    
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if (completion) completion(playerItem);
    }];
}

@end
