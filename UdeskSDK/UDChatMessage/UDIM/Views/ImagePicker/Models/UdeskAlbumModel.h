//
//  UdeskAlbumModel.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHFetchResult;
@interface UdeskAlbumModel : NSObject

/** 相簿名称 */
@property (nonatomic, strong) NSString *name;
/** 相簿照片数量 */
@property (nonatomic, assign) NSInteger count;
/** 相簿照片 */
@property (nonatomic, strong) PHFetchResult *result;

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@property (nonatomic, assign) BOOL isCameraRoll;

@end
