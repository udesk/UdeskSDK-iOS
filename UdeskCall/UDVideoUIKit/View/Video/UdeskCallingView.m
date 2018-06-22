//
//  UdeskCallingView.m
//  UdeskSDK
//
//  Created by xuchen on 2017/11/30.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskCallingView.h"
#import "UdeskAgoraRtcEngineManager.h"
#import "UdeskVideoBundleHelper.h"
#import "UdeskFloatWindow.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>

@interface UdeskCallingView()<WBFloatWindowProtcol,UdeskAgoraRtcEngineManagerDelegate>{
    
    NSTimer *_videoTimer;
    NSInteger _seconds;
    CTCallCenter *_callCenter;
    
    NSTimer *_disconnectTimer;
    NSInteger _disconnectTime;
}

@end

@implementation UdeskCallingView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupUI];
    [self setupCallManager];
    [self registerTelephonyEvent];
}

- (void)registerTelephonyEvent {
    _callCenter = [[CTCallCenter alloc] init];
    __weak __typeof(self) weakSelf = self;
    _callCenter.callEventHandler = ^(CTCall *call) {
        if ([call.callState isEqualToString:CTCallStateConnected]) {
            [weakSelf hangUpAction:nil];
        }
    };
}

- (void)setupUI {
    
    self.remotoVideoView.frame = [[UIScreen mainScreen] bounds];
    self.waitAcceptLabel.hidden = self.hiddenWaitAcceptLabel;
    self.durationLabel.hidden = YES;
    self.durationLabel.text = @"00:00:00";
    
    self.waitAcceptLabel.text = UVCLocalizedString(@"uvc_wait_accpet");
    
    [self.switchCameraButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoSwitchCamera.png")] forState:UIControlStateNormal];
    
    [self.microphoneButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoMicrophone.png")] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoMicrophoneHigh.png")] forState:UIControlStateNormal];
    [self.microphoneButton setTitle:UVCLocalizedString(@"uvc_microphone") forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor colorWithRed:0.063f  green:0.525f  blue:1 alpha:1] forState:UIControlStateNormal];
    [self layoutButton:self.microphoneButton space:10];
    
    [self.cameraButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoCamera.png")] forState:UIControlStateSelected];
    [self.cameraButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoCameraHigh.png")] forState:UIControlStateNormal];
    [self.cameraButton setTitle:UVCLocalizedString(@"uvc_camera") forState:UIControlStateNormal];
    [self.cameraButton setTitleColor:[UIColor colorWithRed:0.063f  green:0.525f  blue:1 alpha:1] forState:UIControlStateNormal];
    [self layoutButton:self.cameraButton space:30];
    
    [self.speakerButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoSpeaker.png")] forState:UIControlStateSelected];
    [self.speakerButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoSpeakerHigh.png")] forState:UIControlStateNormal];
    [self.speakerButton setTitle:UVCLocalizedString(@"uvc_speaker") forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:[UIColor colorWithRed:0.063f  green:0.525f  blue:1 alpha:1] forState:UIControlStateNormal];
    [self layoutButton:self.speakerButton space:10];
    
    [self.putWayButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoPutWay.png")] forState:UIControlStateNormal];
    [self.putWayButton setTitle:UVCLocalizedString(@"uvc_put_way") forState:UIControlStateNormal];
    [self layoutButton:self.putWayButton space:10];
    
    [self.hangUpButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoHangUp.png")] forState:UIControlStateNormal];
}

- (void)layoutButton:(UIButton *)button space:(CGFloat)space {
    
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = button.imageView.frame.size.width;
    CGFloat imageHeight = button.imageView.frame.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = button.titleLabel.intrinsicContentSize.width;
        labelHeight = button.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = button.titleLabel.frame.size.width;
        labelHeight = button.titleLabel.frame.size.height;
    }
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
    
    // 4. 赋值
    button.titleEdgeInsets = labelEdgeInsets;
    button.imageEdgeInsets = imageEdgeInsets;
}

//切换摄像头
- (IBAction)switchCameraAction:(id)sender {
    
    [[UdeskAgoraRtcEngineManager shared].agoraKit switchCamera];
}

//本地麦克风
- (IBAction)microphoneAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self setButtonTitleColor:sender];
    [[UdeskAgoraRtcEngineManager shared].agoraKit muteLocalAudioStream:sender.selected];
}

//本地摄像头
- (IBAction)cameraAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self setButtonTitleColor:sender];
    [[UdeskAgoraRtcEngineManager shared].agoraKit muteLocalVideoStream:sender.selected];
    _localVideoView.hidden = sender.selected;
}

