//
//  UdeskSmallVideoManager.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskVideoUtil.h"

typedef NS_ENUM(NSInteger, UdeskRecorderFinishedReason){
    UdeskRecorderFinishedReasonNormal,//主动结束
    UdeskRecorderFinishedReasonCancle,//取消
    UdeskRecorderFinishedReasonBeyondMaxDuration//超时结束
};

typedef void (^UdeskFinishRecordingBlock)(NSDictionary *info, UdeskRecorderFinishedReason finishReason);

@interface UdeskSmallVideoManager : NSObject

@property (nonatomic, copy  ) UdeskFinishRecordingBlock finishBlock;
//照相捕捉
@property (nonatomic, strong) AVCaptureStillImageOutput *imageDataOutput;
//视频捕捉画面宽高
@property (nonatomic, assign) CGSize cropSize;
//视频最长时间
@property (nonatomic, assign) NSTimeInterval maxDuration;

//视频持续时间
@property (nonatomic, assign, readonly) NSTimeInterval duration;
//本地视频地址
@property (nonatomic, strong, readonly) NSURL *recordURL;

+ (UdeskSmallVideoManager *)sharedManager;

- (AVCaptureVideoPreviewLayer *)previewLayer;

//setup
- (void)setup;

/** 开启摄像头 */
- (void)startSession;
/** 关闭摄像头 */
- (void)stopSession;

/** 开始视频捕捉 */
- (void)startCapture;
/** 结束视频捕捉 */
- (void)stopCapture;
/** 取消视频捕捉 */
- (void)cancelCapture;

/** 摄像头翻转 */
- (void)swapFrontAndBackCameras;

/** 设置缩放比例 */
- (BOOL)setScaleFactor:(CGFloat)factor;
/** 焦距改变 */
- (void)setFocusPoint:(CGPoint)point;

//清除记录
- (void)removeSmallVideoCache;

@end
