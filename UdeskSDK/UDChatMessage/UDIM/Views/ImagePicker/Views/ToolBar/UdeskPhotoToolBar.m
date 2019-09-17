//
//  UdeskPhotoToolBar.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/8.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskPhotoToolBar.h"
#import "UdeskBundleUtils.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskAssetModel.h"
#import "UdeskAssetsPickerManager.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKMacro.h"

static NSString *kCollectionViewCellIdentifier = @"kCollectionViewCellIdentifier";

@interface UdeskPhotoToolBar()<UICollectionViewDelegate,UICollectionViewDataSource>

    
@property (nonatomic, strong) UIView *lineView;

@end

@implementation UdeskPhotoToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.backgroundColor = [UIColor colorWithRed:0.141f  green:0.145f  blue:0.149f alpha:1];
    
    _toolBarFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _toolBarFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _toolBarCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_toolBarFlowLayout];
    _toolBarCollectionView.backgroundColor = [UIColor colorWithRed:0.141f  green:0.145f  blue:0.149f alpha:1];
    _toolBarCollectionView.dataSource = self;
    _toolBarCollectionView.delegate = self;
    _toolBarCollectionView.pagingEnabled = YES;
    _toolBarCollectionView.scrollsToTop = NO;
    _toolBarCollectionView.showsHorizontalScrollIndicator = NO;
    _toolBarCollectionView.contentOffset = CGPointMake(0, 0);
    _toolBarCollectionView.contentInset = UIEdgeInsetsMake(12, 13, 12, 13);
    [self addSubview:_toolBarCollectionView];
    [_toolBarCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [UIColor colorWithRed:0.2f  green:0.204f  blue:0.208f alpha:1];
    [self addSubview:_lineView];
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitle:getUDLocalizedString(@"udesk_preview") forState:UIControlStateNormal];
    [_previewButton setTitle:getUDLocalizedString(@"udesk_preview") forState:UIControlStateDisabled];
    [_previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor colorWithRed:1  green:1  blue:1 alpha:0.4] forState:UIControlStateDisabled];
    _previewButton.enabled = NO;
    [self addSubview:_previewButton];
    
    _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_originalPhotoButton setTitle:getUDLocalizedString(@"udesk_full_image") forState:UIControlStateNormal];
    [_originalPhotoButton setImage:[UIImage udDefaultImagePickerFullImage] forState:UIControlStateNormal];
    [_originalPhotoButton setImage:[UIImage udDefaultImagePickerFullImageSelected] forState:UIControlStateSelected];
    [self addSubview:_originalPhotoButton];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:getUDLocalizedString(@"udesk_send") forState:UIControlStateNormal];
    [_doneButton setTitle:getUDLocalizedString(@"udesk_send") forState:UIControlStateDisabled];
    [_doneButton setTitleColor:[UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1] forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:0.4] forState:UIControlStateDisabled];
    _doneButton.enabled = NO;
    [self addSubview:_doneButton];
}

- (void)previewButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolBarDidSelectPreview:)]) {
        [self.delegate toolBarDidSelectPreview:self];
    }
}

- (void)originalPhotoButtonClick:(UIButton *)button {
    button.selected = !button.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolBarDidSelectOriginalPhoto:)]) {
        [self.delegate toolBarDidSelectOriginalPhoto:self];
    }
}

- (void)doneButtonClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolBarDidSelectDone:)]) {
        [self.delegate toolBarDidSelectDone:self];
    }
    
    self.doneButton.enabled = NO;
    self.doneButton.alpha = 0.4;
}

