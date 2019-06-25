//
//  UdeskAlbumsViewManager.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAlbumsViewManager.h"
#import "UdeskImageUtil.h"

@interface UdeskAlbumsViewManager()

@end

@implementation UdeskAlbumsViewManager

+ (void)allAlbumsWithAllowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<UdeskAlbumModel *> *albumArray))completion {
    
    if (([UIDevice currentDevice].systemVersion.floatValue < 8.0f)) {
        return;
    }
    
    NSMutableArray *albumArray = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smallAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smallAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            // 过滤空相册
            if (collection.estimatedAssetCount <= 0) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1) continue;
            
            if ([collection.localizedTitle rangeOfString:@"Hidden"].location != NSNotFound || [collection.localizedTitle isEqualToString:@"已隐藏"]) continue;
            if ([collection.localizedTitle rangeOfString:@"Deleted"].location != NSNotFound || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;
            if ([self isCameraRollAlbum:collection]) {
                UdeskAlbumModel *model = [self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:YES];
                if (model) {
                    [albumArray insertObject:model atIndex:0];
                }
            } else {
                UdeskAlbumModel *model = [self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:NO];
                if (model) {
                    [albumArray addObject:model];
                }
            }
        }
    }
    
    if (completion && albumArray.count > 0) {
        completion(albumArray);
    }
}

+ (BOOL)isCameraRollAlbum:(PHAssetCollection *)metadata {
    
    if (!metadata || metadata == (id)kCFNull) return NO;
    
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 ~ 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded;
    }
    else {
        return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    }
}

+ (UdeskAlbumModel *)modelWithResult:(PHFetchResult *)result name:(NSString *)name isCameraRoll:(BOOL)isCameraRoll {
    
    if (!result || result == (id)kCFNull) return nil;
    if (![result isKindOfClass:[PHFetchResult class]]) return nil;
    
    UdeskAlbumModel *model = [[UdeskAlbumModel alloc] init];
    model.name = name;
    model.result = result;
    model.isCameraRoll = isCameraRoll;
    model.count = result.count;
    return model;
}

+ (void)fetchAlbumPosterImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion {
    
    if (!asset || asset == (id)kCFNull) return ;
    if (![asset isKindOfClass:[PHAsset class]]) return ;
    
    CGSize imageSize = CGSizeMake(180, 180);
    __block UIImage *image;
    // 修复获取图片时出现的瞬间内存过高问题
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
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                resultImage = [UdeskImageUtil imageResize:resultImage toSize:imageSize];
                if (!resultImage) {
                    resultImage = image;
                }
                resultImage = [UdeskImageUtil fixOrientation:resultImage];
                if (completion) completion(resultImage);
            }];
        }
    }];
}

@end
