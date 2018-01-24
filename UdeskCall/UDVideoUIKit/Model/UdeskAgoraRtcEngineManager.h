//
//  UdeskAgoraRtcEngineManager.h
//  UdeskSDK
//
//  Created by xuchen on 2017/11/28.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

@protocol UdeskAgoraRtcEngineManagerDelegate <NSObject>

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid;
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSString *)uid;

- (void)networkConnectionDidNormal;
- (void)networkConnectionDidLost;

@end

@interface UdeskAgoraRtcEngineManager : NSObject

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, weak  ) id<UdeskAgoraRtcEngineManagerDelegate> delegate;

@property (nonatomic, strong) UIView *localVideo;
@property (nonatomic, strong) UIView *remoteVideo;
@property (nonatomic, strong) UILabel *durationLabel;

+ (instancetype)shared;

//挂断
- (void)hangup;

@end
