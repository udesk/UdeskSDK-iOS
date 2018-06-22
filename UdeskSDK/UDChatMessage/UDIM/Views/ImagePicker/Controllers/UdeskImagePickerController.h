//
//  UdeskImagePickerController.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskImagePickerController;
@class UdeskAssetModel;

@protocol UdeskImagePickerControllerDelegate <NSObject>

@optional
// 如果选择发送了图片，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos;

// 如果选择发送了视频，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingVideos:(NSArray<NSString *> *)videoPath;

// 如果选择发送了gif图片，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingGIFImages:(NSArray<NSData *> *)gifImages;

@end

@interface UdeskImagePickerController : UINavigationController

/** 允许选择视频（默认允许） */
@property (nonatomic, assign) BOOL allowPickingVideo;
/** 图片一次可选择数（默认9张） */
@property (nonatomic, assign) NSInteger maxImagesCount;
/** 压缩质量 */
@property (nonatomic, assign) CGFloat quality;

@property (nonatomic, strong) NSMutableArray<UdeskAssetModel *> *selectedModels;
@property (nonatomic, weak  ) id<UdeskImagePickerControllerDelegate> pickerDelegate;

@end
