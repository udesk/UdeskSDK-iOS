//
//  UdeskAssetCell.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAssetCell.h"
#import "UdeskAssetModel.h"
#import "UdeskAssetsPickerManager.h"
#import "UdeskBundleUtils.h"
#import "UIImage+UdeskSDK.h"

@interface UdeskAssetCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView      *bottomView;
@property (nonatomic, strong) UILabel     *timeLength;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, assign) int32_t bigImageRequestID;

@end

@implementation UdeskAssetCell

- (void)setAssetModel:(UdeskAssetModel *)assetModel {
    if (!assetModel || assetModel == (id)kCFNull) return ;
    _assetModel = assetModel;
    
    [UdeskAssetsPickerManager fetchPhotoWithAsset:assetModel.asset completion:^(UIImage *image) {
        self.imageView.image = image;
    }];
    self.selectAssetButton.selected = assetModel.isSelected;
    
    [self setupBottomView];
    
    [self setNeedsLayout];
}

#pragma mark - Lazy load

- (UdeskButton *)selectAssetButton {
    if (!_selectAssetButton) {
        _selectAssetButton = [UdeskButton buttonWithType:UIButtonTypeCustom];
        [_selectAssetButton setImage:[UIImage udDefaultImagePickerNotSelected] forState:UIControlStateNormal];
        [_selectAssetButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_selectAssetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectAssetButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _selectAssetButton.layer.masksToBounds = YES;
        _selectAssetButton.layer.cornerRadius = 11;
        [self.contentView addSubview:_selectAssetButton];
    }
    return _selectAssetButton;
}

- (void)selectPhotoButtonClick:(UdeskButton *)button {
    button.selected = !button.selected;
    
    if (self.udDelegate && [self.udDelegate respondsToSelector:@selector(assetCell:didSelectAsset:)]) {
        [self.udDelegate assetCell:self didSelectAsset:button.selected];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIImageView *)videoImageView {
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc] init];
        _videoImageView.image = [UIImage udDefaultImagePickerVideoIcon];
        [self.bottomView addSubview:_videoImageView];
    }
    return _videoImageView;
}

- (UILabel *)timeLength {
    if (!_timeLength) {
        _timeLength = [[UILabel alloc] init];
        _timeLength.font = [UIFont boldSystemFontOfSize:11];
        _timeLength.textColor = [UIColor whiteColor];
        _timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:_timeLength];
    }
    return _timeLength;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _selectAssetButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 22 - 4, 4, 22, 22);
    _imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    _bottomView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 17, CGRectGetWidth(self.frame), 17);
    _videoImageView.frame = CGRectMake(8, 0, 20, 12);
    _timeLength.frame = CGRectMake(CGRectGetMaxX(self.videoImageView.frame), 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(self.videoImageView.frame) - 5, 12);
    
    [self setupBottomView];
}

- (void)setupBottomView {
    
    switch (self.assetModel.type) {
        case UdeskAssetModelMediaTypePhoto:
            self.bottomView.hidden = YES;
            break;
        case UdeskAssetModelMediaTypeVideo:
            self.bottomView.hidden = NO;
            self.timeLength.text = self.assetModel.videoTimeLength;
            self.videoImageView.hidden = NO;
            self.timeLength.frame = CGRectMake(CGRectGetMaxX(self.videoImageView.frame), CGRectGetMinY(self.timeLength.frame), CGRectGetWidth(self.timeLength.frame), CGRectGetHeight(self.timeLength.frame));
            self.timeLength.textAlignment = NSTextAlignmentRight;
            break;
        case UdeskAssetModelMediaTypePhotoGif:
            self.bottomView.hidden = NO;
            self.timeLength.text = @"GIF";
            self.videoImageView.hidden = YES;
            self.timeLength.frame = CGRectMake(5, CGRectGetMinY(self.timeLength.frame), CGRectGetWidth(self.timeLength.frame), CGRectGetHeight(self.timeLength.frame));
            self.timeLength.textAlignment = NSTextAlignmentLeft;
            break;
            
        default:
            break;
    }
}

- (void)setSelectionIndex:(NSInteger)selectionIndex {
    _selectionIndex = selectionIndex;
    
    if (selectionIndex == -1) {
        _selectAssetButton.backgroundColor = [UIColor clearColor];
        [_selectAssetButton setImage:[UIImage udDefaultImagePickerNotSelected] forState:UIControlStateNormal];
        [self.selectAssetButton setTitle:nil forState:UIControlStateNormal];
        return;
    }
    
    [_selectAssetButton setImage:nil forState:UIControlStateNormal];
    _selectAssetButton.backgroundColor = [UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1];
    [self.selectAssetButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)(selectionIndex + 1)] forState:UIControlStateNormal];
}

@end
