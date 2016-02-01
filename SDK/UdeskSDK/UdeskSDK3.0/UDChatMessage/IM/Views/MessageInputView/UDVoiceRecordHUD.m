//
//  UDVoiceRecordHUD.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDVoiceRecordHUD.h"

@interface UDVoiceRecordHUD ()

/**
 *  录音提示文字
 */
@property (nonatomic, weak) UILabel *remindLabel;
/**
 *  录音话筒UI
 */
@property (nonatomic, weak) UIImageView *microPhoneImageView;
/**
 *  取消录音UI
 */
@property (nonatomic, weak) UIImageView *cancelRecordImageView;
/**
 *  音量UI
 */
@property (nonatomic, weak) UIImageView *recordingHUDImageView;


@end

@implementation UDVoiceRecordHUD

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化视图
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor blackColor];
    self.alpha = .6f;
    ViewRadius(self, 5);
    
    if (!_remindLabel) {
        UILabel *remindLabel= [[UILabel alloc] initWithFrame:CGRectMake(14.0, 117.0, 120.0, 21.0)];
        remindLabel.textColor = [UIColor whiteColor];
        remindLabel.font = [UIFont systemFontOfSize:13];
        remindLabel.layer.masksToBounds = YES;
        remindLabel.layer.cornerRadius = 4;
        remindLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        remindLabel.backgroundColor = [UIColor clearColor];
        remindLabel.text = @"手指上滑，取消发送";
        remindLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:remindLabel];
        _remindLabel = remindLabel;
    }
    
    if (!_microPhoneImageView) {
        UIImageView *microPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 28.0, 80, 80)];
        microPhoneImageView.image = [UIImage imageWithContentsOfFile:getMyBundlePath(@"speak.png")];
        microPhoneImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        microPhoneImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:microPhoneImageView];
        _microPhoneImageView = microPhoneImageView;
    }
    
    if (!_recordingHUDImageView) {
        UIImageView *recordHUDImageView = [[UIImageView alloc] initWithFrame:CGRectMake(97.0, 14.0, 38, 100)];
        recordHUDImageView.image = [UIImage imageWithContentsOfFile:getMyBundlePath(@"UDRecordingSignal001.png")];
        recordHUDImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        recordHUDImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:recordHUDImageView];
        _recordingHUDImageView = recordHUDImageView;
    }
    
    if (!_cancelRecordImageView) {
        UIImageView *cancelRecordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0, 20.0, 80, 80)];
        cancelRecordImageView.image = [UIImage imageWithContentsOfFile:getMyBundlePath(@"revoke.png")];
        cancelRecordImageView.hidden = YES;
        cancelRecordImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        cancelRecordImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:cancelRecordImageView];
        _cancelRecordImageView = cancelRecordImageView;
    }
}

- (void)startRecordingHUDAtView:(UIView *)view {
    CGPoint center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0-44);
    self.center = center;
    [view addSubview:self];
    [self configRecoding:YES];
}

- (void)pauseRecord {
    [self configRecoding:YES];
    self.remindLabel.backgroundColor = [UIColor clearColor];
    self.remindLabel.text = @"手指上滑，取消发送";
}

- (void)resaueRecord {
    [self configRecoding:NO];
    
    self.remindLabel.backgroundColor = RGBACOLOR(1.0f, 0.0f, 0.0f, 0.630);
    self.remindLabel.text = @"松开手指，取消发送";
}

- (void)stopRecordCompled:(void(^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

- (void)cancelRecordCompled:(void(^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

- (void)dismissCompled:(void(^)(BOOL fnished))compled {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
        compled(finished);
    }];
}

- (void)configRecoding:(BOOL)recording {
    self.microPhoneImageView.hidden = !recording;
    self.recordingHUDImageView.hidden = !recording;
    self.cancelRecordImageView.hidden = recording;
}

- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower {
    NSString *imageName = @"UDRecordingSignal002.png";
    
    if (peakPower>0&&peakPower<=10) {
        
        imageName = @"UDRecordingSignal001.png";
    } else if (peakPower>10&&peakPower<=35){
        
        imageName = @"UDRecordingSignal002.png";
    } else if (peakPower>35&&peakPower<=50){
        
        imageName = @"UDRecordingSignal003.png";
    } else if (peakPower>50&&peakPower<=60){
        
        imageName = @"UDRecordingSignal004.png";
    } else if (peakPower>60&&peakPower<=70){
        
        imageName = @"UDRecordingSignal005.png";
    } else if (peakPower>70&&peakPower<=75){
        
        imageName = @"UDRecordingSignal006.png";
    } else if (peakPower>75&&peakPower<=80){
        
        imageName = @"UDRecordingSignal007.png";
    } else if (peakPower>80&&peakPower<=90){
        
        imageName = @"UDRecordingSignal008.png";
    } else{
        imageName = @"UDRecordingSignal008.png";
    }
    
    self.recordingHUDImageView.image = [UIImage imageWithContentsOfFile:getMyBundlePath(imageName)];
}

- (void)setPeakPower:(CGFloat)peakPower {
    _peakPower = peakPower;
    [self configRecordingHUDImageWithPeakPower:peakPower];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
