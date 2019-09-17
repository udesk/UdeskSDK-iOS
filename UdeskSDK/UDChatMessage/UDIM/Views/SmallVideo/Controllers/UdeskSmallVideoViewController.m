//
//  UdeskSmallVideoViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSmallVideoViewController.h"
#import "UdeskSmallVideoPreviewViewController.h"
#import "UdeskSmallVideoBottomView.h"
#import "UdeskSmallVideoManager.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "UdeskBundleUtils.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskImageUtil.h"
#import "UdeskSDKConfig.h"
#import "UdeskButton.h"

@interface UdeskSmallVideoViewController ()<UdeskSmallVideoBottomViewDelegate>

@property (nonatomic, strong) UdeskSmallVideoManager *videoManager;
@property (nonatomic, strong) UdeskSmallVideoBottomView *bottomView;
@property (nonatomic, strong) UdeskButton *invertButton;
@property (nonatomic, strong) UdeskButton *backButton;
@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, assign) BOOL   savingImage;
@property (nonatomic, strong) UdeskSmallVideoPreviewViewController *previewVC;

@end

@implementation UdeskSmallVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)setup {
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self configVideoManager];
    
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.invertButton];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.bottomView];
    
    //第一次自动对焦
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self firstAutoFouce];
    });
}

- (void)firstAutoFouce {
    [self updateFocusWithPoint:self.view.center];
}

- (void)configVideoManager {
    
    _videoManager = [UdeskSmallVideoManager sharedManager];
    _videoManager.maxDuration = [UdeskSDKConfig customConfig].smallVideoDuration;
    _videoManager.cropSize = self.previewView.frame.size;
    
    __weak typeof(self) weakSelf = self;
    self.videoManager.finishBlock = ^(NSDictionary *info, UdeskRecorderFinishedReason finishReason) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        switch (finishReason) {
            case UdeskRecorderFinishedReasonNormal:
            case UdeskRecorderFinishedReasonBeyondMaxDuration:
                
                [strongSelf previewVideoWithURL:[info objectForKey:@"videoURL"] videoInfo:info];
                break;
            case UdeskRecorderFinishedReasonCancle:
                NSLog(@"UdeskSDK：取消录制视频");
                break;
                
            default:
                break;
        }
    };
    
    [self.videoManager setup];
    
    CALayer *tempLayer = [self.videoManager previewLayer];
    tempLayer.frame = self.previewView.bounds;
    [self.previewView.layer addSublayer:tempLayer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.videoManager startSession];
    });
}

- (void)previewVideoWithURL:(NSString *)sandboxURL videoInfo:(NSDictionary *)info {
    
    self.previewVC = [UdeskSmallVideoPreviewViewController new];
    self.previewVC.url = sandboxURL;
    __weak typeof(self) weakSelf = self;
    self.previewVC.SubmitShootingBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf removeSelf:^{
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didFinishRecordSmallVideo:)]) {
                [strongSelf.delegate didFinishRecordSmallVideo:info];
            }
        }];
    };
    
    self.previewVC.AbandonSmallVideoBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.videoManager removeSmallVideoCache];
    };
    
    [self.view addSubview:self.previewVC.view];
}

- (void)removeSelf:(void(^)(void))completion {
    
    [self.videoManager stopSession];
    [self dismissViewControllerAnimated:YES completion:completion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy
- (UdeskButton *)invertButton {
    if (!_invertButton) {
        _invertButton = [UdeskButton buttonWithType:UIButtonTypeCustom];
        [_invertButton setImage:[UIImage udDefaultSmallVideoCameraSwitch] forState:UIControlStateNormal];
        [_invertButton addTarget:self action:@selector(invertAction:) forControlEvents:UIControlEventTouchUpInside];
        _invertButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 26-16, 20, 26, 21);
    }
    return _invertButton;
}

- (UdeskButton *)backButton {
    if (!_backButton) {
        _backButton = [UdeskButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage udDefaultSmallVideoBack] forState:UIControlStateNormal];
        _backButton.frame = CGRectMake(16, 20, 20, 20);
        [_backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UdeskSmallVideoBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UdeskSmallVideoBottomView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 180, [UIScreen mainScreen].bounds.size.width, 300)];
        _bottomView.backgroundColor = [UIColor clearColor];
        _bottomView.delegate = self;
        _bottomView.duration = [UdeskSDKConfig customConfig].smallVideoDuration;
    }
    return _bottomView;
}

