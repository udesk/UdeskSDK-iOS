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
#import "UdeskVoiceRecordHelper.h"

@interface UdeskVoiceRecordView()<AVAudioRecorderDelegate,MZTimerLabelDelegate> {

    UILabel  *tipLabel;
    UIButton *deleteButton;
    UIButton *recordButton;
    UdeskSpectrumView *spectrumView;
    BOOL        isInDeleteButton;
    float  recordTime;
}

@property (nonatomic, strong) UdeskVoiceRecordHelper    *voiceRecordHelper;//管理录音工具对象


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

        @udWeakify(self);
        spectrumView.itemLevelCallback = ^() {
            @udStrongify(self);
            self.voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
                
                weakSpectrum.level = peakPowerForChannel;
            };
            
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

-(void)timerLabel:(UdeskTimerLabel*)timerLabel countingTo:(NSTimeInterval)time timertype:(UDTimerLabelType)timerType {
    
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
        
        isInDeleteButton = YES;
    }
    else {
        spectrumView.hidden = NO;
        tipLabel.hidden = YES;
        tipLabel.text = getUDLocalizedString(@"udesk_hold_to_talk");
        [deleteButton setImage:[UIImage ud_defaultDeleteRecordVoiceImage] forState:UIControlStateNormal];
        
        isInDeleteButton = NO;
    }
    
}

- (void)recordCancel:(UIButton *)button
{
    
    if (isInDeleteButton) {
        
        [spectrumView.stopwatch reset];
        [spectrumView.stopwatch pause];
        
        spectrumView.hidden = YES;
        tipLabel.text = getUDLocalizedString(@"udesk_hold_to_talk");
        tipLabel.hidden = NO;
        [deleteButton setImage:[UIImage ud_defaultDeleteRecordVoiceImage] forState:UIControlStateNormal];
        
        [self.voiceRecordHelper cancelledDeleteWithCompletion:nil];
    }
    else {

        [self finishRecord];
    }
}

- (void)recordStart:(UIButton *)button
{

    if ([self canRecord]) {
        
        @udWeakify(self);
        [self.voiceRecordHelper prepareRecordingCompletion:^BOOL{
            
            @udStrongify(self);
            [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:nil];
            
            
            return YES;
        }];
        
        spectrumView.hidden = NO;
        [spectrumView.stopwatch start];
        tipLabel.hidden = YES;
    }
    
}

- (void)recordFinish:(UIButton *)button
{
    
    spectrumView.hidden = YES;
    tipLabel.text = getUDLocalizedString(@"udesk_hold_to_talk");
    tipLabel.hidden = NO;
    [deleteButton setImage:[UIImage ud_defaultDeleteRecordVoiceImage] forState:UIControlStateNormal];
    if (isInDeleteButton) {
        
        [spectrumView.stopwatch reset];
        [spectrumView.stopwatch pause];
        
        [self.voiceRecordHelper cancelledDeleteWithCompletion:nil];
    }
    else {
        
        [self finishRecord];
    }
}

- (void)finishRecord {
    
    [spectrumView.stopwatch pause];
    
    if (recordTime >1) {
        
        @try {
            @udWeakify(self);
            [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
                @udStrongify(self);
                @try {
                    [self.delegate finishRecordedWithVoicePath:self.voiceRecordHelper.recordPath withAudioDuration:[NSString stringWithFormat:@"%@", self.voiceRecordHelper.recordDuration]];
                } @catch (NSException *exception) {
                } @finally {
                }
            }];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    if (recordTime <=1) {
        @try {
            
            [self.delegate speakDurationTooShort];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }

    [spectrumView.stopwatch reset];
}

//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if (ud_isIOS7)
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
                        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        [[[UIAlertView alloc] initWithTitle:nil
                                                    message:getUDLocalizedString(@"udesk_microphone_denied")
                                                   delegate:nil
                                          cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                                          otherButtonTitles:nil] show];
#pragma clang diagnostic pop
                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}

#pragma mark - 录制语音
- (UdeskVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        
        @udWeakify(self);
        _voiceRecordHelper = [[UdeskVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            @udStrongify(self);
            [self finishRecord];
        };

        _voiceRecordHelper.maxRecordTime = UdeskVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}

@end
