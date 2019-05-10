//
//  UdeskSmallVideoManager.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSmallVideoManager.h"
#import "UdeskSmallVideoWriter.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UdeskSDKConfig.h"

@interface UdeskSmallVideoManager()<AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,UdeskSmallVideoWriterDelegate> {
    
    CMTime _timeOffset;
    CMTime _lastVideo;
    CMTime _lastAudio;
    
    UdeskSmallVideoWriter *_writer;
    
    NSTimer *_durationTimer;
    
    NSString *_smallVideoPath;
}

@property (nonatomic, assign)BOOL isCapturing; //!< 开始录制

@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) dispatch_queue_t audioDataOutputQueue;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureDevice *audioCaptureDevice;

@property (nonatomic, strong) NSMutableArray *frames;//存储录制帧

@property (nonatomic, strong) AVCaptureConnection *videoConnection; //!< 视频控制
@property (nonatomic, strong) AVCaptureConnection *audioConnection; //!< 音频控制

@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput; //!< 视频捕捉
@property (nonatomic, strong) AVCaptureDeviceInput *audioDeviceInput; //!< 音频捕捉

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;//!< 视频输出
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;//!< 音频输出

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview; //!< 视频预览层

@property (nonatomic, assign) UdeskRecorderFinishedReason finishReason;

@end

@implementation UdeskSmallVideoManager

+ (UdeskSmallVideoManager *)sharedManager {
    static UdeskSmallVideoManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UdeskSmallVideoManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _duration = 0.f;
        self.frames = [NSMutableArray arrayWithCapacity:0];
        
        self.sessionQueue = dispatch_queue_create("udesk.session.queue", DISPATCH_QUEUE_SERIAL);
        self.videoDataOutputQueue = dispatch_queue_create("udesk.videoDataOutput.queue", DISPATCH_QUEUE_SERIAL);
        self.audioDataOutputQueue = dispatch_queue_create("udesk.audioDataOutput.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.videoDataOutputQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        dispatch_set_target_queue(self.audioDataOutputQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    }
    return self;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return self.preview;
}

- (void)setup {
    
    if (!self.session) {
        
        self.isCapturing = NO;
        self.session = [[AVCaptureSession alloc] init];
        [self configurationSession];
        [self configurationPreviewLayer];
    }
}

- (void)startSession {
    
    @synchronized (self) {
        dispatch_async(self.sessionQueue, ^{
            
            if (![self.session isRunning]){
                [self.session startRunning];
            }
        });
    }
}

- (void)stopSession {
    
    @synchronized (self) {
        dispatch_async(self.sessionQueue, ^{
            
            if ([self.session isRunning]) {
                [self.session stopRunning];
                [self.preview removeFromSuperlayer];
                self.session = nil;
                self.preview = nil;
            }
        });
    }
}

- (void)startCapture {
    @synchronized (self)
    {
        dispatch_async(self.sessionQueue, ^{
            
            if (!self.isCapturing) {
                
                if (![self.session isRunning]) {
                    [self.session startRunning];
                }
                
                [self.frames removeAllObjects];
                self.isCapturing = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(computeDuration:) userInfo:nil repeats:YES];
                });
            }
        });
    }
}

- (void)stopCapture {
    [self finishCaptureWithReason:UdeskRecorderFinishedReasonNormal];
}

- (void)cancelCapture {
    [self finishCaptureWithReason:UdeskRecorderFinishedReasonCancle];
}

