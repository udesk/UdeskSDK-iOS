//
//  UdeskVoiceRecodView.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UdeskVoiceRecordViewDelegate <NSObject>

- (void)finishRecordedWithVoicePath:(NSString *)voicePath withAudioDuration:(NSString *)duration;

- (void)speakDurationTooShort;

@end

@interface UdeskVoiceRecordView : UIView

@property (nonatomic, weak) id <UdeskVoiceRecordViewDelegate> delegate;

@end
 
