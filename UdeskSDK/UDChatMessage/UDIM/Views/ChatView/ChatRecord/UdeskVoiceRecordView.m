//
//  UdeskVoiceRecodView.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskVoiceRecordView.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskBundleUtils.h"

@interface UdeskVoiceRecordView()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *microPhoneImageView;
@property (nonatomic, strong) UIImageView *cancelRecordImageView;
@property (nonatomic, strong) UIImageView *volumeImageView;
@property (nonatomic, strong) UIImageView *tooShortView;

@end

@implementation UdeskVoiceRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor colorWithRed:0.459f  green:0.459f  blue:0.459f alpha:.9];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5;
    
    //提示信息
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 117.0, 125.0, 21.0)];
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.font = [UIFont systemFontOfSize:13];
    _tipLabel.layer.masksToBounds = YES;
    _tipLabel.layer.cornerRadius = 4;
    _tipLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.text = getUDLocalizedString(@"udesk_slide_up_to_cancel");
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_tipLabel];
    
    _microPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(38.0, 37.5, 38, 61)];
    _microPhoneImageView.image = [UIImage udDefaultVoiceSpeakImage];
    _microPhoneImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _microPhoneImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:_microPhoneImageView];
    
    _volumeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(90.0, 14.0, 38, 100)];
    _volumeImageView.image = [UIImage imageWithContentsOfFile:getUDBundlePath(@"udRecordingVolume001.png")];
    _volumeImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _volumeImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:_volumeImageView];
    
    _cancelRecordImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-38)/2, 37.5, 38, 52)];
    _cancelRecordImageView.image = [UIImage udDefaultVoiceRevokeImage];
    _cancelRecordImageView.hidden = YES;
    _cancelRecordImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _cancelRecordImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:_cancelRecordImageView];
    
    _tooShortView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-8)/2, 37.5, 8, 62)];
    _tooShortView.image = [UIImage udDefaultVoiceTooShortImage];
    _tooShortView.hidden = YES;
    _tooShortView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _tooShortView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:_tooShortView];
}

- (void)startRecordingAtView:(UIView *)view {
    CGPoint center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0-44);
    self.center = center;
    [view addSubview:self];
    [self configRecoding:YES];
}

- (void)pauseRecord {
    [self configRecoding:YES];
    self.tipLabel.backgroundColor = [UIColor clearColor];
    self.tipLabel.text = getUDLocalizedString(@"udesk_slide_up_to_cancel");
}

- (void)resaueRecord {
    [self configRecoding:NO];
    self.tipLabel.backgroundColor = [UIColor colorWithRed:0.62f  green:0.22f  blue:0.212f alpha:1];
    self.tipLabel.text = getUDLocalizedString(@"udesk_release_up_to_cancel");
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

/** 录音时间太短 */
- (void)speakDurationTooShort {
    
    self.microPhoneImageView.hidden = YES;
    self.volumeImageView.hidden = YES;
    self.cancelRecordImageView.hidden = YES;
    self.tooShortView.hidden = NO;
    self.tipLabel.backgroundColor = [UIColor clearColor];
    self.tipLabel.text = getUDLocalizedString(@"udesk_message_too_short");
}

- (void)configRecoding:(BOOL)recording {
    self.microPhoneImageView.hidden = !recording;
    self.volumeImageView.hidden = !recording;
    self.cancelRecordImageView.hidden = recording;
}

- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower {
    NSString *imageName = @"udRecordingVolume002.png";
    
    if (peakPower>0&&peakPower<=10) {
        
        imageName = @"udRecordingVolume001.png";
    } else if (peakPower>10&&peakPower<=35){
        
        imageName = @"udRecordingVolume002.png";
    } else if (peakPower>35&&peakPower<=50){
        
        imageName = @"udRecordingVolume003.png";
    } else if (peakPower>50&&peakPower<=60){
        
        imageName = @"udRecordingVolume004.png";
    } else if (peakPower>60&&peakPower<=70){
        
        imageName = @"udRecordingVolume005.png";
    } else if (peakPower>70&&peakPower<=75){
        
        imageName = @"udRecordingVolume006.png";
    } else if (peakPower>75&&peakPower<=80){
        
        imageName = @"udRecordingVolume007.png";
    } else if (peakPower>80&&peakPower<=90){
        
        imageName = @"udRecordingVolume008.png";
    } else{
        imageName = @"udRecordingVolume008.png";
    }
    
    self.volumeImageView.image = [UIImage imageWithContentsOfFile:getUDBundlePath(imageName)];
}

- (void)setPeakPower:(CGFloat)peakPower {
    _peakPower = peakPower;
    [self configRecordingHUDImageWithPeakPower:peakPower];
}

@end
