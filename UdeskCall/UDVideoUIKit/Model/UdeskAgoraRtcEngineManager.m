//
//  UdeskAgoraRtcEngineManager.m
//  UdeskSDK
//
//  Created by xuchen on 2017/11/28.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskAgoraRtcEngineManager.h"
#import <UdeskCall/UdeskCall.h>

@interface UdeskAgoraRtcEngineManager()<UdeskCallSessionManagerDelegate,AgoraRtcEngineDelegate>

@property (nonatomic, assign) BOOL isCalling;

@end

@implementation UdeskAgoraRtcEngineManager

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static UdeskAgoraRtcEngineManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[UdeskCallSessionManager sharedManager] addDelegate:self];
        
        _agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:[UdeskCallSessionManager sharedManager].videoCallAppId delegate:self];
        [_agoraKit enableVideo];
        [_agoraKit setVideoProfile:AgoraRtc_VideoProfile_360P_4 swapWidthAndHeight:NO];
    }
    return self;
}

- (void)setLocalVideo:(UIView *)localVideo {
    _localVideo = localVideo;
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.view = localVideo;
    //    videoCanvas.uid = 0;
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [_agoraKit setupLocalVideo:videoCanvas];
    [_agoraKit startPreview];
}

//挂断
- (void)hangup {
    
    if (self.isCalling) {
        [_agoraKit leaveChannel:^(AgoraRtcStats *stat) {
            self.isCalling = NO;
            //离开频道成功
            [[UdeskCallSessionManager sharedManager] leaveChannelSuccess];
            [[UdeskCallSessionManager sharedManager] hangup];
        }];
        [_agoraKit setupLocalVideo:nil];
        [_agoraKit setEnableSpeakerphone:NO];
    }
    else {
        [[UdeskCallSessionManager sharedManager] hangup];
    }
}

#pragma mark - @protocol UdeskVideoCallDelegate
//收到挂断(离开频道)
- (void)remoteUserDidHangup:(NSString *)userId {
    
    NSString *currentUserId = [UdeskCallSessionManager sharedManager].userProfile.userId;
    if (![currentUserId isEqualToString:userId]) {
        
        [_agoraKit leaveChannel:^(AgoraRtcStats *stat) {
            self.isCalling = NO;
            //离开频道成功
            [[UdeskCallSessionManager sharedManager] leaveChannelSuccess];
        }];
    }
    
    //离开
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcEngine:didOfflineOfUid:)]) {
        [self.delegate rtcEngine:self.agoraKit didOfflineOfUid:userId];;
    }
}

//收到拒绝
- (void)remoteUserDidDecline:(NSString *)userId {
    
    //离开
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcEngine:didOfflineOfUid:)]) {
        [self.delegate rtcEngine:self.agoraKit didOfflineOfUid:userId];;
    }
}

//无应答
- (void)remoteUserDidNotAnswered:(NSString *)userId {
    
    //离开
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcEngine:didOfflineOfUid:)]) {
        [self.delegate rtcEngine:self.agoraKit didOfflineOfUid:userId];;
    }
}

//忙线
- (void)remoteUserDidLineBusy:(NSString *)userId {
    
    //离开
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcEngine:didOfflineOfUid:)]) {
        [self.delegate rtcEngine:self.agoraKit didOfflineOfUid:userId];;
    }
}

//对方未登录
- (void)remoteUserDidNotLogedIn:(NSString *)userId {
    
    //离开
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcEngine:didOfflineOfUid:)]) {
        [self.delegate rtcEngine:self.agoraKit didOfflineOfUid:userId];;
    }
}

//网络连接正常
- (void)connectionDidNormal {

    if (self.delegate && [self.delegate respondsToSelector:@selector(networkConnectionDidNormal)]) {
        [self.delegate networkConnectionDidNormal];
    }
}

//网络连接失败
- (void)connectionDidLost {
    
    //离开
    if (self.delegate && [self.delegate respondsToSelector:@selector(networkConnectionDidLost)]) {
        [self.delegate networkConnectionDidLost];
    }
}

//加入频道
- (void)userJoinChannel:(NSString *)userId channelToken:(NSString *)channelToken channelId:(NSString *)channelId agoraUid:(NSUInteger)agoraUid {
    
    [_agoraKit joinChannelByKey:channelToken channelName:channelId info:nil uid:agoraUid joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        
        self.isCalling = YES;
        [_agoraKit setEnableSpeakerphone:YES];
        //加入频道成功
        [[UdeskCallSessionManager sharedManager] joinChannelSuccess];
        //屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        NSLog(@"UdeskCall：用户%ld加入channel成功",uid);
    }];
}

#pragma mark - @protocol AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.view = self.remoteVideo;
    videoCanvas.uid = uid;
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [_agoraKit setupRemoteVideo:videoCanvas];
    
    //加入成功回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcEngine:firstRemoteVideoDecodedOfUid:)]) {
        [self.delegate rtcEngine:engine firstRemoteVideoDecodedOfUid:uid];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    self.remoteVideo.hidden = muted;
}

@end
