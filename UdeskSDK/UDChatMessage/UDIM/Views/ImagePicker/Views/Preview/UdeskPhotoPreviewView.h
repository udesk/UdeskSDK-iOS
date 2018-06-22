//
//  UdeskPhotoPreviewView.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskAssetModel;
@class PHAsset;

@interface UdeskPhotoPreviewView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;

@property (nonatomic, strong) UdeskAssetModel *model;
@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, copy) void (^SingleTapGestureBlock)(void);

- (void)recoverSubviews;

@end