- (void)configurationSession {
    
    dispatch_async(self.sessionQueue, ^{
        self.captureDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        if (self.videoDeviceInput) {
            [self.session removeInput:self.videoDeviceInput];
        }
        
        NSError *error = nil;
        self.videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:&error];
        if (!self.videoDeviceInput) {
            NSLog(@"UdeskSDK：未找到设备");
        }
        
        [self.session beginConfiguration];
        [self configFrameDuration];
        
        if ([self.session canAddInput:self.videoDeviceInput]) {
            [self.session addInput:self.videoDeviceInput];
            if (self.videoDataOutput) {
                [self.session removeOutput:self.videoDataOutput];
            }
            
            //MARK :视频输出
            self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
            self.videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
            [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
            self.videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
            
            if ([self.session canAddOutput:self.videoDataOutput]) {
                
                [self.session addOutput:self.videoDataOutput];
                [self.captureDevice addObserver:self
                                     forKeyPath:@"adjustingFocus"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
                
                self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
                if (self.videoConnection.isVideoStabilizationSupported) {
                    self.videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
                }
                
                self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
            }
            else {
                NSLog(@"UdeskSDK：无法添加视频输入到会话");
            }
            
            if (self.imageDataOutput) {
                [self.session removeOutput:self.imageDataOutput];
            }
            // MARK：图片输出
            self.imageDataOutput = [[AVCaptureStillImageOutput alloc] init];
            if ([self.session canAddOutput:self.imageDataOutput]) {
                [self.session addOutput:self.imageDataOutput];
            }
            
            if (self.audioDataOutput) {
                [self.session removeOutput:self.audioDataOutput];
            }
            
            // MARK :音频输出
            self.audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            self.audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioCaptureDevice error:&error];
            if (!self.audioDeviceInput) {
                NSLog(@"UdeskSDK：不能创建音频 %@", error);
            }
            
            if ([self.session canAddInput:self.audioDeviceInput]) {
                [self.session addInput:self.audioDeviceInput];
            }
            
            self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
            [self.audioDataOutput setSampleBufferDelegate:self queue:self.audioDataOutputQueue];
            
            if ([self.session canAddOutput:self.audioDataOutput]) {
                [self.session addOutput:self.audioDataOutput];
            }
            self.audioConnection = [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
            [self.session commitConfiguration];
        }
    });
}

- (void)configFrameDuration {
    
    if ([NSProcessInfo processInfo].processorCount == 1) {
        if ([self.session canSetSessionPreset:AVCaptureSessionPresetLow]) {
            [self.session setSessionPreset:AVCaptureSessionPresetLow];
        }
    }
    else {
        if ([self.session canSetSessionPreset:[self customSessionPreset]]) {
            [self.session setSessionPreset:[self customSessionPreset]];
        }
    }
    
    Float64 _frameRate = 0.0;
    
    AVCaptureDeviceFormat *activeFormat = self.captureDevice.activeFormat;
    NSArray *supportedRanges = activeFormat.videoSupportedFrameRateRanges;
    AVFrameRateRange *targetRange = [supportedRanges count] > 0 ? supportedRanges[0] : nil;
    for (AVFrameRateRange* range in supportedRanges) {
        if (range.maxFrameRate <= _frameRate && targetRange.maxFrameRate <= range.maxFrameRate) {
            targetRange = range;
        }
    }
    
    
    if (targetRange && [self.captureDevice lockForConfiguration:NULL]) {
        [self.captureDevice setActiveVideoMinFrameDuration:CMTimeMake(1, _frameRate)];
        [self.captureDevice setActiveVideoMaxFrameDuration:targetRange.maxFrameDuration];
        [self.captureDevice unlockForConfiguration];
    }
}

- (void)configurationSessionFront {
    dispatch_async(self.sessionQueue, ^{
        self.captureDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
        
        if (self.videoDeviceInput) {
            [self.session removeInput:self.videoDeviceInput];
        }
        
        NSError *error = nil;
        self.videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:&error];
        if (!self.videoDeviceInput)  {  NSLog(@"未找到设备");  }
        
        // === beginConfiguration ===
        [self.session beginConfiguration];
        [self configFrameDuration];
        if ([self.session canAddInput:self.videoDeviceInput]) {
            
            [self.session addInput:self.videoDeviceInput];
            if (self.videoDataOutput) {
                [self.session removeOutput:self.videoDataOutput];
            }
            
            //MARK :视频输出
            self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
            self.videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
            [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
            self.videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
            
            if ([self.session canAddOutput:self.videoDataOutput]) {
                
                [self.session addOutput:self.videoDataOutput];
                [self.captureDevice addObserver:self
                                     forKeyPath:@"adjustingFocus"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
                
                self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
                if (self.videoConnection.isVideoStabilizationSupported) {
                    self.videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
                }
                
                self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
            }
            else {
                NSLog(@"UdeskSDK：无法添加视频输入到会话");
            }
            
            if (self.imageDataOutput) {
                [self.session removeOutput:self.imageDataOutput];
            }
            // MARK：图片输出
            self.imageDataOutput = [[AVCaptureStillImageOutput alloc] init];
            if ([self.session canAddOutput:self.imageDataOutput]) {
                [self.session addOutput:self.imageDataOutput];
            }
            else {
                NSLog(@"UdeskSDK：图片输出 加入失败");
            }
            
            if (self.audioDataOutput) {
                [self.session removeOutput:self.audioDataOutput];
            }
            
            // MARK :音频输出
            self.audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            self.audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioCaptureDevice error:&error];
            if (!self.audioDeviceInput) {
                NSLog(@"UdeskSDK：不能创建音频 %@", error);
            }
            
            if ([self.session canAddInput:self.audioDeviceInput]) {
                [self.session addInput:self.audioDeviceInput];
            }
            
            self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
            [self.audioDataOutput setSampleBufferDelegate:self queue:self.audioDataOutputQueue];
            
            if ([self.session canAddOutput:self.audioDataOutput]) {
                [self.session addOutput:self.audioDataOutput];
            }
            self.audioConnection = [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
            [self.session commitConfiguration];
        }
    });
}

- (void)configurationPreviewLayer {
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (void)swapFrontAndBackCameras {
    
    CATransition *animation = [CATransition animation];
    animation.duration = .5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";

    NSArray *inputs = self.session.inputs;
    for (AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            if (position ==AVCaptureDevicePositionFront) {
                animation.subtype = kCATransitionFromLeft;
                [self configurationSession];
            }
            else {
                animation.subtype = kCATransitionFromRight;
                [self configurationSessionFront];
            }
            break;
        }
    }

    [self.previewLayer addAnimation:animation forKey:nil];
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    @synchronized (self)
    {
        if (!self.isCapturing) return;
        
        if (_writer == nil) {
            NSString *name = [NSString stringWithFormat:@"/%@.mp4",[self getVideoSaveFilePathString]];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
            _smallVideoPath = [paths objectAtIndex:0];
            _smallVideoPath = [_smallVideoPath stringByAppendingString:name];
            _recordURL = [NSURL fileURLWithPath:_smallVideoPath];
            
            _writer  = [[UdeskSmallVideoWriter alloc] initWithURL:_recordURL cropSize:[self udCropSize]];
            _writer.delegate = self;
        }
        
        CFRetain(sampleBuffer);
        
        if ([connection isEqual:self.videoConnection]) {
            @autoreleasepool {
                UIImage *frame = [UdeskVideoUtil convertSampleBufferRefToUIImage:sampleBuffer];
                [self.frames addObject:frame];
            }
            [_writer appendVideoBuffer:sampleBuffer];
        }
        else if ([connection isEqual:self.audioConnection]) {
            [_writer appendAudioBuffer:sampleBuffer];
        }
    }
    
    CFRelease(sampleBuffer);
}

- (void)smallVideoWriterDidFinishRecording:(UdeskSmallVideoWriter *)recorder status:(BOOL)isCancle {
    
    if (_duration < 1.0f) {
        NSLog(@"UdeskSDK：录制时间太短");
    }
    
    if (!isCancle && _duration >= 1.0f) {
        if (self.finishBlock)
        {
            long long size = [self getCacheFileSize:_smallVideoPath];
            long long videoSize = size / 1024;
            NSDictionary *info = @{@"videoURL":[_recordURL description],
                                   @"videoDuration":[NSString stringWithFormat:@"%.0f",_duration],
                                   @"videoSize":[NSString stringWithFormat:@"%lldkb",videoSize],
                                   @"videoFirstFrame":[self.frames firstObject]
                                   };
            self.finishBlock(info,self.finishReason);
        }
    }
    else {
        NSLog(@"UdeskSDK：用户手动取消录制操作");
    }
    
    self.isCapturing = NO;
    _writer = nil;
    _duration = 0.f;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if([keyPath isEqualToString:@"adjustingFocus"]) {
        
        BOOL adjustingFocus =[[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        if (adjustingFocus) {
            NSLog(@"UdeskSDK：对焦成功");
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - CustoMethod
- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++)
    {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for (AVCaptureDevice *device in devices) {
        
        if (device.position == position){
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

// NSTimers 调用事件
- (void)computeDuration:(NSTimer *)timer {
    
    if (self.isCapturing) {
        [self willChangeValueForKey:@"duration"];
        _duration += 0.1;
        [self didChangeValueForKey:@"duration"];
        
        if (_duration >= _maxDuration) {
            [self finishCaptureWithReason:UdeskRecorderFinishedReasonBeyondMaxDuration];
            [timer invalidate];
            NSLog(@"UdeskSDK：录制超时,结束录制");
        }
    }
}

// 录制结束
- (void)finishCaptureWithReason:(UdeskRecorderFinishedReason)reason {
    @synchronized (self)
    {
        if (self.isCapturing) {
            
            self.isCapturing = NO;
            [_durationTimer invalidate];
            dispatch_async(self.sessionQueue, ^{
                switch (reason) {
                    case UdeskRecorderFinishedReasonNormal:
                        [_writer finishRecording];
                        break;
                    case UdeskRecorderFinishedReasonCancle:
                        [_writer cancleRecording];
                        break;
                    case UdeskRecorderFinishedReasonBeyondMaxDuration:
                        [_writer finishRecording];
                        break;
                        
                    default:
                        break;
                }
                self.finishReason = reason;
            });
        }
    }
}

- (BOOL)setScaleFactor:(CGFloat)factor {
    
    [_captureDevice lockForConfiguration:nil];
    BOOL success = NO;
    if(_captureDevice.activeFormat.videoMaxZoomFactor > factor) {
        [_captureDevice rampToVideoZoomFactor:factor withRate:30.f];//平滑过渡
        success = YES;
    }
    [_captureDevice unlockForConfiguration];
    
    return success;
}

#pragma mark - ToolsMethod
- (NSString *)getVideoSaveFilePathString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    return nowTimeStr;
}

- (long long)getCacheFileSize:(NSString *)path {
    NSFileManager *fileMananger = [NSFileManager defaultManager];
    if ([fileMananger fileExistsAtPath:path]) {
        
        NSDictionary *dic = [fileMananger attributesOfItemAtPath:path error:nil];
        return [dic[@"NSFileSize"] longLongValue];
    }
    return 0;
}

// MARK: 焦距改变
- (void)setFocusPoint:(CGPoint)point {
    if (self.captureDevice.isFocusPointOfInterestSupported) {
        NSError *error = nil;
        [self.captureDevice lockForConfiguration:&error];
        /*****必须先设定聚焦位置，在设定聚焦方式******/
        //聚焦点的位置
        if ([self.captureDevice isFocusPointOfInterestSupported]) {
            [self.captureDevice setFocusPointOfInterest:point];
        }
        
        // 聚焦模式
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        else {
            NSLog(@"UdeskSDK：聚焦模式修改失败");
        }
        
        [self.captureDevice unlockForConfiguration];
    }
}

//清除记录
- (void)removeSmallVideoCache {
    
    NSFileManager *fileMananger = [NSFileManager defaultManager];
    if ([fileMananger fileExistsAtPath:_smallVideoPath]) {
        [fileMananger removeItemAtPath:_smallVideoPath error:nil];
    }
}

- (AVCaptureSessionPreset)customSessionPreset {
    
    switch ([UdeskSDKConfig customConfig].smallVideoResolution) {
        case UDSmallVideoResolutionType640x480:
            return AVCaptureSessionPreset640x480;
            break;
        case UDSmallVideoResolutionType1280x720:
            return AVCaptureSessionPreset1280x720;
            break;
        case UDSmallVideoResolutionType1920x1080:
            return AVCaptureSessionPreset1920x1080;
            break;
        case UDSmallVideoResolutionTypePhoto:
            return AVCaptureSessionPresetPhoto;
            break;
            
        default:
            break;
    }
}

- (CGSize)udCropSize {
    
    switch ([UdeskSDKConfig customConfig].smallVideoResolution) {
        case UDSmallVideoResolutionType640x480:
            return CGSizeMake(480, 640);
            break;
        case UDSmallVideoResolutionType1280x720:
            return CGSizeMake(720, 1280);
            break;
        case UDSmallVideoResolutionType1920x1080:
            return CGSizeMake(1080, 1920);
            break;
        case UDSmallVideoResolutionTypePhoto:
            return CGSizeMake(1080, 1920);
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    [_captureDevice removeObserver:self forKeyPath:@"adjustingFocus"];
    
    if (_session){
        _session = nil;
    }
    
    if (_captureDevice){
        _captureDevice = nil;
    }
}

@end
