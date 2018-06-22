//
//  UdeskAssetPreviewCell.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAssetPreviewCell.h"
#import "UdeskAssetModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "UdeskAssetsPickerManager.h"
#import "UIImage+UdeskSDK.h"

@implementation UdeskAssetPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self configSubviews];
    }
    return self;
}

- (void)configSubviews {
    
}

@end

@implementation UdeskPhotoPreviewCell

- (void)configSubviews {
    
    _previewView = [[UdeskPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [_previewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.SingleTapGestureBlock) {
            strongSelf.SingleTapGestureBlock();
        }
    }];
    [self addSubview:_previewView];
}

- (void)setAssetModel:(UdeskAssetModel *)assetModel {
    [super setAssetModel:assetModel];
    
    _previewView.asset = assetModel.asset;
}

- (void)recoverSubviews {
    [_previewView recoverSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}

@end

@implementation UdeskGIFPreviewCell

- (void)configSubviews {
    [self configPreviewView];
}

- (void)configPreviewView {
    _previewView = [[UdeskPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [_previewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf signleTapAction];
    }];
    [self addSubview:_previewView];
}

- (void)setAssetModel:(UdeskAssetModel *)assetModel {
    [super setAssetModel:assetModel];
    
    _previewView.model = self.assetModel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _previewView.frame = self.bounds;
}

#pragma mark - Click Event
- (void)signleTapAction {
    if (self.SingleTapGestureBlock) {
        self.SingleTapGestureBlock();
    }
}

@end

@implementation UdeskVideoPreviewCell

- (void)configSubviews {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNavBar) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)configPlayButton {
    if (_playButton) {
        [_playButton removeFromSuperview];
    }
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage udDefaultImagePickerVideoPlay] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
}

- (void)setAssetModel:(UdeskAssetModel *)assetModel {
    [super setAssetModel:assetModel];
    
    [self configMoviePlayer];
}

- (void)configMoviePlayer {
    if (_player) {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        [_player pause];
        _player = nil;
    }
    
    [UdeskAssetsPickerManager fetchPreviewPhotoWithAsset:self.assetModel.asset completion:^(UIImage *image) {
        _cover = image;
    }];

    [UdeskAssetsPickerManager fetchVideoWithAsset:self.assetModel.asset completion:^(AVPlayerItem *playerItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _player = [AVPlayer playerWithPlayerItem:playerItem];
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
            _playerLayer.frame = self.bounds;
            [self.layer addSublayer:_playerLayer];
            [self configPlayButton];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNavBar) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        });
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
    _playButton.frame = CGRectMake(0, 64, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 80 - 80);
}

- (void)photoPreviewCollectionViewDidScroll {
    [self pausePlayerAndShowNavBar];
}

#pragma mark - Click Event

- (void)playButtonClick {
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
        [_player play];
        [_playButton setImage:nil forState:UIControlStateNormal];
        [UIApplication sharedApplication].statusBarHidden = YES;
        if (self.SingleTapGestureBlock) {
            self.SingleTapGestureBlock();
        }
    } else {
        [self pausePlayerAndShowNavBar];
    }
}

- (void)pausePlayerAndShowNavBar {
    if (_player.rate != 0.0) {
        [_player pause];
        [_playButton setImage:[UIImage udDefaultImagePickerVideoPlay] forState:UIControlStateNormal];
        if (self.SingleTapGestureBlock) {
            self.SingleTapGestureBlock();
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

@end

