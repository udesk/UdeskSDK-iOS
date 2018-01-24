//
//  UdeskCallSessionManager.h
//  UdeskSDK
//
//  Created by xuchen on 2017/12/12.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskCallUserProfile.h"

typedef NS_ENUM(NSUInteger, UVCClientStatus) {
    Incomming,
    Outgoing,
    Talking,
    Idle,
};

@protocol UdeskCallSessionManagerDelegate <NSObject>

@optional
//挂断
- (void)remoteUserDidHangup:(NSString *)userId;
//邀请
- (void)remoteUserDidInvite:(NSString *)userId;
//拒绝
- (void)remoteUserDidDecline:(NSString *)userId;
//取消
- (void)remoteUserDidCancel:(NSString *)userId;
//忙线
- (void)remoteUserDidLineBusy:(NSString *)userId;
//无应答
- (void)remoteUserDidNotAnswered:(NSString *)userId;
//加入频道
- (void)userJoinChannel:(NSString *)userId channelToken:(NSString *)channelToken channelId:(NSString *)channelId agoraUid:(NSUInteger)agoraUid;
//信令连接成功
- (void)signalingDidConnected:(UVCClientStatus)clientStatus;
//用户未登录
- (void)remoteUserDidNotLogedIn:(NSString *)userId;

//网络断开连接
- (void)connectionDidLost;
//网络连接正常
- (void)connectionDidNormal;

@end

@interface UdeskCallSessionManager : NSObject

@property (nonatomic, strong) UdeskCallUserProfile *userProfile;
@property (nonatomic, strong, readonly) NSString *videoCallAppId;

+ (instancetype)sharedManager;

//邀请视频
- (void)inviteVideo;

//同意通话
- (void)acceptCall;
//拒绝通话
- (void)rejeptCall;

//挂断
- (void)hangup;
//取消通话
- (void)cancel;

//加入频道成功调用
- (void)joinChannelSuccess;
//离开频道成功调用
- (void)leaveChannelSuccess;

//连接
- (void)connect;
//断开连接
- (void)disConnect;

//delegate
- (void)addDelegate:(id<UdeskCallSessionManagerDelegate>)delegate;
- (void)removeDelegate:(id<UdeskCallSessionManagerDelegate>)delegate;

@end
