//
//  UdeskAssetModel.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAsset;

typedef enum : NSUInteger {
    UdeskAssetModelMediaTypePhoto = 0,
    UdeskAssetModelMediaTypePhotoGif,
    UdeskAssetModelMediaTypeVideo,
} UdeskAssetModelMediaType;

@interface UdeskAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
/** 是否选中 */
@property (nonatomic, assign) BOOL isSelected;
/** 媒体类型 */
@property (nonatomic, assign) UdeskAssetModelMediaType type;
/** 视频时长 */
@property (nonatomic, copy  ) NSString *videoTimeLength;

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(UdeskAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end