- (UIView *)previewView {
    if (!_previewView) {
        _previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _previewView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPreview:)];
        [_previewView addGestureRecognizer:tap];
    }
    return _previewView;
}

- (UIView *)focusView {
    if (!_focusView) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderWidth = 1;
        _focusView.layer.borderColor = [UIColor colorWithRed:1  green:0.8f  blue:0 alpha:1].CGColor;
        _focusView.hidden = YES;
        [self.view addSubview:_focusView];
    }
    return _focusView;
}

#pragma mark - @protocol UdeskSmallVideoBottomViewDelegate
- (void)udSmallVideo:(UdeskSmallVideoBottomView *)smallVideoView zoomLens:(CGFloat)scaleNum {
    
    [self.videoManager setScaleFactor:scaleNum];
}

- (void)udSmallVideo:(UdeskSmallVideoBottomView *)smallVideoView isRecording:(BOOL)recording {
    
    if (recording) {
        [self startRecording];
    }
    else {
        [self finishRecording];
    }
}

- (void)udSmallVideo:(UdeskSmallVideoBottomView *)smallVideoView captureCurrentFrame:(BOOL)capture {
    
    if (capture && !_savingImage) {
        [self smallVideoCurrentFrame];
    }
}

- (void)smallVideoCurrentFrame {
    
    _savingImage = YES;
    AVCaptureConnection *conntion = [self.videoManager.imageDataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion || !conntion.enabled || !conntion.active) {
        _savingImage = NO;
        return;
    }
    
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [UdeskVideoUtil avOrientationForDeviceOrientation:curDeviceOrientation];
    [conntion setVideoOrientation:avcaptureOrientation];
    [conntion setVideoScaleAndCropFactor:1];
    
    __weak typeof(self) weakSelf = self;
    [self.videoManager.imageDataOutput captureStillImageAsynchronouslyFromConnection:conntion
                                                                   completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                                       __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                       if (imageDataSampleBuffer == nil) {
                                                                           return ;
                                                                       }
                                                                       NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                       UIImage *image = [UIImage imageWithData:imageData];
                                                                       [strongSelf previewPhoto:[UdeskImageUtil fixOrientation:image]];
                                                                   }];
}

- (void)previewPhoto:(UIImage *)image {
    
    self.previewVC = [UdeskSmallVideoPreviewViewController new];
    self.previewVC.image = image;
    __weak typeof(self) weakSelf = self;
    self.previewVC.SubmitShootingBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.savingImage = NO;
        [strongSelf removeSelf:^{
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didFinishCaptureImage:)]) {
                [strongSelf.delegate didFinishCaptureImage:image];
            }
        }];
    };
    self.previewVC.AbandonSmallVideoBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.savingImage = NO;
    };

    [self.view addSubview:self.previewVC.view];
}

- (void)startRecording {
    
    NSLog(@"UdeskSDK：开始录制小视频");
    [self.videoManager startCapture];
}

- (void)finishRecording {
    
    NSLog(@"UdeskSDK：结束录制小视频");
    [self.videoManager stopCapture];
}

#pragma mark PreviewGesture
- (void)tapPreview:(UITapGestureRecognizer *)tap {
    
    CGPoint point = [tap locationInView:self.view];
    [self updateFocusWithPoint:point];
}

- (void)updateFocusWithPoint:(CGPoint)point {
    
    [self showFouceView:point];
    CGPoint focusPoint = CGPointMake(point.x/CGRectGetWidth(self.view.frame), point.y/CGRectGetHeight(self.view.frame));
    [self.videoManager setFocusPoint:focusPoint];
}

//对焦
- (void)showFouceView:(CGPoint)point {
    
    self.focusView.hidden = NO;
    self.focusView.center = point;
    [self hiddenFouceView];
}

- (void)hiddenFouceView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.focusView.hidden = YES;
    });
}

#pragma mark Invert Action
- (void)invertAction:(UIButton *)button {
    [self.videoManager swapFrontAndBackCameras];
}

- (void)backAction:(UIButton *)button {
    [self removeSelf:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    _previewView = nil;
    _bottomView.delegate = nil;
    _bottomView = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
