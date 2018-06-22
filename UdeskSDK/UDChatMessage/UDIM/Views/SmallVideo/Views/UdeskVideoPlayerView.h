//
//  UdeskVideoPlayerView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskVideoPlayerView;

typedef enum : NSUInteger {
    UdeskVideoPlayerStatusUnknown,
    UdeskVideoPlayerStatusReadyToPlay,
    UdeskVideoPlayerStatusFailed,
    UdeskVideoPlayerStatusFinished
} UdeskVideoPlayerStatusEnum;

typedef enum : NSUInteger {
    UdeskVideoPlayerTimeString, // string 类型 00:004
    UdeskVideoPlayerTimeNum  // num 类型 4
} UdeskVideoPlayerTimeEnum;

@protocol UdeskVideoPlayerViewDelegate <NSObject>

@optional;
- (void)videoPlayerView:(UdeskVideoPlayerView *)playerView playerStatus:(UdeskVideoPlayerStatusEnum)status;
- (void)videoPlayerView:(UdeskVideoPlayerView *)playerView currentSecond:(CGFloat)second timeString:(NSString *)timeString;

@end


@interface UdeskVideoPlayerView : UIView

@property (nonatomic, weak)id <UdeskVideoPlayerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)url;

- (NSString *)videoDurationTime:(UdeskVideoPlayerTimeEnum)timeEnum ;//!< 获取总时长

- (void)play;
- (void)pause;
- (void)cyclePlayVideo;

@end
