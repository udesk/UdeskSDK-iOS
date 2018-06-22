//
//  UdeskPhotoPreviewView.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskPhotoPreviewView.h"
#import "UdeskAssetModel.h"
#import <Photos/Photos.h>
#import "UdeskAssetsPickerManager.h"
#import "UIImage+UdeskSDK.h"

@interface UdeskPhotoPreviewView()<UIScrollViewDelegate>

@end

@implementation UdeskPhotoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.bouncesZoom = YES;
    _scrollView.maximumZoomScale = 2.5;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.multipleTouchEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.alwaysBounceVertical = NO;
    [self addSubview:_scrollView];
    
    _imageContainerView = [[UIView alloc] init];
    _imageContainerView.clipsToBounds = YES;
    _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
    [_scrollView addSubview:_imageContainerView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [_imageContainerView addSubview:_imageView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self addGestureRecognizer:tap2];
}

- (void)setModel:(UdeskAssetModel *)model {
    if (!model || model == (id)kCFNull) return ;
    _model = model;
    [_scrollView setZoomScale:1.0 animated:NO];
    if (model.type == UdeskAssetModelMediaTypePhotoGif) {
        // 先显示缩略图
        [UdeskAssetsPickerManager fetchPhotoWithAsset:model.asset completion:^(UIImage *image) {
            self.imageView.image = image;
            [self resizeSubviews];
            
            [UdeskAssetsPickerManager fetchOriginalDataWithAsset:model.asset completion:^(NSData *imageData) {
                self.imageView.image = [UIImage udAnimatedGIFWithData:imageData];
                [self resizeSubviews];
            }];
        }];
    } else {
        self.asset = model.asset;
    }
}

- (void)setAsset:(PHAsset *)asset {
    if (!asset || asset == (id)kCFNull) return ;
    _asset = asset;
    
    [UdeskAssetsPickerManager fetchPreviewPhotoWithAsset:asset completion:^(UIImage *image) {
        self.imageView.image = image;
        [self resizeSubviews];
    }];
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {

    _imageContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame),CGRectGetHeight(_imageContainerView.frame));
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > CGRectGetHeight(self.frame) / CGRectGetWidth(self.scrollView.frame)) {
        _imageContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame),floor(image.size.height / (image.size.width / CGRectGetWidth(self.scrollView.frame))));
    } else {
        CGFloat height = image.size.height / image.size.width * CGRectGetWidth(self.scrollView.frame);
        if (height < 1 || isnan(height)) height = CGRectGetHeight(self.frame);
        height = floor(height);
        _imageContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame),height);
        _imageContainerView.center = CGPointMake(_imageContainerView.center.x, CGRectGetHeight(self.frame) / 2);
    }
    if (CGRectGetHeight(_imageContainerView.frame) > CGRectGetHeight(self.frame) && CGRectGetHeight(_imageContainerView.frame) - CGRectGetHeight(self.frame) <= 1) {
        _imageContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame),CGRectGetHeight(self.frame));
    }
    CGFloat contentSizeH = MAX(CGRectGetHeight(_imageContainerView.frame), CGRectGetHeight(self.frame));
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), contentSizeH);
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = CGRectGetHeight(_imageContainerView.frame) <= CGRectGetHeight(self.frame) ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = CGRectMake(10, 0, CGRectGetWidth(self.frame) - 20, CGRectGetHeight(self.frame));
    
    [self recoverSubviews];
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.SingleTapGestureBlock) {
        self.SingleTapGestureBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (CGRectGetWidth(_scrollView.frame) > _scrollView.contentSize.width) ? ((CGRectGetWidth(_scrollView.frame) - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (CGRectGetHeight(_scrollView.frame) > _scrollView.contentSize.height) ? ((CGRectGetHeight(_scrollView.frame) - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

@end
