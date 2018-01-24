//
//  UdeskCallingView.h
//  UdeskSDK
//
//  Created by xuchen on 2017/11/30.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskCallingView : UIView

@property (strong, nonatomic) IBOutlet UIView *remotoVideoView;
@property (strong, nonatomic) IBOutlet UIView *localVideoView;
@property (strong, nonatomic) IBOutlet UIButton *switchCameraButton;

@property (strong, nonatomic) IBOutlet UIView *controlButtons;
@property (strong, nonatomic) IBOutlet UIButton *microphoneButton;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIButton *speakerButton;
@property (strong, nonatomic) IBOutlet UIButton *putWayButton;
@property (strong, nonatomic) IBOutlet UIButton *hangUpButton;

@property (strong, nonatomic) IBOutlet UILabel *waitAcceptLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

@property (nonatomic, assign) BOOL hiddenWaitAcceptLabel;

@property (nonatomic, copy) void(^callEndedBlock)(void);

+ (UdeskCallingView *)instanceCallingView;

@end
