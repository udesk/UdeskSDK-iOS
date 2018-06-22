//
//  UdeskPhotoToolBar.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/8.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskPhotoToolBar;
@class UdeskAssetModel;

@protocol UdeskPhotoToolBarDelegate <NSObject>

@optional
- (void)toolBarDidSelectPreview:(UdeskPhotoToolBar *)toolBar;
- (void)toolBarDidSelectOriginalPhoto:(UdeskPhotoToolBar *)toolBar;
- (void)toolBarDidSelectDone:(UdeskPhotoToolBar *)toolBar;
- (void)toolBarDidSelectPreviewItemAtAssetModel:(UdeskAssetModel *)asset;

@end

@interface UdeskPhotoToolBar : UIView

@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *originalPhotoButton;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) UICollectionViewFlowLayout *toolBarFlowLayout;
@property (nonatomic, strong) UICollectionView           *toolBarCollectionView;

@property (nonatomic, strong) UdeskAssetModel            *currentAsset;
@property (nonatomic, strong) NSArray                    *selectedAssets;

@property (nonatomic, weak  ) id<UdeskPhotoToolBarDelegate> delegate;

- (void)updateSendNumber:(NSInteger)count;

@end
