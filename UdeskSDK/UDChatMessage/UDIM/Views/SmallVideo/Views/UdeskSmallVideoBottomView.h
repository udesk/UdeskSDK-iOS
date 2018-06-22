//
//  UdeskSmallVideoBottomView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskSmallVideoBottomView;
@protocol UdeskSmallVideoBottomViewDelegate <NSObject>

- (void)udSmallVideo:(UdeskSmallVideoBottomView *)smallVideoView zoomLens:(CGFloat)scaleNum;

- (void)udSmallVideo:(UdeskSmallVideoBottomView *)smallVideoView isRecording:(BOOL)recording;

- (void)udSmallVideo:(UdeskSmallVideoBottomView *)smallVideoView captureCurrentFrame:(BOOL)capture;

@end

@interface UdeskSmallVideoBottomView : UIView

@property (nonatomic, weak  )id <UdeskSmallVideoBottomViewDelegate> delegate;

@property (nonatomic, assign) NSInteger duration;

@end
