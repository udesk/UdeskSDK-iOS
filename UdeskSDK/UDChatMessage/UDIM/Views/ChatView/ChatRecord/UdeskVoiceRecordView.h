//
//  UdeskVoiceRecodView.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskVoiceRecordView : UIView

@property (nonatomic, assign) CGFloat peakPower;

/*** 开始显示录音 */
- (void)startRecordingAtView:(UIView *)view;

/** 提示取消录音 */
- (void)pauseRecord;

/** 提示继续录音 */
- (void)resaueRecord;

/** 停止录音 */
- (void)stopRecordCompled:(void(^)(BOOL fnished))compled;

/** 取消录音 */
- (void)cancelRecordCompled:(void(^)(BOOL fnished))compled;

/** 录音时间太短 */
- (void)speakDurationTooShort;

@end
 
