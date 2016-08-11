//
//  UDVoiceRecordHUD.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskVoiceRecordHUD.h"
#import "UdeskFoundationMacro.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskUtils.h"      

@interface UdeskVoiceRecordHUD ()

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

@property (nonatomic, weak) UIImageView *tooShortRecordImageView;


@end

@implementation UdeskVoiceRecordHUD

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化视图
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor clearColor];
    if (!_microPhoneImageView) {
        UIImageView *microPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        microPhoneImageView.image = [UIImage ud_defaultVoiceSpeakImage];
        microPhoneImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        microPhoneImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:microPhoneImageView];
        _microPhoneImageView = microPhoneImageView;
    }
    
    if (!_recordingHUDImageView) {
        UIImageView *recordHUDImageView = [[UIImageView alloc] initWithFrame:CGRectMake(97.0, 14.0, 38, 100)];
        recordHUDImageView.image = [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_Recording_Signal001.png")];
        recordHUDImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        recordHUDImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:recordHUDImageView];
        _recordingHUDImageView = recordHUDImageView;
    }
    
    if (!_cancelRecordImageView) {
        UIImageView *cancelRecordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        cancelRecordImageView.image = [UIImage ud_defaultVoiceRevokeImage];
        cancelRecordImageView.hidden = YES;
        cancelRecordImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        cancelRecordImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:cancelRecordImageView];
        _cancelRecordImageView = cancelRecordImageView;
    }
    
    if (!_tooShortRecordImageView) {
        UIImageView *tooShortRecordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        tooShortRecordImageView.image = [UIImage ud_defaultVoiceTooShortImage];
        tooShortRecordImageView.hidden = YES;
        tooShortRecordImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        tooShortRecordImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:tooShortRecordImageView];
        _tooShortRecordImageView = tooShortRecordImageView;
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
    
    self.remindLabel.backgroundColor = UDRGBACOLOR(1.0f, 0.0f, 0.0f, 0.630);
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
    NSString *imageName = @"ud_Recording_Signal002.png";
    
    if (peakPower>0&&peakPower<=10) {
        
        imageName = @"ud_Recording_Signal001.png";
    } else if (peakPower>10&&peakPower<=35){
        
        imageName = @"ud_Recording_Signal002.png";
    } else if (peakPower>35&&peakPower<=50){
        
        imageName = @"ud_Recording_Signal003.png";
    } else if (peakPower>50&&peakPower<=60){
        
        imageName = @"ud_Recording_Signal004.png";
    } else if (peakPower>60&&peakPower<=70){
        
        imageName = @"ud_Recording_Signal005.png";
    } else if (peakPower>70&&peakPower<=75){
        
        imageName = @"ud_Recording_Signal006.png";
    } else if (peakPower>75&&peakPower<=80){
        
        imageName = @"ud_Recording_Signal007.png";
    } else if (peakPower>80&&peakPower<=90){
        
        imageName = @"ud_Recording_Signal008.png";
    } else{
        imageName = @"ud_Recording_Signal008.png";
    }
    
    self.recordingHUDImageView.image = [UIImage imageWithContentsOfFile:getUDBundlePath(imageName)];
}

- (void)setPeakPower:(CGFloat)peakPower {
    _peakPower = peakPower;
    [self configRecordingHUDImageWithPeakPower:peakPower];
}

- (void)tooShortRecord {
    
    self.microPhoneImageView.hidden = YES;
    self.recordingHUDImageView.hidden = YES;
    self.cancelRecordImageView.hidden = YES;
    self.tooShortRecordImageView.hidden = NO;
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
