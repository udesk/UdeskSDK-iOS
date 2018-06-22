//
//  UdeskAssetsPickerManager.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "UdeskAssetModel.h"

@interface UdeskAssetsPickerManager : NSObject

@property (nonatomic, strong, readonly) NSArray<UdeskAssetModel *> *assetArray;

- (void)assetsFromFetchResult:(PHFetchResult *)result allowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<UdeskAssetModel *> *assetArray))completion;
//获取原图Images
- (void)fetchOriginalPhotoWithAssets:(NSArray<PHAsset *> *)assets completion:(void (^)(NSArray<UIImage *> *images))completion;
//获取压缩图
- (void)fetchCompressPhotoWithAssets:(NSArray<PHAsset *> *)assets quality:(CGFloat)quality completion:(void (^)(NSArray<UIImage *> *images))completion;

//获取原图GifImages
- (void)fetchOriginalGifPhotoWithAssets:(NSArray<PHAsset *> *)assets completion:(void (^)(NSArray<NSData *> *gifs))completion;

//获取视频
- (void)fetchCompressVideoWithAssets:(NSArray<PHAsset *> *)assets completion:(void (^)(NSArray<NSString *> *paths))completion;

//获取原图Data
+ (void)fetchOriginalDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData))completion;
+ (void)fetchPreviewPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion;
+ (void)fetchPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion;
//获取视频
+ (void)fetchVideoWithAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem *playerItem))completion;

@end