- (void)updateSendNumber:(NSInteger)count {
    
    self.previewButton.enabled = count > 0 ? YES : NO;
    self.doneButton.enabled = count > 0 ? YES : NO;
    [self.doneButton setTitle:[NSString stringWithFormat:@"%@(%ld)",getUDLocalizedString(@"udesk_send"),count] forState:UIControlStateNormal];
    [self.doneButton setTitle:[NSString stringWithFormat:@"%@(%ld)",getUDLocalizedString(@"udesk_send"),count] forState:UIControlStateDisabled];
    if (!count) {
        [self.doneButton setTitle:getUDLocalizedString(@"udesk_send") forState:UIControlStateNormal];
        [self.doneButton setTitle:getUDLocalizedString(@"udesk_send") forState:UIControlStateDisabled];
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskAssetModel *model = self.selectedAssets[indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier forIndexPath:indexPath];
    
    [UdeskAssetsPickerManager fetchPreviewPhotoWithAsset:model.asset completion:^(UIImage *image) {
        cell.backgroundView = [[UIImageView alloc] initWithImage:image];
        if ([self.currentAsset.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            cell.backgroundView.layer.borderWidth = 2;
            cell.backgroundView.layer.borderColor = [UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1].CGColor;
        }
        else {
            cell.backgroundView.layer.borderWidth = 0;
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskAssetModel *model = self.selectedAssets[indexPath.row];
    self.currentAsset = model;
    [self.toolBarCollectionView reloadData];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolBarDidSelectPreviewItemAtAssetModel:)]) {
        [self.delegate toolBarDidSelectPreviewItemAtAssetModel:model];
    }
}

- (void)setCurrentAsset:(UdeskAssetModel *)currentAsset {
    if (!currentAsset || currentAsset == (id)kCFNull) return ;
    _currentAsset = currentAsset;
    if (self.toolBarCollectionView) {
        [self.toolBarCollectionView reloadData];
    }
    @try {
        if ([self.selectedAssets containsObject:currentAsset]) {
            NSUInteger index = [self.selectedAssets indexOfObject:currentAsset];
            [self updateContentOffsetWithIndex:index];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)setSelectedAssets:(NSArray *)selectedAssets {
    if (!selectedAssets || selectedAssets == (id)kCFNull) return ;
    _selectedAssets = selectedAssets;
    if (self.toolBarCollectionView) {
        [self.toolBarCollectionView reloadData];
    }
}

- (void)updateContentOffsetWithIndex:(NSInteger)index {
    
    @try {
        
        CGFloat space = [[UIScreen mainScreen] bounds].size.width/1.8;
        CGFloat contentX = (54 + 12) * index - space;
        if (contentX < 0) {
            contentX = -12;
        }
        [self.toolBarCollectionView setContentOffset:CGPointMake(contentX, self.toolBarCollectionView.contentOffset.y) animated:YES];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _toolBarFlowLayout.itemSize = CGSizeMake(54, 54);
    _toolBarFlowLayout.minimumLineSpacing = 12;
    _toolBarFlowLayout.minimumInteritemSpacing = 12;
    _toolBarCollectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 80);
    [_toolBarCollectionView setCollectionViewLayout:_toolBarFlowLayout];
    
    CGFloat topSpace = 0;
    if (!_toolBarCollectionView.hidden) {
        topSpace = CGRectGetMaxY(_toolBarCollectionView.frame);
        _lineView.frame = CGRectMake(0, topSpace, CGRectGetWidth(self.frame), 1);
    }
    
    CGFloat iphoneX = udIsIPhoneXSeries ? 34 : 0;
    _previewButton.frame = CGRectMake(8, (CGRectGetHeight(self.frame)-30-iphoneX + topSpace)/2, 60, 30);
    _originalPhotoButton.frame = CGRectMake(self.center.x-40, (CGRectGetHeight(self.frame)-20-iphoneX + topSpace)/2, 80, 20);
    _doneButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 60 - 10, (CGRectGetHeight(self.frame)-30-iphoneX + topSpace)/2, 60, 30);
    
    if (self.currentAsset && [self.selectedAssets containsObject:self.currentAsset]) {
        NSUInteger index = [self.selectedAssets indexOfObject:self.currentAsset];
        [self updateContentOffsetWithIndex:index];
    }
}

@end
