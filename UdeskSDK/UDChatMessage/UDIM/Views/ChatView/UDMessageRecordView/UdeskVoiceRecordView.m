//
//  UdeskVoiceRecodView.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/23.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskVoiceRecordView.h"
#import "UdeskSpectrumView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+UdeskSDK.h"
#import "UdeskFoundationMacro.h"
#import "UdeskSDKConfig.h"
#import "UdeskUtils.h"

@interface UdeskVoiceRecordView()<AVAudioRecorderDelegate,MZTimerLabelDelegate> {

    UILabel  *tipLabel;
    UIButton *deleteButton;
    UIButton *recordButton;
    UdeskSpectrumView *spectrumView;
    BOOL        isInDeleteButton;
    NSString *recordDuration;
    NSString *audioPath;
    float  recordTime;
}

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机


@end

@implementation UdeskVoiceRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UdeskSDKConfig sharedConfig].sdkStyle.recordViewColor;
        
        recordTime = 0.0f;
        
        spectrumView = [[UdeskSpectrumView alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-170)/2,32,150, 20)];
        spectrumView.stopwatch.delegate = self;
        __weak UdeskSpectrumView * weakSpectrum = spectrumView;
        __weak typeof(self) weakself = self;
        spectrumView.itemLevelCallback = ^() {
            
            [weakself.audioRecorder updateMeters];
            //取得第一个通道的音频，音频强度范围时-160到0
            float power= [weakself.audioRecorder averagePowerForChannel:0];
            weakSpectrum.level = power;
        };
        
        spectrumView.hidden = YES;
        
        [self addSubview:spectrumView];
        
        tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, CGRectGetMaxX(self.frame),30)];
        tipLabel.textColor = [UIColor grayColor];
        tipLabel.font = [UIFont systemFontOfSize:18];
        tipLabel.text = getUDLocalizedString(@"udesk_hold_to_talk");
        [tipLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:tipLabel];
        
        recordButton = [[UIButton alloc]initWithFrame:CGRectMake((UD_SCREEN_WIDTH-100)/2, 77, 100, 100)];
        
        [recordButton setBackgroundImage:[UIImage ud_defaultRecordVoiceImage] forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[UIImage ud_defaultRecordVoiceHighImage] forState:UIControlStateHighlighted];
        
        //开始
        [recordButton addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
        //完成
        [recordButton addTarget:self action:@selector(recordFinish:) forControlEvents:UIControlEventTouchUpInside];
        //取消
        [recordButton addTarget:self action:@selector(recordCancel:) forControlEvents: UIControlEventTouchUpOutside];
        //移出
        [recordButton addTarget:self action:@selector(btnTouchUp:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [recordButton addTarget:self action:@selector(btnTouchUp:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
        
        [self addSubview:recordButton];
        
        
        deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(UD_SCREEN_WIDTH-40-25, 25, 40, 40)];
        
        [deleteButton setImage:[UIImage ud_defaultDeleteRecordVoiceImage] forState:UIControlStateNormal];
        
        [self addSubview:deleteButton];
    }
    return self;
}

-(void)timerLabel:(UdeskTimerLabel*)timerLabel countingTo:(NSTimeInterval)time timertype:(MZTimerLabelType)timerType {
    
    if (!isnan(time)) {
        recordTime = time;
    }
}

- (void)btnTouchUp:(UIButton *)sender withEvent:(UIEvent *)event {
    
    [recordButton setBackgroundImage:[UIImage ud_defaultRecordVoiceHighImage] forState:UIControlStateNormal];
    
    UITouch *touch = [[event allTouches] anyObject];
    
    CGPoint location = [touch locationInView:sender];
    
    CGRect newButton = CGRectMake(location.x+sender.frame.origin.x, location.y+sender.frame.origin.y,100, 100);
    
    BOOL test1 = CGRectIntersectsRect(deleteButton.frame,newButton);
    
    if (test1) {
        spectrumView.hidden = YES;
        tipLabel.hidden = NO;
        tipLabel.text = getUDLocalizedString(@"udesk_release_to_cancel");
        [deleteButton setImage:[UIImage ud_defaultDeleteRecordVoiceHighImage] forState:UIControlStateNormal];
        
        if([self.audioRecorder isRecording]){
            isInDeleteButton = YES;
        }
    }
    else {
        spectrumView.hidden = NO;
        tipLabel.hidden = YES;
        tipLabel.text = getUDLocalizedString(@"udesk_hold_to_talk");
        [deleteButton setImage:[UIImage ud_defaultDeleteRecordVoiceImage] forState:UIControlStateNormal];
        if([self.audioRecorder isRecording]){
            isInDeleteButton = NO;
        }
    }
    
}

- (void)recordCancel:(UIButton *)button
{
    
    if (isInDeleteButton) {
        
        [spectrumView.stopwatch reset];
        [spectrumView.stopwatch pause];
        
        [self.audioRecorder stop];
        spectrumView.hidden = YES;
        tipLabel.text = getUDLocalizedString(@"udesk_hold_to_talk");
        tipLabel.hidden = NO;
        [deleteButton setImage:[UIImage ud_defaultDeleteRecordVoiceImage] forState:UIControlStateNormal];
    }
    else {
        
        if ([self.audioRecorder isRecording]) {
            [self finishRecord];
        }
    }
}

- (void)recordStart:(UIButton *)button
{
    if ([self canRecord]) {
        
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
        {
            //7.0第一次运行会提示，是否允许使用麦克风
            AVAudioSession *session = [AVAudioSession sharedInstance];
            NSError *sessionError;
            //AVAudioSessionCategoryPlayAndRecord用于录音和播放
            [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
            if(session == nil)
                NSLog(@"Error creating session: %@", [sessionError description]);
            else
                [session setActive:YES error:nil];
        }
        
        if (![self.audioRecorder isRecording]) {
            
            [self.audioRecorder record];
            spectrumView.hidden = NO;
            [spectrumView.stopwatch start];
            tipLabel.hidden = YES;
        }
    }
    
}

- (void)recordFinish:(UIButton *)button
{
    
    if ([self.audioRecorder isRecording]) {
        [self finishRecord];
    }
}

- (void)finishRecord {
    
    [self.audioRecorder stop];
    [spectrumView.stopwatch pause];
    spectrumView.hidden = YES;
    tipLabel.hidden = NO;

    if (recordTime>1.1f && recordTime < 60.0f) {
        
        @try {
            [self.delegate finishRecordedWithAudioPath:audioPath withAudioDuration:[NSString stringWithFormat:@"%.f", recordTime]];
        } @catch (NSException *exception) {
        } @finally {
        }
    }

    if (recordTime>60.0f) {
        
        @try {
            [self.delegate finishRecordedWithAudioPath:audioPath withAudioDuration:[NSString stringWithFormat:@"%.f", recordTime]];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
    
    if (recordTime<1.1f) {
        @try {
            [self.delegate speakDurationTooShort];
        } @catch (NSException *exception) {
        } @finally {
        }
    }

    [spectrumView.stopwatch reset];
}

//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:nil
                                                    message:getUDLocalizedString(@"udesk_microphone_denied")
                                                   delegate:nil
                                          cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                                          otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}


/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}


/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath {
    
    //  在Documents目录下创建一个名为FileData的文件夹
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"UdeskAudioData"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir))
        
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
    }
    
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@myRecord.aac",[[NSUUID UUID] UUIDString]]];
    audioPath = path;
    NSURL *url=[NSURL fileURLWithPath:path];
    return url;
}

- (NSString *)getVoiceDuration:(NSString*)recordPath {
    NSError *error = nil;
    AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordPath] error:&error];
    if (error) {
        return @"";
    } else {
        return [NSString stringWithFormat:@"%.f", play.duration];
    }
}

@end
