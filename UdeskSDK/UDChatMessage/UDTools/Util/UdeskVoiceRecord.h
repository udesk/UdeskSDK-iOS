//
//  UdeskVoiceRecord.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef BOOL(^UDPrepareRecorderCompletion)(void);
typedef void(^UDStartRecorderCompletion)(void);
typedef void(^UDStopRecorderCompletion)(void);
typedef void(^UDTooShortRecorderFailue)(void);
typedef void(^UDPauseRecorderCompletion)(void);
typedef void(^UDResumeRecorderCompletion)(void);
typedef void(^UDCancellRecorderDeleteFileCompletion)(void);
typedef void(^UDRecordProgress)(float progress);
typedef void(^UDPeakPowerForChannel)(float peakPowerForChannel);

static CGFloat kUdeskVoiceRecorderTotalTime = 60;

@interface UdeskVoiceRecord : NSObject

/**
 *  录制语音
 */
@property (nonatomic, strong) AVAudioRecorder *recorder;

/**
 *  录音到最大时长callback结束录音
 */
@property (nonatomic, copy) UDStopRecorderCompletion maxTimeStopRecorderCompletion;
/**
 *  时间太短
 */
@property (nonatomic, copy) UDTooShortRecorderFailue tooShortRecorderFailue;
/**
 *  录音进度callback
 */
@property (nonatomic, copy) UDRecordProgress recordProgress;
/**
 *  分贝
 */
@property (nonatomic, copy) UDPeakPowerForChannel peakPowerForChannel;
/**
 *  语音文件地址
 */
@property (nonatomic, copy, readonly) NSString *recordPath;
/**
 *  语音时长
 */
@property (nonatomic, copy) NSString *recordDuration;
/**
 *  语音最长时间 默认60秒最大
 */
@property (nonatomic) float maxRecordTime;
/**
 *  当前语音时间
 */
@property (nonatomic, readonly) NSTimeInterval currentTimeInterval;

/**
 *  准备录音
 *
 *  @param completion 准备完成callback
 */
- (void)prepareRecordingCompletion:(UDPrepareRecorderCompletion)completion;
/**
 *  录音开始
 *
 *  @param startRecorderCompletion 录音开始callback
 */
- (void)startRecordingWithStartRecorderCompletion:(UDStartRecorderCompletion)startRecorderCompletion;
/**
 *  暂停录音
 *
 *  @param pauseRecorderCompletion 暂停callback
 */
- (void)pauseRecordingWithPauseRecorderCompletion:(UDPauseRecorderCompletion)pauseRecorderCompletion;
/**
 *  恢复录音
 *
 *  @param resumeRecorderCompletion 恢复callback
 */
- (void)resumeRecordingWithResumeRecorderCompletion:(UDResumeRecorderCompletion)resumeRecorderCompletion;
/**
 *  停止录音
 *
 *  @param stopRecorderCompletion 停止callback
 */
- (void)stopRecordingWithStopRecorderCompletion:(UDStopRecorderCompletion)stopRecorderCompletion;
/**
 *  取消录音
 *
 *  @param cancelledDeleteCompletion 取消callback
 */
- (void)cancelledDeleteWithCompletion:(UDCancellRecorderDeleteFileCompletion)cancelledDeleteCompletion;
/**
 *  录音失败
 *
 *  @param tooShortRecorderFailue tooShortRecorderFailue
 */
- (void)tooShortRecordWithFailue:(UDTooShortRecorderFailue)tooShortRecorderFailue;

@end
