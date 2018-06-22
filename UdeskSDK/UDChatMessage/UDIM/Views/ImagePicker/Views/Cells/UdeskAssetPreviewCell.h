//
//  UdeskAssetPreviewCell.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskPhotoPreviewView.h"
@class UdeskAssetModel;

@interface UdeskAssetPreviewCell : UICollectionViewCell

@property (nonatomic, strong) UdeskAssetModel *assetModel;
@property (nonatomic, copy) void (^SingleTapGestureBlock)(void);

- (void)configSubviews;

@end

@interface UdeskPhotoPreviewCell : UdeskAssetPreviewCell

@property (nonatomic, strong) UdeskPhotoPreviewView *previewView;

- (void)recoverSubviews;

@end

@interface UdeskGIFPreviewCell : UdeskAssetPreviewCell

@property (nonatomic, strong) UdeskPhotoPreviewView *previewView;

@end

@class AVPlayer;
@class AVPlayerLayer;
@interface UdeskVideoPreviewCell : UdeskAssetPreviewCell

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIImage *cover;

- (void)pausePlayerAndShowNavBar;

@end