//扬声器
- (IBAction)speakerAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self setButtonTitleColor:sender];
    [[UdeskAgoraRtcEngineManager shared].agoraKit setDefaultAudioRouteToSpeakerphone:!sender.selected];
    [[UdeskAgoraRtcEngineManager shared].agoraKit setEnableSpeakerphone:!sender.selected];
}

//收起
- (IBAction)putWayAction:(id)sender {
    
    [self enlargeShrink:YES];
    [[UdeskFloatWindow floatWindow] showView:self delegate:self];
}

- (void)enlargeShrink:(BOOL)hidden {
    
    self.localVideoView.hidden = hidden;
    self.switchCameraButton.hidden = hidden;
    self.hangUpButton.hidden = hidden;
    self.controlButtons.hidden = hidden;
    self.durationLabel.hidden = hidden;
    self.microphoneButton.hidden = hidden;
    self.cameraButton.hidden = hidden;
    self.speakerButton.hidden = hidden;
    self.putWayButton.hidden = hidden;
    self.hangUpButton.hidden = hidden;
}

- (void)recoverFloatWindow:(UdeskFloatWindow *)floatWindow{
    
    floatWindow.showView.center = floatWindow.dragView.center;
    [UIView animateWithDuration:0.35 animations:^{
        floatWindow.dragView.frame = [[UIScreen mainScreen] bounds];
        floatWindow.showView.frame = [[UIScreen mainScreen] bounds];
        self.remotoVideoView.frame = [[UIScreen mainScreen] bounds];
        [[UIApplication sharedApplication].delegate.window addSubview:floatWindow.showView];
    } completion:^(BOOL finished) {
        [self enlargeShrink:NO];
    }];
}

//挂断
- (IBAction)hangUpAction:(id)sender {
    
    [[UdeskAgoraRtcEngineManager shared] hangup];
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    } completion:^(BOOL finished) {
        [self callEnded];
    }];
}

- (void)setButtonTitleColor:(UIButton *)button {
    
    if (!button.selected) {
        [button setTitleColor:[UIColor colorWithRed:0.063f  green:0.525f  blue:1 alpha:1] forState:UIControlStateNormal];
    }
    else {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)setupCallManager {
    
    //设置本地图像
    [UdeskAgoraRtcEngineManager shared].localVideo = self.localVideoView;
    [UdeskAgoraRtcEngineManager shared].remoteVideo = self.remotoVideoView;
    [UdeskAgoraRtcEngineManager shared].durationLabel = self.durationLabel;
    [UdeskAgoraRtcEngineManager shared].delegate = self;
}

#pragma mark - UdeskVideoCallManagerDelegate
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid {
    
    self.waitAcceptLabel.hidden = YES;
    self.durationLabel.hidden = NO;

    _videoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordTimeAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_videoTimer forMode:NSRunLoopCommonModes];
}

- (void)recordTimeAction {
    self.durationLabel.text = [self getVideoDuration:_seconds++];
}

//对方离开视频
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSString *)uid {
    
    [self callEnded];
    [UIView animateWithDuration:0.35 animations:^{
        dispatch_async(dispatch_get_main_queue(), ^{
          self.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        });
    }];
}

//网络连接丢失回调
- (void)networkConnectionDidNormal {
    
    _disconnectTime = 0;
    [_disconnectTimer invalidate];
    _disconnectTimer = nil;
}

- (void)networkConnectionDidLost {
    NSLog(@"UdeskCall：网络断开");
    _disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(disconnectTimeAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_disconnectTimer forMode:NSRunLoopCommonModes];
}

- (void)disconnectTimeAction {
    
    _disconnectTime++;
    if (_disconnectTime == 30) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:UVCLocalizedString(@"uvc_disconnected_network")
                                   delegate:nil
                          cancelButtonTitle:UVCLocalizedString(@"uvc_close")
                          otherButtonTitles:nil] show];
#pragma clang diagnostic pop
        
        [_disconnectTimer invalidate];
        _disconnectTimer = nil;
        [self callEnded];
    }
}

//时间
- (NSString *)getVideoDuration:(NSInteger)seconds {
    
    NSString *hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSString *minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    NSString *second = [NSString stringWithFormat:@"%02ld",seconds%60];
    
    NSString *time = [NSString stringWithFormat:@"%@:%@:%@",hour,minute,second];
    
    return time;
}

//通话结束
- (void)callEnded {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_videoTimer invalidate];
        _videoTimer = nil;
        [_localVideoView removeFromSuperview];
        [_remotoVideoView removeFromSuperview];
        [_durationLabel removeFromSuperview];
        
        //屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        if (self.callEndedBlock) {
            self.callEndedBlock();
        }
    });
}

+ (UdeskCallingView *)instanceCallingView {
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"UdeskCallingView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

@end
