//
//  UdeskAssetModel.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAssetModel.h"

@implementation UdeskAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(UdeskAssetModelMediaType)type timeLength:(NSString *)timeLength {
    UdeskAssetModel *model = [[UdeskAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    model.videoTimeLength = timeLength;
    return model;
}

@end
