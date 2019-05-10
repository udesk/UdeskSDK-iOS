//
//  UdeskAlbumsViewManager.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "UdeskAlbumModel.h"

@interface UdeskAlbumsViewManager : NSObject

//所有相册
+ (void)allAlbumsWithAllowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<UdeskAlbumModel *> *albumArray))completion;
//相册的第一个图像
+ (void)fetchAlbumPosterImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion;

@end
